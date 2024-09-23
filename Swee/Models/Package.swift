import SwiftUI

struct Package {
    let id: UUID
    let merchant: String
    let imageURL: URL?
    let title: String
    let description: String
    let summary: String
    let price: Double
    let originalPrice: Double?
    let currency: String
    let details: [PackageModel.Details]
    let tos: String?
}

extension Package {
    var priceString: String {
        return "\(currency) \(String(format: "%.2f", price))"
    }
    
    var originalPriceString: String? {
        guard let originalPrice = originalPrice else {
            return nil
        }
        
        return "\(currency) \(String(format: "%.2f", originalPrice))"
    }
}
