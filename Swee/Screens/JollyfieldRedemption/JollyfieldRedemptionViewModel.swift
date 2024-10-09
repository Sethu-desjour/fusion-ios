import SwiftUI
import Combine

class JollyfieldRedemptionViewModel: ObservableObject {
    var api: API = API()
    @Published private(set) var loadedData = false
    @Published private(set) var showError = false
    @Published var children: [Child] = []
    @Published var merchant: WalletMerchant = .empty
    var availableTime: TimeInterval {
        guard let remainingValue = merchant.products.first?.purchases.first?.remainingValue else {
            return 0
        }
        return Double(remainingValue * 60)
    }
    
    var validUntilDate: Date? {
        return merchant.products.first?.purchases.first?.expiresAt
    }
    
    func fetch() async throws {
        do {
            let children = try await self.api.children()
            let merchant = try await self.api.walletMerchant(for: merchant.id)
            await MainActor.run {
                loadedData = true
                showError = false
                self.merchant = merchant.toLocal()
                guard merchant.products?.first?.purchases?.first?.productType == .timeBased else {
                    showError = true
                    return
                }
                self.children = children.toLocal()
            }
        } catch {
            await MainActor.run {
                showError = true
            }
        }
    }
}
