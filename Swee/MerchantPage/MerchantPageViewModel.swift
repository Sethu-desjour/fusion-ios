import SwiftUI
import Combine

class MerchantPageViewModel: ObservableObject {
    var api: API = API()
    @State private var loadedData = false
    @Published var packages: [Package] = []
    @Published var stores: [MerchantStore] = []
    
    func fetch(with id: String) {
        guard !loadedData else {
            return
        }
        Task {
            do {
                let packageModels = try await self.api.packagesForMerchant(id)
                loadedData = true
                
                await MainActor.run {
                    self.packages = packageModels.map { $0.toPackage() }
                }
            } catch {
                // @todo parse error and show error screen
            }
            
            do {
                let storeModels = try await self.api.storesForMerchant(id)
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

extension MerchantStoreModel {
    func toStore() -> MerchantStore {
        .init(id: id,
              name: name,
              address: address,
              imageURL: photoURL,
              distance: distance)
    }
}
