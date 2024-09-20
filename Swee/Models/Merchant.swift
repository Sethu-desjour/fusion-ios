import SwiftUI

struct Merchant {
    let id: UUID
    let name: String
    let description: String?
    let backgroundImage: URL?
    let backgroundColors: [Color]
    let storeImageURL: URL?
}
