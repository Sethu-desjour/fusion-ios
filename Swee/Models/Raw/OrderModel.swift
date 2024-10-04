import Foundation

struct OrderModel: Codable {
    enum Status: String, Codable {
        case pending = "PENDING"
        case completed = "COMPLETED"
        case failed = "FAILED"
    }
    
    let id: UUID
    let userID: UUID
    let cartID: UUID
    let status: Status
    let currencyCode: String
    let priceCents: Int64
    let totalPriceCents: Int64
    let items: [OrderItem]?
    let fees: [FeeModel]?
    @DecodableDate var createdAt: Date
    @DecodableDate var updatedAt: Date
    
    private enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case cartID = "cart_id"
        case status
        case currencyCode = "currency_code"
        case priceCents = "price_cents"
        case totalPriceCents = "total_price_cents"
        case items
        case fees
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
