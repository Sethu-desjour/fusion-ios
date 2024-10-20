import Foundation
import SwiftUI

enum SessionStatus: String, Codable {
    case notStarted = "NOT_STARTED"
    case inProgress = "IN_PROGRESS"
    case completed = "COMPLETED"
}

struct SessionNew: Codable {
    let purchaseId: String
    let childrenIds: [String]
    
    enum CodingKeys: String, CodingKey {
        case purchaseId = "purchase_id"
        case childrenIds = "children_ids"
    }
}

struct SessionStatusUpdate: Codable {
    let status: SessionStatus
    let merchantStoreId: String
    
    enum CodingKeys: String, CodingKey {
        case status
        case merchantStoreId = "merchant_store_id"
    }
}

struct SessionModel: Codable {
    let id: UUID
    let qrCodeImage: String?
    let status: SessionStatus
    let merchantId: UUID?
    let merchantName: String?
    @DecodableDate var startedAt: Date?
    @DecodableDate var endedAt: Date?
    let remainingTime: String?
    let remainingTimeMinutes: Int?
    let children: [SessionChildModel]?
    let storeId: UUID?
    @DecodableDate var createdAt: Date
    @DecodableDate var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case qrCodeImage = "qr_code_image"
        case status
        case merchantId = "merchant_id"
        case merchantName = "merchant_name"
        case startedAt = "started_at"
        case endedAt = "ended_at"
        case remainingTime = "remaining_time"
        case remainingTimeMinutes = "remaining_time_minutes"
        case children
        case storeId = "store_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

enum SessionChildStatus: String, Codable {
    case active = "ACTIVE"
    case inactive = "INACTIVE"
}

struct SessionChildModel: Codable {
    let id: UUID
    let name: String
    let remainingTime: String?
    let status: SessionChildStatus
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case remainingTime = "remaining_time"
        case status
    }
}
