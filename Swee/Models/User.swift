import Foundation

struct User: Identifiable, Codable {
    let id: String
    let name: String
    let preferredLanguage: String
    let phone: String?
    
    enum CodingKeys: String, CodingKey {
            case id
            case name
            case preferredLanguage = "preferred_language"
            case phone = "phone_number"
        }
}
