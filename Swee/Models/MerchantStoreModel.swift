import Foundation

struct MerchantStoreModel: Codable {
    let id: UUID
    let name: String
    let photoURL: URL?
    let email: String?
    let phoneNumber: String?
    let lat: Double
    let lon: Double
    let distance: String?
    @DecodableDate var createdAt: Date
    @DecodableDate var updatedAt: Date
    
    private enum CodingKeys: String, CodingKey {
        case id, name
        case photoURL = "photo_url"
        case email
        case phoneNumber = "phone_number"
        case lat, lon, distance
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
