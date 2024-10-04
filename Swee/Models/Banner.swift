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

extension BannerModel: RawModelConvertable {
    func toLocal() -> Banner {
        var background: Banner.Background
        if let backgroundURL = backgroundURL {
            background = .image(backgroundURL)
        } else {
            background = .gradient(backgroundColors ?? [])
        }
        
        return Banner(title: name,
                      description: description  ?? "",
                      buttonTitle: ctaText,
                      background: background,
                      badgeImage: iconURL)
    }
}
