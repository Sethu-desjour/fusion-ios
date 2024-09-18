import SwiftUI

// MARK: - Banner Struct
struct BannerModel: Decodable {
    let id: UUID
    let name: String
    let description: String?
    let iconURL: URL?
    let backgroundURL: URL?
    let backgroundColors: [Color]?
    let linkURL: URL?
    let ctaText: String?
    @DecodableDate var createdAt: Date
    @DecodableDate var updatedAt: Date
    
    private enum CodingKeys: String, CodingKey {
        case id, name, description
        case ctaText = "cta_text"
        case iconURL = "icon_url"
        case linkURL = "link_url"
        case backgroundColors = "background_colors"
        case backgroundURL = "background_photo_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
