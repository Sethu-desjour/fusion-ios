import SwiftUI

struct Banner {
    enum Background {
        case image(URL)
        case gradient([Color])
    }
    
    let title: String
    let description: String
    let buttonTitle: String?
    let background: Background
    let badgeImage: URL?
}
