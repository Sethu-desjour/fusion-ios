import SwiftUI
import Combine

class MyWalletViewModel: ObservableObject {
    var api: API = API()
    @Published private(set) var loadedData = false
    @Published private(set) var showError = false
    @Published var orders: [OrderModel] = []
    
    func fetch() async throws {
        do {
            let orders = try await self.api.orders()
            await MainActor.run {
                loadedData = true
                showError = false
                self.orders = orders
            }
        } catch {
            await MainActor.run {
                showError = true
            }
        }
    }
}
