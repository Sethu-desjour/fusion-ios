import Foundation

struct OrderItem: Codable {
    let packageID: UUID?
//    let productID: UUID?
    let quantity: Int
    let totalPriceCents: Int64
    let snapshot: OrderItemSnapshot
    
    private enum CodingKeys: String, CodingKey {
        case packageID = "package_id"
//        case productID = "product_id"
        case quantity
        case totalPriceCents = "total_price_cents"
        case snapshot
    }
}
