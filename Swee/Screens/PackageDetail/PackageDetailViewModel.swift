import SwiftUI
import Combine

class PackageDetailViewModel: ObservableObject {
    var api: API = API()
    var cart: Cart = Cart()
    @State private var loadedData = false
    @Published var package: Package = .empty
    @Published var stores: [MerchantStore] = []
    var quantity: Int {
        cart.quantity(for: package)
    }
    
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
