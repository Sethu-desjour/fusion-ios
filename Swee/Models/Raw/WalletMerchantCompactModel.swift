import Foundation

struct WalletMerchantCompactModel: Codable {
    let merchantID: UUID
    let merchantName: String
    let merchantPhotoURL: URL?
    let merchantBackgroundColors: [String]?
    let purchaseSummary: String
    
    private enum CodingKeys: String, CodingKey {
        case merchantID = "merchant_id"
        case merchantName = "merchant_name"
        case merchantPhotoURL = "merchant_photo_url"
        case merchantBackgroundColors = "merchant_background_colors"
        case purchaseSummary = "purchase_summary"
    }
}

