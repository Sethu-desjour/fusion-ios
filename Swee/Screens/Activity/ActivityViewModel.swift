import SwiftUI
import Combine

class ActivityViewModel: ObservableObject {
    var api: API = API()
    @Published private(set) var loadedData = false
    @Published private(set) var showError = false
    @Published var orders: [Order] = []
    
    func fetch() async throws {
        do {
            let orders = try await self.api.orders()
            await MainActor.run {
                loadedData = true
                showError = false
                self.orders = orders.map { $0.toLocal() }
            }
        } catch {
            await MainActor.run {
                showError = true
            }
        }
    }
}

