import Foundation

struct ChildModel: Codable, Identifiable, Hashable {
    func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
    }
    let id: UUID
    let userId: UUID
    let name: String
    @DecodableDayDate var dateOfBirth: Date?
    @DecodableDate var createdAt: Date
    @DecodableDate var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case dateOfBirth = "date_of_birth"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
