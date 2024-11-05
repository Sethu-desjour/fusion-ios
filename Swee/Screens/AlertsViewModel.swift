
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
}
