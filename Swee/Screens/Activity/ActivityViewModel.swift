import SwiftUI
import Combine

class ActivityViewModel: ObservableObject {
    var api: API = API()
    @Published private(set) var loadedData = false
    @Published private(set) var showError = false
    @Published var purchaseSections: [PurchasesSection] = []
    @Published var redemptionSections: [RedemptionsSection] = []
    
    func fetch() async throws {
        do {
            let rawOrders = try await self.api.orders()
            let rawRedemptions = try await self.api.redemptions()
            await MainActor.run {
                loadedData = true
                showError = false
                let orders = rawOrders.map { $0.toLocal() }
                let redemptions = rawRedemptions.map { $0.toLocal() }
                self.purchaseSections = createSections(from: orders)
                self.redemptionSections = createSections(from: redemptions)
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

    func createSections(from redemptions: [Redemption]) -> [RedemptionsSection] {
        let calendar = Calendar.current
        var groupedRedemptions: [Date: [Redemption]] = [:]
        for redemption in redemptions {
            let startOfDay = calendar.startOfDay(for: redemption.createdAt)
            
            groupedRedemptions[startOfDay, default: []].append(redemption)
        }
        return groupedRedemptions
            .sorted(by: { $0.key > $1.key })
            .map { (date, redemptions) in
            RedemptionsSection(date: date, redemptions: redemptions)
        }
    }
}


