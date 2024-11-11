import Foundation

struct AlertModel: Codable {
    let id: UUID
    let userId: UUID
    let title: String
    let body: String
    let isRead: Bool
    @DecodableDate var createdAt: Date
    @DecodableDate var updatedAt: Date
    
    private enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case title
        case body
        case isRead = "is_read"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

extension AlertModel: RawModelConvertable {
    func toLocal() -> AlertsView.Alert {
        AlertsView.Alert.localCTA(.init(id: id,
                                        read: isRead,
                                        title: title,
                                        description: body,
                                        createdAt: createdAt))
    }
}
