import SwiftUI

struct Merchant {
    let id: UUID
    let name: String
    let description: String?
    let backgroundImage: URL?
    let backgroundColors: [Color]
    let storeImageURL: URL?
}

extension MerchantModel: RawModelConvertable {
    func toLocal() -> Merchant {
        .init(id: id,
              name: name,
              description: description,
              backgroundImage: backgroundURL,
              backgroundColors: backgroundColors ?? [],
              storeImageURL: photoURL)
    }
}
