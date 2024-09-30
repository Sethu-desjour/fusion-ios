import SwiftUI
import Combine

class MerchantPageViewModel: ObservableObject {
    var api: API = API()
    var locationManager = LocationManager()
    @State private(set) var loadedData = false
    @Published private(set) var showError = false
    @Published var packages: [Package] = []
    @Published var stores: [MerchantStore] = []
    
    func fetch(with id: String) async throws {
        guard !loadedData else {
            return
        }
        
        do {
            let packageModels = try await self.api.packagesForMerchant(id)
            loadedData = true
            
            await MainActor.run {
                showError = false
                self.packages = packageModels.map { $0.toPackage() }
            }
        } catch {
            await MainActor.run {
                showError = true
            }
        }
        
        do {
            let storeModels = try await self.api.storesForMerchant(id, location: locationManager.lastKnownLocation)
            
            await MainActor.run {
                self.stores = storeModels.map { $0.toStore() }
            }
        } catch {
            // @todo parse error and show error screen
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
