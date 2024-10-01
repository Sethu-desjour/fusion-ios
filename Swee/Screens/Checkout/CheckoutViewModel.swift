import SwiftUI
import Combine

class CheckoutViewModel: ObservableObject {
    enum State {
        case loaded
        case empty
        case error
        case paymentSucceeded
        case paymentFailed
    }
    
    var cart: Cart = Cart()
    private var loadedData = false
    private var showError = false
    private var cancellables = Set<AnyCancellable>()
    @Published private(set) var state: State = .loaded
    
    var quantity: Int {
        return cart.quantity
    }
    
    var cartTotal: Double {
        return Double(cart.priceCents / 100)
    }
    
    var finalTotal: Double {
        return Double(cart.totalPriceCents / 100)
    }
    
    func fetch() async throws {
        self.cart.$packages.sink { items in
            Task {
                await MainActor.run { [weak self] in
                    self?.state = items.isEmpty ? .empty : .loaded
                }
            }
        }
        .store(in: &cancellables)
        do {
            try await cart.refresh()
            await MainActor.run {
                showError = false
                loadedData = true
            }
        } catch {
            await MainActor.run {
                state = .error
                showError = true
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
    
    func checkout() async throws {
        do {
            try await cart.checkout()
            await MainActor.run {
                state = .paymentSucceeded
            }
        } catch {
            await MainActor.run {
                state = .paymentFailed
            }
        }
    }
}
