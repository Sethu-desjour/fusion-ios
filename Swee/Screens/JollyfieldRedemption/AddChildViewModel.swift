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
    
    func save(children: [Child]) async -> [Child] {
        return await withTaskGroup(of: Child?.self) { group in
            for child in children {
                group.addTask {
                    do {
                        if let id = child.id {
                            return try await self.api.updateChild(with: id,
                                                             name: child.name,
                                                             dob: child.dob).toLocal()
                        } else {
                            return try await self.api.addChild(with: child.name,
                                                          dob: child.dob).toLocal()
                        }
                    } catch {
                        return child.id != nil ? child : nil // we're failing silently here
                    }
                }
            }

            var results: [Child] = []
            for await result in group {
                guard let child = result else {
                    continue
                }
                results.append(child)
            }

            return results
        }
    }
}
