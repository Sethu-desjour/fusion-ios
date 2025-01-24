import Foundation

struct RedemptionDetailModel: Codable {
    let id: UUID
    let merchantName: String
    let merchantBackgroundColors: [String]?
    let productName: String
    let productType: ProductType
    let storeName: String
    let value: Int
    let status: RedemptionStatus
    @DecodableDate var createdAt: Date
    @DecodableDate var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case merchantName = "merchant_name"
        case merchantBackgroundColors = "merchant_background_colors"
        case productName = "product_name"
        case productType = "product_type"
        case storeName = "store_name"
        case value
        case status
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
