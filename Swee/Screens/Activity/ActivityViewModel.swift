import SwiftUI
import Combine

class ActivityViewModel: ObservableObject {
    var api: API = API()
    @Published private(set) var loadedData = false
    @Published private(set) var showError = false
    @Published var purchaseSections: [DateGroup<OrderDetail>] = []
    @Published var redemptionSections: [DateGroup<RedemptionDetail>] = []
    @State private var filter: DateFilter?
    
    func fetch(with filter: DateFilter) async throws {
        if self.filter != filter {
            await MainActor.run {
                self.filter = filter
                loadedData = false
            }
        }
        do {
            let rawOrders = try await self.api.orders(with: filter.date)
            let rawRedemptions = try await self.api.redemptions(with: filter.date)
            await MainActor.run {
                loadedData = true
                showError = false
                let orders = rawOrders.map { $0.toLocal() }
                let redemptions = rawRedemptions.map { $0.toLocal() }
                self.purchaseSections = createGroups(from: orders)
                self.redemptionSections = createGroups(from: redemptions)
            }
        } catch {
            await MainActor.run {
                showError = true
            }
        }
    }
 
    func createGroups<T: CreatedAtType>(from items: [T]) -> [DateGroup<T>] {
        let calendar = Calendar.current
        var groupedRedemptions: [Date: [T]] = [:]
        for redemption in items {
            let startOfDay = calendar.startOfDay(for: redemption.createdAt)
            
            groupedRedemptions[startOfDay, default: []].append(redemption)
        }
        return groupedRedemptions
            .sorted(by: { $0.key > $1.key })
            .map { (date, items) in
            DateGroup(date: date, items: items)
        }
    }
}

protocol CreatedAtType {
    var createdAt: Date { get }
}

struct DateGroup<T: CreatedAtType> {
    let date: Date
    let items: [T]
}

extension OrderDetail: CreatedAtType {}
extension RedemptionDetail: CreatedAtType {}

