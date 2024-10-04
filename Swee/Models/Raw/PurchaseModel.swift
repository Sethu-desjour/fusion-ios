import Foundation

enum PurchaseStatus: String, Codable, Equatable {
    case ready = "READY"
    case completed = "COMPLETED"
    case expired = "EXPIRED"
}

enum ProductType: String, Codable, Equatable {
    case coupon = "COUPON"
    case item = "ITEM"
    case timeBased = "TIME_BASED"
}

struct PurchaseModel: Codable {
    let id: UUID
    let userID: UUID
    let orderID: UUID
    let merchantID: UUID
    let productID: UUID
    let productType: ProductType
    let productNotes: String?
    let startingValue: Int
    let remainingValue: Int
    let status: PurchaseStatus
    @DecodableDate var expiresAt: Date
    @DecodableDate var createdAt: Date
    @DecodableDate var updatedAt: Date

    private enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case orderID = "order_id"
        case merchantID = "merchant_id"
        case productID = "product_id"
        case productType = "product_type"
        case productNotes = "product_notes"
        case startingValue = "starting_value"
        case remainingValue = "remaining_value"
        case status
        case expiresAt = "expires_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct PurchaseProductModel: Codable {
    let productID: UUID
    let productName: String
    let productType: ProductType
    let purchases: [PurchaseModel]?

    private enum CodingKeys: String, CodingKey {
        case productID = "product_id"
        case productName = "product_name"
        case productType = "product_type"
        case purchases
    }
}
