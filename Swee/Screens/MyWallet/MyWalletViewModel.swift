import SwiftUI
import Combine

struct MyWalletMerchant {
    let id: UUID
    let name: String
    let photoURL: URL?
    let bgColors: [Color]
    let purchaseSummary: String
    let products: [PurchaseProduct]
}

struct PurchaseProduct {
    let id: UUID
    let name: String
    let type: ProductType
    let purchases: [Purchase]
}

struct Purchase {
    let id: UUID
    let merchantID: UUID
    let type: ProductType
    let remainingValue: Int
    let status: PurchaseStatus
    let expiresAt: Date
}

extension PurchaseProductModel {
    func toPurchaseProduct() -> PurchaseProduct {
        let purchases = purchases ?? []
        return .init(id: productID, 
                     name: productName,
                     type: productType,
                     purchases: purchases.map { $0.toPurchase() } )
    }
}

extension PurchaseModel {
    func toPurchase() -> Purchase {
        .init(id: id,
              merchantID: merchantID,
              type: productType,
              remainingValue: remainingValue,
              status: status,
              expiresAt: expiresAt)
    }
}

extension WalletMerchantModel {
    func toMerchant() -> MyWalletMerchant {
        let colors = merchantBackgroundColors ?? []
        let products = products ?? []
        return .init(id: merchantID,
                     name: merchantName,
                     photoURL: merchantPhotoURL,
                     bgColors: colors.map { Color(hex: $0) },
                     purchaseSummary: purchaseSummary,
                     products: products.map { $0.toPurchaseProduct() })
    }
}

class MyWalletViewModel: ObservableObject {
    var api: API = API()
    @Published private(set) var loadedData = false
    @Published private(set) var showError = false
    @Published var merchants: [MyWalletMerchant] = []
    
    func fetch() async throws {
        do {
            let merchants = try await self.api.walletMerchants()
            await MainActor.run {
                loadedData = true
                showError = false
                self.merchants = merchants.map { $0.toMerchant() }
            }
        } catch {
            await MainActor.run {
                showError = true
            }
        }
    }
}

