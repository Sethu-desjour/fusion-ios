import SwiftUI
import Combine

struct MyWalletMerchant {
    let id: UUID
    let name: String
    let photoURL: URL?
    let bgColors: [Color]
    let purchaseSummary: String
}

extension WalletMerchantCompactModel {
    func toMerchant() -> MyWalletMerchant {
        let colors = merchantBackgroundColors ?? []
        
        return .init(id: merchantID,
                     name: merchantName,
                     photoURL: merchantPhotoURL,
                     bgColors: colors.map { Color(hex: $0) },
                     purchaseSummary: purchaseSummary)
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

