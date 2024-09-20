import Foundation
import CoreLocation

struct User: Identifiable, Codable {
    let id: String
    let name: String
    let preferredLanguage: String
    let phone: String?
    
    enum CodingKeys: String, CodingKey {
            case id
            case name
            case preferredLanguage = "preferred_language"
            case phone = "phone_number"
        }
}

//"""
// USER RESPONSE SAMPLE
//{
//    "created_at": "2024-09-10T15:02:05.967162Z",
//    "gender": "NS",
//    "id": "dfsf33-be48-sddf33-88d3-a7dd2f1aa647",
//    "name": "Johnny Depp",
//    "phone_number": "+6512345671",
//    "preferred_language": "en",
//    "updated_at": "2024-09-10T15:02:05.967162Z"
//}
//"""

struct NetworkError {
    let code: Int
    let message: String
}

class API: ObservableObject {
    @Published var user: User?
    
    enum SignInResponse {
        case loggedIn
        case withoutName
    }
    
    @discardableResult
    func signIn(with token: String) async throws -> SignInResponse {
        UserDefaults.standard.setValue(token, forKey: Keys.authToken)
        
        print("token =====", token)
        
        let url = "/users/me?token="
        
        guard let url = URL(string: Strings.baseURL + url + token) else {
            throw LocalError(message: "Can't form Sign In URL")
        }

        let request = URLRequest(url: url)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let response = response as? HTTPURLResponse else {
            throw LocalError(message: "Invalid response")
        }
        
        print("data =======", String(data: data, encoding: String.Encoding.utf8))
        
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
    
    func signOut() async {
        UserDefaults.standard.removeObject(forKey: Keys.authToken)
        try? await Authentication().logout()
    }
    
    func completeUser(with name: String) async throws {
        let url = "/users?token="
        
        guard let token = UserDefaults.standard.string(forKey: Keys.authToken) else {
            throw LocalError(message: "Token not found")
        }
        
        guard let url = URL(string: Strings.baseURL + url + token) else {
            throw LocalError(message: "Can't form Complete profile URL")
        }
        

        let jsonData = try JSONEncoder().encode(["name": name])

        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let response = response as? HTTPURLResponse else {
            throw LocalError(message: "Invalid response")
        }
        
        print("data =======", String(data: data, encoding: String.Encoding.utf8))
        
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
    }
    
    func homeSections() async throws -> [HomeSectionModel] {
        let url = "/home_sections"
        
        guard let token = UserDefaults.standard.string(forKey: Keys.authToken) else {
            throw LocalError(message: "Token not found")
        }
        
        guard let url = URL(string: Strings.baseURL + url) else {
            throw LocalError(message: "Can't form Complete profile URL")
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let config = URLSessionConfiguration.default
//        config.protocolClasses = [MockHomeSectionURLProtocol.self]
        let session = URLSession(configuration: config)
        
        let (data, response) = try await session.data(for: request)
        
        guard let response = response as? HTTPURLResponse else {
            throw LocalError(message: "Invalid response")
        }
        
        print("data =======", String(data: data, encoding: String.Encoding.utf8))
        
        guard response.statusCode == 200 else {
            throw LocalError(message: "Something went wrong")
        }
        
        do {
            let homeSections = try JSONDecoder().decode([HomeSectionModel].self, from: data)
            return await MainActor.run {
                return homeSections
            }
        } catch {
            throw LocalError(message: "Incorrect server data")
        }
    }
    
    func packagesForMerchant(_ id: String) async throws -> [PackageModel] {
        let url = "/merchants/\(id.lowercased())/packages"
        
        guard let token = UserDefaults.standard.string(forKey: Keys.authToken) else {
            throw LocalError(message: "Token not found")
        }
        
        guard let url = URL(string: Strings.baseURL + url) else {
            throw LocalError(message: "Can't form Complete profile URL")
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let config = URLSessionConfiguration.default
//        config.protocolClasses = [MockProductsURLProtocol.self]
        let session = URLSession(configuration: config)
        
        let (data, response) = try await session.data(for: request)
        
        guard let response = response as? HTTPURLResponse else {
            throw LocalError(message: "Invalid response")
        }
        
        print("data =======", String(data: data, encoding: String.Encoding.utf8))
        
        guard response.statusCode == 200 else {
            throw LocalError(message: "Something went wrong")
        }
        
        do {
            let packages = try JSONDecoder().decode([PackageModel].self, from: data)
            return await MainActor.run {
                return packages
            }
        } catch {
            throw LocalError(message: "Incorrect server data")
        }
    }
    
    func storesForMerchant(_ id: String, location: CLLocationCoordinate2D? = nil) async throws -> [MerchantStoreModel] {
        var url = "/merchants/\(id.lowercased())/stores"
        
        if let location = location {
            url = url + "?lat=\(location.latitude)&lon=\(location.longitude)"
        }
        
        guard let token = UserDefaults.standard.string(forKey: Keys.authToken) else {
            throw LocalError(message: "Token not found")
        }
        
        guard let url = URL(string: Strings.baseURL + url) else {
            throw LocalError(message: "Can't form Complete profile URL")
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let config = URLSessionConfiguration.default
//        config.protocolClasses = [MockMerchantStoresURLProtocol.self]
        let session = URLSession(configuration: config)
        
        let (data, response) = try await session.data(for: request)
        
        guard let response = response as? HTTPURLResponse else {
            throw LocalError(message: "Invalid response")
        }
        
        print("data =======", String(data: data, encoding: String.Encoding.utf8))
        
        guard response.statusCode == 200 else {
            throw LocalError(message: "Something went wrong")
        }
        
        do {
            let stores = try JSONDecoder().decode([MerchantStoreModel].self, from: data)
            return await MainActor.run {
                return stores
            }
        } catch {
            throw LocalError(message: "Incorrect server data")
        }
    }
    
    func homeSection(for id: UUID) async throws -> HomeSectionModel {
        let url = "/home_sections/\(id.uuidString.lowercased())"
        
        guard let token = UserDefaults.standard.string(forKey: Keys.authToken) else {
            throw LocalError(message: "Token not found")
        }
        
        guard let url = URL(string: Strings.baseURL + url) else {
            throw LocalError(message: "Can't form Complete profile URL")
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let (data, response) = try await session.data(for: request)
        
        guard let response = response as? HTTPURLResponse else {
            throw LocalError(message: "Invalid response")
        }
        
        print("data =======", String(data: data, encoding: String.Encoding.utf8))
        
        guard response.statusCode == 200 else {
            throw LocalError(message: "Something went wrong")
        }
        
        do {
            let homeSections = try JSONDecoder().decode(HomeSectionModel.self, from: data)
            return await MainActor.run {
                return homeSections
            }
        } catch {
            throw LocalError(message: "Incorrect server data")
        }
    }
}
