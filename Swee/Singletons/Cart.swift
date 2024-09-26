import Foundation
import Combine

struct CartItem: Codable, Identifiable {
    let id: UUID
    let packageId: UUID?
    let packageDetails: PackageModel?
//    let productId: UUID?
//    let productDetails: Product?
    let quantity: Int
    let totalPriceCents: Int64
    @DecodableDate var createdAt: Date
//    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case packageId = "package_id"
        case packageDetails = "package_details"
//        case productId = "product_id"
//        case productDetails = "product_details"
        case quantity
        case totalPriceCents = "total_price_cents"
        case createdAt = "created_at"
//        case updatedAt = "updated_at"
    }
}

struct CartModel: Codable {
    let id: UUID
    let items: [CartItem]
    let quantity: Int
    let currencyCode: String
    let priceCents: Int64
    let totalPriceCents: Int64
    let fees: [FeeModel]?
    @DecodableDate var createdAt: Date
    @DecodableDate var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case items
        case quantity
        case currencyCode = "currency_code"
        case priceCents = "price_cents"
        case totalPriceCents = "total_price_cents"
        case fees
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct FeeModel: Codable {
    let name: String
    let amountCents: Int64
    let rateMilli: Int64
    
    enum CodingKeys: String, CodingKey {
        case name
        case amountCents = "amount_cents"
        case rateMilli = "rate_milli"
    }
}

class Cart: ObservableObject {
    @Published var packages: [CartItem] = []
    var api = API()
    private let operationQueue: OperationQueue = OperationQueue()
    private var operations: [String: BlockOperation] = [:]
    var quantity: Int {
        return packages.reduce(0) { acc, item in
            return acc + item.quantity
        }
    }

    @Published private(set) var currencyCode: String = "SGD"
    @Published private(set) var priceCents: Int64 = 0
    @Published private(set) var totalPriceCents: Int64 = 0
    @Published private(set) var fees: [FeeModel]? = []
    @Published private(set) var updatedAt: Date = .now
    var inProgress = false
    var debounce_timer: Timer?
    
    func refresh() async throws {
        operationQueue.maxConcurrentOperationCount = 1
        let cart = try await self.api.latestCart()
//        guard !inProgress else {
//            print("Cancelled refresh")
//            return
//        }
        await MainActor.run {
            packages = cart.items
            currencyCode = cart.currencyCode
            priceCents = cart.priceCents
            totalPriceCents = cart.totalPriceCents
            fees = cart.fees
            updatedAt = cart.updatedAt
            inProgress = false
        }
    }
    
    func addPackage(_ id: UUID, quantity: Int = 1) async throws {
        guard !packages.contains(where: { item in
            item.packageId == id
        }) else {
            return
        }
        do {
            let item = try await self.api.addPackageToCart(id, quantity: quantity)
            await MainActor.run {
                self.packages.append(item)
            }
            Task {
                try? await refresh()
            }
        } catch {
            // @todo maybe show some kind of notification that request failed
            inProgress = false
        }
    }
    
    func changeQuantity(_ packageId: UUID, quantity: Int) async throws {
        inProgress = true
        let oldItems = packages
        guard let index = packages.firstIndex(where: { $0.packageId == packageId }) else {
            try await addPackage(packageId, quantity: quantity)
            return
        }
        let item = packages[index]
        await MainActor.run {
            packages[index] = .init(id: item.id, packageId: item.packageId, packageDetails: item.packageDetails, quantity: quantity, totalPriceCents: item.totalPriceCents, createdAt: item.createdAt)
        }
        
//        let operation = BlockOperation()
//        operation.addExecutionBlock {
//            Task {
                do {
                    try await self.api.changeQuantityInCart(for: item.id, quantity: quantity)
                    await MainActor.run {
                        debounce_timer?.invalidate()
                        debounce_timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
                            print ("Debounce this...")
                            Task {
                                self.inProgress = false
                                try? await self.refresh()
                            }
                        }
                    }
                } catch {
                    await MainActor.run {
                        self.inProgress = false
                        self.packages = oldItems
                    }
                }
//            }
//        }
    
        
//        operations[packageId.uuidString.lowercased()] = operation
//        
//        operationQueue.addOperation(operation)
    }
    
    func deletePackage(_ packageId: UUID) async throws {
        guard let index = packages.firstIndex(where: { $0.packageId == packageId }) else {
            return
        }
        inProgress = true
        let item = packages[index]
        do {
            try await api.deletePackageFromCart(item.id)
            await MainActor.run {
                let _ = packages.remove(at: index)
            }
            Task {
                try? await self.refresh()
            }
        } catch {
            inProgress = true
            // @todo maybe show some kind of notification that request failed
        }
    }

    func quantity(for package: Package) -> Int {
        guard let item = packages.first(where: { $0.packageId == package.id }) else {
            return 0
        }
        
        return item.quantity
    }
}
