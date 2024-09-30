import Foundation

struct OrderItemSnapshot: Codable {
    let name: String
    let productSummary: String
    let photoURL: URL?
    let merchantID: UUID
    let merchantName: String
    let priceCents: Int64
    let originalPriceCents: Int64?
    
    private enum CodingKeys: String, CodingKey {
        case name
        case productSummary = "product_summary"
        case photoURL = "photo_url"
        case merchantID = "merchant_id"
        case merchantName = "merchant_name"
        case priceCents = "price_cents"
        case originalPriceCents = "original_price_cents"
    }
}
