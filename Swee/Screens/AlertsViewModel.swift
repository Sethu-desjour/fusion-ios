
import SwiftUI
import Combine

class AlertsViewModel: ObservableObject {
    var api: API = API()
    @Published private(set) var loadedData = false
    @Published private(set) var showError = false
    @Published private(set) var alerts: [AlertsView.Alert] = []
    
    func fetch() async throws {
        do {
            let alertsRaw = try await self.api.getAlerts()
            
            await MainActor.run {
                alerts = alertsRaw.toLocal()
                loadedData = true
                showError = false
            }
        } catch {
            await MainActor.run {
                showError = true
            }
        }
    }
    
    var numberOfUnreadAlerts: Int {
        alerts.filter { alert in
            switch alert {
            case .announcement(let alert):
                return alert.read == false
            case .localCTA(let alert):
                return alert.read == false
            case .redeemActivity(let alert):
                return alert.read == false
            }
        }.count
    }
    
    func markAllAsRead() async throws {
        try await self.api.markAsReadAllAlerts()
    }
    
    func markAsRead(_ alertId: UUID) {
        guard let index = alerts.firstIndex(where: { alert in
            alert.id == alertId
        }) else {
            return
        }
        
        let alert = self.alerts.remove(at: index)
        
        if case .localCTA(var cta) = alert {
            cta.read = true
            alerts.insert(.localCTA(cta), at: index)
        }
    }
}
