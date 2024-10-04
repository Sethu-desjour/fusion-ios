import SwiftUI

struct MerchantStore: Identifiable {
    let id: UUID
    let name: String
    let address: String?
    let imageURL: URL?
    let distance: String?
}

extension MerchantStoreModel: RawModelConvertable {
    func toLocal() -> MerchantStore {
        .init(id: id,
              name: name,
              address: address,
              imageURL: photoURL,
              distance: distance)
    }
}

protocol RawModelConvertable {
    associatedtype LocalModel
    func toLocal() -> LocalModel
}
