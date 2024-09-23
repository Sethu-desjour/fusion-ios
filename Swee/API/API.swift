import Foundation
import CoreLocation

struct NetworkError {
    let code: Int
    let message: String
}

class API: ObservableObject {
    @Published var user: User?
    
    enum SignInResponse: Codable {
        case loggedIn
        case withoutName
    }
    
    @discardableResult
    func signIn(with token: String) async throws -> SignInResponse {
        UserDefaults.standard.setValue(token, forKey: Keys.authToken)
        
        print("token =====", token)
        
        let url = "/users/me?token=" + token
        
        return try await request(with: url) { data, response in
            if response.statusCode == 404 {
                let convertedString = String(data: data, encoding: String.Encoding.utf8)
                if let stringResponse = convertedString, stringResponse.contains("DATA_NOT_FOUND") {
                    return .withoutName
                } else {
                    throw LocalError(message: "Something went wrong")
                }
            }
            
            guard response.statusCode == 200 else {
                throw LocalError(message: "Something went wrong")
            }
            
            do {
                let user = try JSONDecoder().decode(User.self, from: data)
                await MainActor.run {
                    self.user = user
                }
                return .loggedIn
            } catch {
                throw LocalError(message: "Incorrect server data")
            }
        }
    }
    
    func signOut() async {
        UserDefaults.standard.removeObject(forKey: Keys.authToken)
        try? await Authentication().logout()
    }
    
    func completeUser(with name: String) async throws {
        guard let token = UserDefaults.standard.string(forKey: Keys.authToken) else {
            throw LocalError(message: "Token not found")
        }
        
        let url = "/users?token=" + token
        let jsonData = try JSONEncoder().encode(["name": name])
        
        
        try await request(with: url, method: .POST(jsonData)) { data, response in
            guard response.statusCode == 201 else {
                throw LocalError(message: "Something went wrong")
            }
            
            do {
                let user = try JSONDecoder().decode(User.self, from: data)
                await MainActor.run {
                    self.user = user
                }
            } catch {
                throw LocalError(message: "Incorrect server data")
            }
            
            return nil
        }
    }
    
    func homeSections() async throws -> [HomeSectionModel] {
        return try await request(with: "/home_sections", mockProtocol: nil /*MockHomeSectionURLProtocol.self*/)
    }
    
    func packagesForMerchant(_ id: String) async throws -> [PackageModel] {
        let url = "/merchants/\(id.lowercased())/packages"
        
        return try await request(with: url, mockProtocol: nil /*MockProductsURLProtocol.self*/)
    }
    
    func storesForMerchant(_ id: String, location: CLLocationCoordinate2D? = nil) async throws -> [MerchantStoreModel] {
        var url = "/merchants/\(id.lowercased())/stores"
        
        if let location = location {
            url = url + "?lat=\(location.latitude)&lon=\(location.longitude)"
        }
        
        return try await request(with: url, mockProtocol: nil /*MockMerchantStoresURLProtocol.self*/)
    }
    
    func homeSection(for id: UUID) async throws -> HomeSectionModel {
        try await request(with: "/home_sections/\(id.uuidString.lowercased())")
    }
    
    func packageDetails(for id: UUID) async throws -> PackageModel {
        try await request(with: "/packages/\(id.uuidString.lowercased())")
    }
    
    func packageStores(for id: UUID) async throws -> [MerchantStoreModel] {
        try await request(with: "/packages/\(id.uuidString.lowercased())/stores")
    }
}

extension API {
    fileprivate enum Method {
        case GET
        case POST(Data)
        case PUT
        case DELETE
    }
    
    fileprivate func performRequest<U: URLProtocol>(
        with url: String,
        method: Method = .GET,
        mockProtocol: U.Type? = nil
    ) async throws -> (Data, HTTPURLResponse) {
        guard let token = UserDefaults.standard.string(forKey: Keys.authToken) else {
            throw LocalError(message: "Token not found")
        }

        guard let url = URL(string: Strings.baseURL + url) else {
            throw LocalError(message: "Can't form Complete profile URL")
        }

        var request = URLRequest(url: url)
        switch method {
        case .GET:
            request.httpMethod = "GET"
        case .POST(let jsonData):
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
        case .PUT:
            request.httpMethod = "PUT"
        case .DELETE:
            request.httpMethod = "DELETE"
        }

        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let config = URLSessionConfiguration.default
        if let mock = mockProtocol {
            config.protocolClasses = [mock]
        }
        let session = URLSession(configuration: config)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw LocalError(message: "Invalid response")
        }

        return (data, httpResponse)
    }

    fileprivate func request<T: Decodable, U: URLProtocol>(
        with url: String,
        method: Method = .GET,
        intercept: ((Data, HTTPURLResponse) async throws -> T?)? = { data, response in
            guard response.statusCode == 200 else {
                throw LocalError(message: "Something went wrong")
            }
            return nil
        },
        mockProtocol: U.Type? = nil
    ) async throws -> T {
        let (data, response) = try await performRequest(with: url, method: method, mockProtocol: mockProtocol)

        if let intercept = intercept, let decision = try await intercept(data, response) {
            return decision
        }

        return try decodeResponseData(data: data)
    }

    fileprivate func request<U: URLProtocol>(
        with url: String,
        method: Method = .GET,
        intercept: ((Data, HTTPURLResponse) async throws -> Void?)? = { data, response in
            guard response.statusCode == 200 else {
                throw LocalError(message: "Something went wrong")
            }
            return nil
        },
        mockProtocol: U.Type? = nil
    ) async throws {
        let (data, response) = try await performRequest(with: url, method: method, mockProtocol: mockProtocol)

        if let intercept = intercept {
            _ = try await intercept(data, response)
        }
    }

    fileprivate func decodeResponseData<T: Decodable>(data: Data) throws -> T {
        do {
            let decodedResponse = try JSONDecoder().decode(T.self, from: data)
            return decodedResponse
        } catch {
            throw LocalError(message: "Incorrect server data")
        }
    }
}
