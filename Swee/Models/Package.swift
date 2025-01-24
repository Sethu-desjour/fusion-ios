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
    
    static var empty: Package {
        .init(id: .init(uuidString: "4cc469ee-7337-4644-b335-0cb6990a42c2")!,
              merchant: "",
              imageURL: nil,
              title: "",
              description: "",
              summary: "",
              price: 0,
              originalPrice: 0,
              currency: "",
              details: [],
              tos: nil)
    }
}

extension PackageModel: RawModelConvertable {
    func toLocal() -> Package {
        .init(id: id,
              merchant: merchantName,
              imageURL: photoURL,
              title: name,
              description: description ?? "",
              summary: productSummary,
              price: priceCents.toPrice(),
              originalPrice: originalPriceCents.toPrice(),
              currency: currencyCode,
              details: details ?? [],
              tos: tos)
    }
}

fileprivate extension Optional where Wrapped == Int {
    func toPrice() -> Double? {
        switch self {
        case .none:
            return nil
        case .some(let price):
            return price.toPrice()
        }
    }
}

fileprivate extension Int {
    func toPrice() -> Double {
        return Double(self / 100)
    }
}
