import Foundation
import SwiftUI

struct Purchase: Equatable {
    let id: UUID
    let merchantID: UUID
    let type: ProductType
    let remainingValue: Int
    let status: PurchaseStatus
    let note: String?
    let expiresAt: Date
}

extension PurchaseModel: RawModelConvertable {
    func toLocal() -> Purchase {
        .init(id: id,
              merchantID: merchantID,
              type: productType,
              remainingValue: remainingValue,
              status: status,
              note: productNotes,
              expiresAt: expiresAt)
    }
}
