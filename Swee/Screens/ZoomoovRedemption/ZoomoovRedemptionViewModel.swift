import SwiftUI
import Combine

class ZoomoovRedemptionViewModel: ObservableObject {
    var api: API = API()
    @Published private(set) var loadedData = false
    @Published private(set) var showError = false
    @Published var merchant: WalletMerchant = .empty
    var dismiss: DismissAction?
    
    func fetch() async throws {
        do {
            let merchant = try await self.api.walletMerchant(for: merchant.id)
            await MainActor.run {
                loadedData = true
                showError = false
                self.merchant = merchant.toLocal()
                if self.merchant.products.isEmpty {
                    dismiss?()
                }
            }
        } catch {
            if let apiError = error as? APIError  {
                if case .notFound = apiError {
                    await MainActor.run { [weak self] in
                        self?.dismiss?()
                    }
                    return
                }
            }
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
