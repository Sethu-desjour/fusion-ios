import SwiftUI
import Combine

class AddChildViewModel: ObservableObject {
    var api: API = API()
    var editingMode = true
    @Published private(set) var loadedData = false
    @Published private(set) var showError = false
    @Published var children: [Child] = []
    
    func fetch() async throws {
        if editingMode {
            await MainActor.run {
                loadedData = true
            }
            return
        }
        do {
            let children = try await self.api.children()
            await MainActor.run {
                loadedData = true
                showError = false
                self.children = children.toLocal()
                if children.isEmpty {
                    self.children = [.init(name: "")]
                }
            }
        } catch {
            await MainActor.run {
                showError = true
            }
        }
    }
}
