import SwiftUI
import Combine

class JollyfieldRedemptionViewModel: ObservableObject {
    var api: API = API()
    @Published private(set) var loadedData = false
    @Published private(set) var showError = false
    @Published var children: [Child] = []
    @Published var merchant: WalletMerchant = .empty
    @Published var session: Session?
    @Published var selectedChildren: Set<Child> = .init()
    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        timer.sink { [weak self] time in
            guard let session = self?.session, session.status == .inProgress, let remainingTime = session.remainingTimeMinutes, remainingTime > 0 else {
                return
            }
            print("should update remaining time....")
            self?.session?.remainingTimeMinutes = remainingTime - session.numberOfActiveKids
        }.store(in: &cancellables)
    }
    
    var indexOfLastSelectedChild: Int {
        let lastChild = children.last { child in
            selectedChildren.contains { selectedChild in
                selectedChild == child
            }
        }
        
        return children.firstIndex { $0 == lastChild } ?? 0
    }
    
    private var purchase: Purchase? {
        return merchant.products.first?.purchases.first
    }
    
    var availableTime: TimeInterval {
        if let remainingTime = session?.remainingTimeMinutes {
            return Double(remainingTime * 60)
        }
        guard let remainingValue = purchase?.remainingValue else {
            return 0
        }
        return Double(remainingValue * 60)
    }
    
    var alottedTime: TimeInterval {
        if selectedChildren.isEmpty {
            return 0
        }
        
        return availableTime / Double(selectedChildren.count)
    }
    
    var validUntilDate: Date? {
        return purchase?.expiresAt
    }
    
    func fetch() async throws {
        do {
            let children = try await self.api.children()
            print("children ids", children.map { $0.id.uuidString.lowercased() })
            let merchant = try await self.api.walletMerchant(for: merchant.id)
            await MainActor.run {
                loadedData = true
                showError = false
                self.merchant = merchant.toLocal()
                self.session = self.merchant.activeSession
                guard purchase?.type == .timeBased  else {
                    showError = true
                    return
                }
                self.children = children.toLocal()
                for child in self.children {
                    if let session = self.session, 
                        session.children.contains(where: { $0.id == child.id && $0.status == .active }) {
                        selectedChildren.insert(child)
                    }
                }
            }
        } catch {
            await MainActor.run {
                showError = true
            }
        }
    }
    
    func startSession(for selectedChildren: [Child]) async throws {
        guard let purchase = purchase else {
            throw LocalError(message: "Purchase missing")
        }
        
        let newSession = try await api.startSession(for: purchase.id,
                                                    children: selectedChildren.compactMap { $0.id }).toLocal()
        await MainActor.run {
            session = newSession
        }
    }
    
//    func refershSession() async throws {
//        guard let sessionId = session?.id else {
//            throw LocalError(message: "Session is nil")
//        }
//        
//        let updatedSession = try await api.getSession(with: sessionId).toLocal()
//        
//        await MainActor.run {
//            session = updatedSession
//        }
//    }
}
