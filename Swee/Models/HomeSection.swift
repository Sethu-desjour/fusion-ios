import SwiftUI
import Foundation

// MARK: - HomeSectionType Enum
enum HomeSectionType: String, Codable {
    case bannerCarousel = "BANNER_CAROUSEL"
    case bannerStatic = "BANNER_STATIC"
    case packageCarousel = "PACKAGE_CAROUSEL"
    case merchantList = "MERCHANT_LIST"
}

// MARK: - HomeSection Struct
struct HomeSectionModel: Decodable {
    let id: UUID
    let title: String?
    let type: HomeSectionType
    let banners: [BannerModel]?
    let packages: [PackageModel]?
    let merchants: [MerchantModel]?
}

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

extension Color: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let hexString = try container.decode(String.self)
        
        self = Color(hex: hexString)
    }
}

// MARK: - MerchantStatus Enum
enum MerchantStatus: String, Codable {
    case live = "LIVE"
    case notLive = "NOT_LIVE"
}

// MARK: - Merchant Struct
struct MerchantModel: Decodable {
    let id: UUID
    let name: String
    let description: String?
    let photoURL: URL?
    let backgroundURL: URL?
    let backgroundColors: [Color]?
    let countryCode: String
    let status: MerchantStatus
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

// MARK: - PackageStatus Enum
enum PackageStatus: String, Codable {
    case available = "AVAILABLE"
    case unavailable = "UNAVAILABLE"
    case archived = "ARCHIVED"
}

// MARK: - Package Struct
struct PackageModel: Codable {
    let id: UUID
    let name: String
    let description: String?
    let currencyCode: String
    let priceCents: Int
    let merchantName: String
    let originalPriceCents: Int?
    let status: PackageStatus
//    let details: [String: Any]?
    let stores: [MerchantStoreModel]?
    let photoURL: URL?
    @DecodableDate var createdAt: Date
    @DecodableDate var updatedAt: Date
    
    private enum CodingKeys: String, CodingKey {
        case id, name, description
        case currencyCode = "currency_code"
        case priceCents = "price_cents"
        case originalPriceCents = "original_price_cents"
        case merchantName = "merchant_name"
//        case details
        case status, stores
        case photoURL = "photo_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - MerchantStore Struct
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

extension DateFormatter {
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
}

@propertyWrapper
struct DecodableDate {
    var wrappedValue: Date
}

extension DecodableDate: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let dateString = try container.decode(String.self)
        
        wrappedValue = DateFormatter.iso8601Full.date(from: dateString) ?? Date()
    }
}
