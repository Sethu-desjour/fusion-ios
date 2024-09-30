import SwiftUI
import Combine

class PackageDetailViewModel: ObservableObject {
    var api: API = API()
    var cart: Cart = Cart()
    @State private(set) var loadedData = false
    private(set) var showError = false
    @Published var package: Package = .empty
    @Published var stores: [MerchantStore] = []
    var quantity: Int {
        cart.quantity(for: package)
    }
    
    func fetch() async throws {
        guard !loadedData else {
            return
        }
        do {
            let package = try await api.packageDetails(for: package.id)
            loadedData = true
            
            await MainActor.run {
                self.package = package.toPackage()
                showError = false
            }
        } catch {
            await MainActor.run {
                showError = true
            }
        }
        
        guard let storeModels = try? await api.packageStores(for: package.id) else {
            return
        }
        
        await MainActor.run {
            self.stores = storeModels.map { $0.toStore() }
        }
    }
    
    func addToCart() async {
        try? await cart.addPackage(package.id)
    }
    
    func decreaseQuantity() async {
        if quantity == 0 {
            return
        }
        
        if quantity == 1 {
            try? await cart.deletePackage(package.id)
            return
        }
        
        Task {
            try? await cart.changeQuantity(package.id, quantity: quantity - 1)
        }
    }
    
    func increaseQuantity() {
        Task {
            try? await cart.changeQuantity(package.id, quantity: quantity + 1)
        }
    }
}
