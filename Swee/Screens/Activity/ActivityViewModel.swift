import SwiftUI
import Combine

class ActivityViewModel: ObservableObject {
    var api: API = API()
    @Published private(set) var loadedData = false
    @Published private(set) var showError = false
    @Published var purchaseSections: [PurchasesSection] = []
    
    func fetch() async throws {
        do {
            let rawOrders = try await self.api.orders()
            await MainActor.run {
                loadedData = true
                showError = false
                let orders = rawOrders.map { $0.toLocal() }
                self.purchaseSections = createSections(from: orders)
            }
        } catch {
            await MainActor.run {
                showError = true
            }
        }
    }
    
    func createSections(from orders: [Order]) -> [PurchasesSection] {
        let calendar = Calendar.current
        var groupedOrders: [Date: [Order]] = [:]
        for order in orders {
            let startOfDay = calendar.startOfDay(for: order.createdAtDate)
            
            groupedOrders[startOfDay, default: []].append(order)
        }
        return groupedOrders
            .sorted(by: { $0.key > $1.key })
            .map { (date, purchases) in
            PurchasesSection(date: date, purchases: purchases)
        }
    }

}


