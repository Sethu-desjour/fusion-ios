import SwiftUI

struct Order {
    let id: UUID
    let status: OrderStatus
    let type: OrderType
    let currencyCode: String
    let totalPriceCents: Int
    let quantity: Int
    let createdAtDate: Date
}

extension OrderModel: RawModelConvertable {
    func toLocal() -> Order {
        var quantity = 0
        if let items = items {
           quantity = items.reduce(0) { acc, item in
                return acc + item.quantity
            }
        }
        return .init(id: id,
                     status: status,
                     type: type,
                     currencyCode: currencyCode,
                     totalPriceCents: totalPriceCents,
                     quantity: quantity,
                     createdAtDate: createdAt)
    }
}
