import SwiftUI
import Combine

class MyWalletViewModel: ObservableObject {
    var api: API = API()
    @Published private(set) var loadedData = false
    @Published private(set) var showError = false
    @Published var merchants: [WalletMerchant] = []
    
    func fetch() async throws {
        do {
            let merchants = try await self.api.walletMerchants()
            await MainActor.run {
                loadedData = true
                showError = false
                self.merchants = merchants.map { $0.toLocal() }
            }
        } catch {
            await MainActor.run {
                showError = true
            }
        }
    }
}

