import SwiftUI
import Combine

class PackageDetailViewModel: ObservableObject {
    var api: API = API()
    @State private var loadedData = false
    @Published var package: Package = .init(id: .init(uuidString: "4cc469ee-7337-4644-b335-0cb6990a42c2")!, merchant: "Zoomoov", imageURL: nil, title: "Chinese New Year", description: "Some description", summary: "Some summary", price: 1000, originalPrice: 2000, currency: "SGD", details: [], tos: nil)
    @Published var stores: [MerchantStore] = []
    
//    init(loadedData: Bool = false, package: Package, stores: [MerchantStore] = []) {
//        self.loadedData = loadedData
//        self.package = package
//        self.stores = stores
//    }
    
    func fetch() {
        guard !loadedData else {
            return
        }
        Task {
            do {
                let package = try await self.api.packageDetails(for: package.id)
                loadedData = true
                
                await MainActor.run {
                    self.package = package.toPackage()
                }
            } catch {
                // @todo parse error and show error screen
            }
            
            do {
                let storeModels = try await self.api.packageStores(for: package.id)
                loadedData = true
                
                await MainActor.run {
                    self.stores = storeModels.map { $0.toStore() }
                }
            } catch {
                // @todo parse error and show error screen
            }
        }
    }
}
