import Foundation

class MockHomeSectionURLProtocol: URLProtocol {
    
    override class func canInit(with request: URLRequest) -> Bool {
        return request.url?.absoluteString == "\(Strings.baseURL)/home_sections"
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
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
                "icon_url": "https://i.ibb.co/qkHf8XZ/badge-1-3x.png",
                "background_photo_url": "https://i.ibb.co/ygmXXG4/banner-bg-1-3x.png",
                "link_url": "https://example.com/promo1",
                "cta_text": "Complete",
                "created_at": "2023-09-01T10:00:00Z",
                "updated_at": "2023-09-10T10:00:00Z"
              },
              {
                "id": "ac84d0c2-61ba-40e3-b4a4-9d5284aeb6f5",
                "name": "Mega Sale",
                "description": "Biggest sale of the year, up to 50% off!",
                "icon_url": "https://i.ibb.co/svVR0JX/badge-2-3x.png",
                "background_colors": [
                            "#FDC093",
                            "#9936CE",
                            "#3900B1"
                        ],
                "link_url": "https://example.com/sale",
                "cta_text": "View",
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
                "merchant_name": "Jollyfield",
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
                "photo_url": "https://i.ibb.co/C8tTtpn/offer-1-3x.png",
                "created_at": "2023-12-01T10:00:00Z",
                "updated_at": "2023-12-10T10:00:00Z"
              },
              {
                "id": "a3c2be4f-b7f8-47b2-9df7-79f8ba1ed9d1",
                "name": "Christmas Special",
                "description": "5 Rides at a Special Price",
                "currency_code": "SGD",
                "price_cents": 15000,
                "merchant_name": "Jollyfield",
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
                "photo_url": "https://i.ibb.co/C8tTtpn/offer-1-3x.png",
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
                "id": "5b752d23-23cd-4ebc-b7d4-4b62e570d0a8",
                "name": "Zoomoov",
                "description": "ZOOMOOV is a vast farming area where characters indulge in farming activities and conjures a farming process – dig, sow, harvest with the emphasis on cooperative teamwork. There is never a lack of PLAYtime with. is a vast farming area where characters indulge in farming activities and conjures a farming process – dig, sow, harvest with the emphasis on cooperative teamwork. There is never a lack of PLAYtime with.",
                "photo_url": "https://i.ibb.co/RP6nfNQ/merchant-bg-3x.png",
                "background_photo_url": "https://i.ibb.co/30myxjJ/explore-bg-2-3x.png",
                "background_colors": [
                    "#80DBD5",
                    "#00B7AA",
                    "#008980"
                ],
                "country_code": "SG",
                "status": "LIVE",
                "created_at": "2023-01-01T10:00:00Z",
                "updated_at": "2023-09-01T10:00:00Z"
              },
              {
                "id": "5135d718-666b-4068-b38b-18a7d5eca583",
                "name": "Jollyfields",
                "description": "Jollyfields is a vast farming area where characters indulge in farming activities and conjures a farming process – dig, sow, harvest with the emphasis on cooperative teamwork. There is never a lack of PLAYtime with.",
                "photo_url": "https://i.ibb.co/NT1zRJr/jollyfield.png",
                "background_photo_url": "https://i.ibb.co/m5YrgtG/explore-bg-1-3x.png",
                "background_colors": [
                    "#F57A5B",
                    "#F09819"
                ],
                "country_code": "SG",
                "status": "LIVE",
                "created_at": "2023-02-01T10:00:00Z",
                "updated_at": "2023-09-10T10:00:00Z"
              }
            ]
          },
          {
            "banners": [
                {
                    "background_photo_url": "https://i.ibb.co/LpYWLfQ/referal-bg-3x.png",
                    "created_at": "2024-09-17T14:43:11.505729Z",
                    "cta_text": "Share",
                    "description": "Enjoy a free Zoomoov ride for each friend who signs up through your referral, and your friend gets a free ride too!",
                    "id": "011b9cf9-6e54-4ec6-8eaf-722a7721208c",
                    "link_url": "https://example.com",
                    "name": "Refer a friend and earn rewards ✨",
                    "icon_url": "https://i.ibb.co/qkHf8XZ/badge-1-3x.png",
                    "updated_at": "2024-09-17T14:43:11.505729Z"
                }
            ],
            "id": "10b40ef1-5319-43cf-9965-aedf5fad9d20",
            "total_count": 1,
            "type": "BANNER_STATIC"
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
