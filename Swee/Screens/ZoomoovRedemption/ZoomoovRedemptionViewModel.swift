import SwiftUI
import Combine

class ZoomoovRedemptionViewModel: ObservableObject {
    var api: API = API()
    @Published private(set) var loadedData = false
    @Published private(set) var showError = false
    @Published var merchant: WalletMerchant = .empty
    
    func fetch() async throws {
        do {
            let merchant = try await self.api.walletMerchant(for: merchant.id)
            await MainActor.run {
                loadedData = true
                showError = false
                self.merchant = merchant.toLocal()
            }
        } catch {
            await MainActor.run {
                showError = true
            }
        }
    }
}

extension WalletMerchant {
    static var empty: Self {
        .init(id: .init(), 
              name: "Zoomoov",
              photoURL: nil,
              bgColors: [],
              purchaseSummary: "",
              products: [],
              activeSession: nil)
    }
}
