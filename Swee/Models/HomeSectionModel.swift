import SwiftUI
import Foundation

struct HomeSectionModel: Decodable {
    enum SectionType: String, Codable {
        case bannerCarousel = "BANNER_CAROUSEL"
        case bannerStatic = "BANNER_STATIC"
        case packageCarousel = "PACKAGE_CAROUSEL"
        case merchantList = "MERCHANT_LIST"
    }
    
    let id: UUID
    let title: String?
    let type: SectionType
    let banners: [BannerModel]?
    let packages: [PackageModel]?
    let merchants: [MerchantModel]?
}
