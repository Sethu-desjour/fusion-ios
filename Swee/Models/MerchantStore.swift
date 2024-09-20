import SwiftUI

struct MerchantStore: Identifiable {
    let id: UUID
    let name: String
    let address: String?
    let imageURL: URL?
    let distance: String?
}
