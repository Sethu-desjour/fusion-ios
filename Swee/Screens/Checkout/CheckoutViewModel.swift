import SwiftUI
import Combine
import StripePaymentSheet

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
    @Published var paymentSheet: PaymentSheet?
    @Published var paymentResult: PaymentSheetResult?
    
    func onPaymentCompletion(result: PaymentSheetResult) {
        self.paymentResult = result
        print("payment result =====", result)
        switch result {
        case .completed:
            state = .paymentSucceeded
        case .canceled:
            print("cancelled payment")
        case .failed(let error):
            state = .paymentFailed
        }
    }
    
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
    
    func prepareForPayment() async throws {
        if cart.packages.isEmpty {
            return
        }
        do {
            let order = try await cart.checkout()
            
            if order.status == .completed {
                await MainActor.run {
                    state = .paymentSucceeded
                }
                return
            }
            
            guard let paymentIntent = order.paymentIntent else {
                throw LocalError(message: "Missing payment intent data")
            }
            STPAPIClient.shared.publishableKey = "pk_test_51LUUoYK8RYfweLYTt9LSdAlQaxjwIyk7UPjXYme3J1zstiC0mcQA2zTMeEj4yTZryjzTsPJcnTWpjj9J5Epf7hzE002MVGVeVE"
            // MARK: Create a PaymentSheet instance
            
            await MainActor.run {
                var configuration = PaymentSheet.Configuration()
                configuration.merchantDisplayName = "Example, Inc." // @todo change this
                configuration.customer = .init(id: paymentIntent.customerId, ephemeralKeySecret: paymentIntent.ephemeralKey)
                // Set `allowsDelayedPaymentMethods` to true if your business handles
                // delayed notification payment methods like US bank accounts.
                // configuration.allowsDelayedPaymentMethods = true
                self.paymentSheet = PaymentSheet(paymentIntentClientSecret: paymentIntent.clientSecret,
                                                 configuration: configuration)
            }
        } catch {
            await MainActor.run {
                state = .error
            }
        }
    }
}

extension PaymentSheet {
    static var empty: PaymentSheet {
        return PaymentSheet(paymentIntentClientSecret: "", configuration: .init())
    }
}
