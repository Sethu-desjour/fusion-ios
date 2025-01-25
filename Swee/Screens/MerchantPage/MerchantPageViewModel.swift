import SwiftUI
import Combine

class MerchantPageViewModel: ObservableObject {
    var api = API()
    var locationManager = LocationManager()
    @State private(set) var loadedData = false
    @Published private(set) var showError = false
    @Published var packages: [Package] = []
    @Published var stores: [MerchantStore] = []
    var merchant: Merchant = .init(id: .init(), name: "", description: nil, backgroundImage: nil, backgroundColors: [], storeImageURL: nil)
    
    func fetch(with id: String) async throws {
        guard !loadedData else {
            return
        }
        
        do {
            let packageModels = try await self.api.packagesForMerchant(id)
            loadedData = true
            
            await MainActor.run {
                showError = false
                self.packages = packageModels.map { $0.toLocal() }
            }
        } catch {
            await MainActor.run {
                showError = true
            }
        }
        
        do {
            let storeModels = try await self.api.storesForMerchant(id, location: locationManager.lastKnownLocation)
            await MainActor.run {
                self.stores = storeModels.map { $0.toLocal() }
            }
        } catch {
            // fail silently
        }
    }
    
    var longDescription: Bool {
        if let count = merchant.description?.count {
            return count >= 200
        } else {
            return false
        }
    }
}
