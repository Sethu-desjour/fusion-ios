import Foundation

class MockProductsURLProtocol: URLProtocol {
    
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
                       "id": "f1b3a1bc-7fa9-4a7f-b481-6f8b7679dcb9",
                       "name": "Chinese New Year",
                       "description": "4 Rides Special Package",
                       "currency_code": "SGD",
                       "price_cents": 10000,
                       "merchant_name": "Zoomooov",
                       "original_price_cents": 20000,
                       "status": "AVAILABLE",
                       "details": {},
                       "stores": [
                         {
                           "id": "c2bf1bb5-c5b4-498e-8c6e-2b31d8edff64",
                           "name": "Jurong Point Mall",
                           "photo_url": "https://example.com/store1.jpg",
                           "email": "store1@example.com",
                           "phone_number": "+6591234567",
                           "lat": 1.3456,
                           "lon": 103.1234,
                           "distance": "0.5 km",
                           "created_at": "2023-01-01T10:00:00Z",
                           "updated_at": "2023-01-01T10:00:00Z"
                         }
                       ],
                       "photo_url": "https://i.ibb.co/7zZQ2Fs/offer-2-3x.png",
                       "created_at": "2023-09-01T10:00:00Z",
                       "updated_at": "2023-09-10T10:00:00Z"
                     },
                     {
                       "id": "f1b3a1bc-7fa9-4a7f-b481-6f8b7679dcb9",
                       "name": "Chinese New Year",
                       "description": "4 Rides Special Package",
                       "currency_code": "SGD",
                       "price_cents": 10000,
                       "merchant_name": "Zoomooov",
                       "original_price_cents": 20000,
                       "status": "AVAILABLE",
                       "details": {},
                       "stores": [
                         {
                           "id": "c2bf1bb5-c5b4-498e-8c6e-2b31d8edff64",
                           "name": "Jurong Point Mall",
                           "photo_url": "https://example.com/store1.jpg",
                           "email": "store1@example.com",
                           "phone_number": "+6591234567",
                           "lat": 1.3456,
                           "lon": 103.1234,
                           "distance": "0.5 km",
                           "created_at": "2023-01-01T10:00:00Z",
                           "updated_at": "2023-01-01T10:00:00Z"
                         }
                       ],
                       "photo_url": "https://i.ibb.co/7zZQ2Fs/offer-2-3x.png",
                       "created_at": "2023-09-01T10:00:00Z",
                       "updated_at": "2023-09-10T10:00:00Z"
                     },
                     {
                       "id": "f1b3a1bc-7fa9-4a7f-b481-6f8b7679dcb9",
                       "name": "Chinese New Year",
                       "description": "4 Rides Special Package",
                       "currency_code": "SGD",
                       "price_cents": 10000,
                       "merchant_name": "Zoomooov",
                       "original_price_cents": 20000,
                       "status": "AVAILABLE",
                       "details": {},
                       "stores": [
                         {
                           "id": "c2bf1bb5-c5b4-498e-8c6e-2b31d8edff64",
                           "name": "Jurong Point Mall",
                           "photo_url": "https://example.com/store1.jpg",
                           "email": "store1@example.com",
                           "phone_number": "+6591234567",
                           "lat": 1.3456,
                           "lon": 103.1234,
                           "distance": "0.5 km",
                           "created_at": "2023-01-01T10:00:00Z",
                           "updated_at": "2023-01-01T10:00:00Z"
                         }
                       ],
                       "photo_url": "https://i.ibb.co/7zZQ2Fs/offer-2-3x.png",
                       "created_at": "2023-09-01T10:00:00Z",
                       "updated_at": "2023-09-10T10:00:00Z"
                     },
                     {
                       "id": "f1b3a1bc-7fa9-4a7f-b481-6f8b7679dcb9",
                       "name": "Chinese New Year",
                       "description": "4 Rides Special Package",
                       "currency_code": "SGD",
                       "price_cents": 10000,
                       "merchant_name": "Zoomooov",
                       "original_price_cents": 20000,
                       "status": "AVAILABLE",
                       "details": {},
                       "stores": [
                         {
                           "id": "c2bf1bb5-c5b4-498e-8c6e-2b31d8edff64",
                           "name": "Jurong Point Mall",
                           "photo_url": "https://example.com/store1.jpg",
                           "email": "store1@example.com",
                           "phone_number": "+6591234567",
                           "lat": 1.3456,
                           "lon": 103.1234,
                           "distance": "0.5 km",
                           "created_at": "2023-01-01T10:00:00Z",
                           "updated_at": "2023-01-01T10:00:00Z"
                         }
                       ],
                       "photo_url": "https://i.ibb.co/7zZQ2Fs/offer-2-3x.png",
                       "created_at": "2023-09-01T10:00:00Z",
                       "updated_at": "2023-09-10T10:00:00Z"
                     },
                     {
                       "id": "f1b3a1bc-7fa9-4a7f-b481-6f8b7679dcb9",
                       "name": "Chinese New Year",
                       "description": "4 Rides Special Package",
                       "currency_code": "SGD",
                       "price_cents": 10000,
                       "merchant_name": "Zoomooov",
                       "original_price_cents": 20000,
                       "status": "AVAILABLE",
                       "details": {},
                       "stores": [
                         {
                           "id": "c2bf1bb5-c5b4-498e-8c6e-2b31d8edff64",
                           "name": "Jurong Point Mall",
                           "photo_url": "https://example.com/store1.jpg",
                           "email": "store1@example.com",
                           "phone_number": "+6591234567",
                           "lat": 1.3456,
                           "lon": 103.1234,
                           "distance": "0.5 km",
                           "created_at": "2023-01-01T10:00:00Z",
                           "updated_at": "2023-01-01T10:00:00Z"
                         }
                       ],
                       "photo_url": "https://i.ibb.co/7zZQ2Fs/offer-2-3x.png",
                       "created_at": "2023-09-01T10:00:00Z",
                       "updated_at": "2023-09-10T10:00:00Z"
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
