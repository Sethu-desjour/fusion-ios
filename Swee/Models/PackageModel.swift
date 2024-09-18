import SwiftUI

struct PackageModel: Codable {
    enum Status: String, Codable {
        case available = "AVAILABLE"
        case unavailable = "UNAVAILABLE"
        case archived = "ARCHIVED"
    }
    
    let id: UUID
    let name: String
    let description: String?
    let currencyCode: String
    let priceCents: Int
    let merchantName: String
    let originalPriceCents: Int?
    let status: Status
//    let details: [String: Any]?
    let stores: [MerchantStoreModel]?
    let photoURL: URL?
    @DecodableDate var createdAt: Date
    @DecodableDate var updatedAt: Date
    
    private enum CodingKeys: String, CodingKey {
        case id, name, description
        case currencyCode = "currency_code"
        case priceCents = "price_cents"
        case originalPriceCents = "original_price_cents"
        case merchantName = "merchant_name"
//        case details
        case status, stores
        case photoURL = "photo_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
