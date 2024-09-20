import SwiftUI
import Combine

class SeeAllViewModel: ObservableObject {
    var api: API = API()
    @Published private(set) var loadedData = false
    // NOTE: only handling Packages for now since we don't have designs for
    // how See All page will look for other home view models
    @Published var packages: [Package] = []
    
    func fetch(with id: UUID) {
        guard !loadedData else {
            return
        }
        Task {
            do {
                let section = try await self.api.homeSection(for: id)
                await MainActor.run {
                    loadedData = true
                    switch section.type {
                    case .packageCarousel:
                        self.packages = section.packages.toPackages()
                    case .bannerCarousel, .bannerStatic, .merchantList:
                        // @todo show error state
                        print("Wrong models returned in See All")
                    }
                }
            } catch {
                // @todo parse error and show error screen
            }
        }
    }
}
