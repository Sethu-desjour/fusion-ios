import SwiftUI

struct PackageModel: Codable {
    enum Status: String, Codable {
        case available = "AVAILABLE"
        case unavailable = "UNAVAILABLE"
        case archived = "ARCHIVED"
    }
    
    struct Details: Codable {
        let title: String
        let content: String
    }
    
    let id: UUID
    let name: String
    let productSummary: String
    let description: String?
    let currencyCode: String
    let priceCents: Int
    let merchantName: String
    let merchantID: UUID
    let originalPriceCents: Int?
    let status: Status
    let details: [Details]?
    let stores: [MerchantStoreModel]?
    let photoURL: URL?
    let tos: String?
    @DecodableDate var createdAt: Date
    @DecodableDate var updatedAt: Date
    
    private enum CodingKeys: String, CodingKey {
        case id, name, description
        case productSummary = "product_summary"
        case currencyCode = "currency_code"
        case priceCents = "price_cents"
        case originalPriceCents = "original_price_cents"
        case merchantName = "merchant_name"
        case merchantID = "merchant_id"
        case status, stores, details
        case photoURL = "photo_url"
        case tos = "terms_and_conditions"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
