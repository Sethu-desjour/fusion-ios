import SwiftUI

struct MerchantModel: Decodable {
    enum Status: String, Codable {
        case live = "LIVE"
        case notLive = "NOT_LIVE"
    }
    
    let id: UUID
    let name: String
    let description: String?
    let photoURL: URL?
    let backgroundURL: URL?
    let backgroundColors: [Color]?
    let countryCode: String
    let status: Status
    @DecodableDate var createdAt: Date
    @DecodableDate var updatedAt: Date
    
    private enum CodingKeys: String, CodingKey {
        case id, name, description
        case photoURL = "photo_url"
        case countryCode = "country_code"
        case status
        case backgroundColors = "background_colors"
        case backgroundURL = "background_photo_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
