import SwiftUI
import Combine

class CheckoutViewModel: ObservableObject {
    var cart: Cart = Cart()
    @State private var loadedData = false

    var quantity: Int {
        return cart.quantity
    }
    
    var cartTotal: Double {
        return Double(cart.priceCents / 100)
    }
    
    var finalTotal: Double {
        return Double(cart.totalPriceCents / 100)
    }
    
    func fetch() {
        Task {
            do {
                try await cart.refresh()
                loadedData = true
            } catch {
                // @todo parse error and show error screen
            }
        }
    }
    
    func decreaseQuantity(for item: CartItem) async {
        guard cart.packages.contains(where: { $0.id == item.id }),
              let packageId = item.packageId else {
            return
        }
        
        if item.quantity == 1 {
            try? await cart.deletePackage(packageId)
            return
        }
        
        Task {
            try? await cart.changeQuantity(packageId, quantity: item.quantity - 1)
        }
    }
    
    func increaseQuantity(for item: CartItem) {
        guard let packageId = item.packageId else {
            return
        }
        Task {
            try? await cart.changeQuantity(packageId, quantity: item.quantity + 1)
        }
    }
}
