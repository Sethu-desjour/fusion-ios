import SwiftUI
import Combine

class SeeAllViewModel: ObservableObject {
    var api: API = API()
    @Published private(set) var loadedData = false
    // NOTE: only handling Packages for now since we don't have designs for
    // how See All page will look for other home view models
    @Published var packages: [Package] = []
    @Published private(set) var showError = false
    
    func fetch(with id: UUID) async throws {
        do {
            let section = try await self.api.homeSection(for: id)
            await MainActor.run {
                loadedData = true
                showError = false
                switch section.type {
                case .packageCarousel:
                    self.packages = section.packages.toLocal()
                case .bannerCarousel, .bannerStatic, .merchantList:
                    showError = true
                    print("Wrong models returned in See All")
                }
            }
        } catch {
            await MainActor.run {
                showError = true
            }
        }
    }
}
