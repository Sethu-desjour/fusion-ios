import Foundation

class MockMerchantStoresURLProtocol: URLProtocol {
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        let mockJSON = """
           [
               {
                   "created_at": "2024-09-17T14:56:30.799003Z",
                   "distance": "0.5 km",
                   "email": "sample@emai.com",
                   "id": "838b2074-fdb3-4f81-a99b-2a6f19eab3d3",
                   "lat": 1.23,
                   "lon": 1.23,
                   "name": "United square mall",
                   "phone_number": "+6512345678",
                   "photo_url": "https://i.ibb.co/HC6B995/location-1-3x.png",
                   "updated_at": "2024-09-17T14:56:30.799003Z"
               },
               {
                   "created_at": "2024-09-17T14:56:30.799003Z",
                   "distance": "0.5 km",
                   "email": "sample@emai.com",
                   "id": "366690eb-ed96-43d4-9b50-c63326d5fe7c",
                   "lat": 1.23,
                   "lon": 1.23,
                   "name": "Jurong point mall",
                   "phone_number": "+6512345678",
                   "photo_url": "https://i.ibb.co/sR6ghKy/location-2-3x.png",
                   "updated_at": "2024-09-17T14:56:30.799003Z"
               }
           ]
        """
        let data = mockJSON.data(using: .utf8)
        
        let response = HTTPURLResponse(url: request.url!,
                                       statusCode: 200,
                                       httpVersion: nil,
                                       headerFields: nil)
        self.client?.urlProtocol(self, didReceive: response!, cacheStoragePolicy: .notAllowed)
        self.client?.urlProtocol(self, didLoad: data!)
        

        self.client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {
        // Required to be implemented but can be left empty
    }
}
