import Foundation
import SwiftUI

enum RedemptionStatus: String, Codable, Equatable {
    case pending = "PENDING"
    case success = "SUCCESS"
    case cancelled = "CANCELLED"
}

struct RedemptionNew: Codable {
    let purchaseId: String
    let value: Int
    
    enum CodingKeys: String, CodingKey {
        case purchaseId = "purchase_id"
        case value
    }
}

struct RedemptionStatusUpdate: Codable {
    let status: RedemptionStatus
    let merchantStoreId: String
    
    enum CodingKeys: String, CodingKey {
        case status
        case merchantStoreId = "merchant_store_id"
    }
}

struct RedemptionModel: Codable {
    let id: UUID
    let purchaseId: UUID
    let value: Int
    let qrCode: URL
    let qrCodeImage: String? // Assuming this is a base64 encoded string
    let status: RedemptionStatus
    let redemptionStoreId: UUID?
    let redemptionStoreName: String?
    @DecodableDate var createdAt: Date
    @DecodableDate var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case purchaseId = "purchase_id"
        case value
        case qrCode = "qr_code"
        case qrCodeImage = "qr_code_image"
        case status
        case redemptionStoreId = "redemption_store_id"
        case redemptionStoreName = "redemption_store_name"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
