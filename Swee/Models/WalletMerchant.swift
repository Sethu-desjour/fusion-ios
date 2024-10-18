import SwiftUI

struct WalletMerchant {
    let id: UUID
    let name: String
    let photoURL: URL?
    let bgColors: [Color]
    let purchaseSummary: String
    let products: [PurchaseProduct]
    var activeSession: Session?
}

extension WalletMerchantModel: RawModelConvertable {
    func toLocal() -> WalletMerchant {
        let colors = merchantBackgroundColors ?? []
        let products = products ?? []
        return .init(id: merchantID,
                     name: merchantName,
                     photoURL: merchantPhotoURL,
                     bgColors: colors.map { Color(hex: $0) },
                     purchaseSummary: purchaseSummary,
                     products: products.map { $0.toLocal() },
                     activeSession: activeSession?.toLocal())
    }
}
