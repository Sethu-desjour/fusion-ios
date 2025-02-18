import SwiftUI

struct PurchaseProduct: Equatable {
    let id: UUID
    let name: String
    let type: ProductType
    let purchases: [Purchase]
}

extension PurchaseProductModel: RawModelConvertable {
    func toLocal() -> PurchaseProduct {
        let purchases = purchases ?? []
        return .init(id: productID,
                     name: productName,
                     type: productType,
                     purchases: purchases.map { $0.toLocal() } )
    }
}
