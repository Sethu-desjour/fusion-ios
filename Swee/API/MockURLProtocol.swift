import Foundation

// Custom URLProtocol to intercept and mock responses
class MockHomeSectionURLProtocol: URLProtocol {
    
    override class func canInit(with request: URLRequest) -> Bool {
        // Intercept the specific request you want to mock
        return request.url?.absoluteString == "http://fusion-core-1579679958.ap-southeast-1.elb.amazonaws.com/v1/home_sections"
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        // Create a mock response
        let mockJSON = """
        [
          {
            "id": "b496c89b-6e99-4080-b99e-98b4fe88678d",
            "title": "Promoted Banners",
            "type": "BANNER_CAROUSEL",
            "banners": [
              {
                "id": "e2b9692e-6e7f-4b85-b8d5-979b88a0babc",
                "name": "Zoomoov Challenge",
                "description": "Complete 10 rides to get a free ride!",
                "icon_url": "https://example.com/banner1.jpg",
                "link_url": "https://example.com/promo1",
                "created_at": "2023-09-01T10:00:00Z",
                "updated_at": "2023-09-10T10:00:00Z"
              },
              {
                "id": "ac84d0c2-61ba-40e3-b4a4-9d5284aeb6f5",
                "name": "Mega Sale",
                "description": "Biggest sale of the year, up to 50% off!",
                "icon_url": "https://example.com/banner2.jpg",
                "link_url": "https://example.com/sale",
                "created_at": "2023-09-05T08:00:00Z",
                "updated_at": "2023-09-10T08:00:00Z"
              }
            ]
          },
          {
            "id": "9c52a85b-3f3d-448b-82b7-2c707b94c8d2",
            "title": "Exclusive Packages",
            "type": "PACKAGE_CAROUSEL",
            "packages": [
              {
                "id": "f1b3a1bc-7fa9-4a7f-b481-6f8b7679dcb9",
                "name": "Chinese New Year",
                "description": "4 Rides Special Package",
                "currency_code": "SGD",
                "price_cents": 10000,
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
                "photo_url": "https://example.com/package1.jpg",
                "created_at": "2023-09-01T10:00:00Z",
                "updated_at": "2023-09-10T10:00:00Z"
              }
            ]
          },
          {
            "id": "4e726a72-ea4a-4a47-ae6e-bb6a6fda4e5b",
            "title": "Limited Time Offers",
            "type": "PACKAGE_CAROUSEL",
            "packages": [
              {
                "id": "a3c2be4f-b7f8-47b2-9df7-79f8ba1ed9d1",
                "name": "Christmas Special",
                "description": "5 Rides at a Special Price",
                "currency_code": "SGD",
                "price_cents": 15000,
                "original_price_cents": 25000,
                "status": "AVAILABLE",
                "details": {},
                "stores": [
                  {
                    "id": "1fc1d30a-54a1-4e2e-95c3-c1e4e16eb2d9",
                    "name": "Orchard Mall",
                    "photo_url": "https://example.com/store2.jpg",
                    "email": "store2@example.com",
                    "phone_number": "+6598765432",
                    "lat": 1.3000,
                    "lon": 103.8000,
                    "distance": "1.0 km",
                    "created_at": "2023-02-01T10:00:00Z",
                    "updated_at": "2023-02-01T10:00:00Z"
                  }
                ],
                "photo_url": "https://example.com/package2.jpg",
                "created_at": "2023-12-01T10:00:00Z",
                "updated_at": "2023-12-10T10:00:00Z"
              }
            ]
          },
          {
            "id": "7e0a5bbd-fd9b-42cf-b16c-8c2c695bca85",
            "title": "Top Merchants",
            "type": "MERCHANT_LIST",
            "merchants": [
              {
                "id": "7a50d881-936b-4f18-96be-9372f1d89f0f",
                "name": "Zoomoov",
                "description": "A fun activity for kids.",
                "photo_url": "https://example.com/merchant1.jpg",
                "country_code": "SG",
                "status": "LIVE",
                "created_at": "2023-01-01T10:00:00Z",
                "updated_at": "2023-09-01T10:00:00Z"
              },
              {
                "id": "ed9b8f6a-d5c8-4824-abc7-e2e9a995839d",
                "name": "Toy Kingdom",
                "description": "The best toys for all ages.",
                "photo_url": "https://example.com/merchant2.jpg",
                "country_code": "SG",
                "status": "LIVE",
                "created_at": "2023-02-01T10:00:00Z",
                "updated_at": "2023-09-10T10:00:00Z"
              }
            ]
          }
        ]
        """
        let data = mockJSON.data(using: .utf8)
        
        // Create a HTTP response and pass it back to the client
        let response = HTTPURLResponse(url: request.url!,
                                       statusCode: 200,
                                       httpVersion: nil,
                                       headerFields: nil)
        self.client?.urlProtocol(self, didReceive: response!, cacheStoragePolicy: .notAllowed)
        self.client?.urlProtocol(self, didLoad: data!)
        
        // Inform that the loading is finished
        self.client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {
        // Required to be implemented but can be left empty
    }
}

//// Register the MockURLProtocol in your app
//let config = URLSessionConfiguration.default
//config.protocolClasses = [MockURLProtocol.self]
//let session = URLSession(configuration: config)
//
//let url = URL(string: "https://example.com/api/endpoint")!
//let request = URLRequest(url: url)
//
//session.dataTask(with: request) { data, response, error in
//    if let data = data {
//        print(String(data: data, encoding: .utf8)!)
//    }
//}.resume()
