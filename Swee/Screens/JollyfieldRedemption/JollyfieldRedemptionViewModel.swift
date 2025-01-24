import SwiftUI
import Combine

class JollyfieldRedemptionViewModel: ObservableObject {
    var api: API = API()
    var activeSession: ActiveSession = ActiveSession(refreshFrequencyInMin: 1)
    @Published private(set) var loadedData = false
    @Published private(set) var showError = false
    @Published var children: [Child] = []
    @Published var merchant: WalletMerchant = .empty
    var session: Session? {
        if let session = activeSession.session {
            return session
        } else {
            return merchant.activeSession
        }
    }
    @Published var selectedChildren: Set<Child> = .init()
    var dismiss: DismissAction?
    
    deinit {
        print("*** DEALLOCATING MODEL")
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
                self.activeSession.session = self.merchant.activeSession
                self.activeSession.merchant = self.merchant
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
            if let apiError = error as? APIError  {
                if case .notFound = apiError {
                    await MainActor.run { [weak self] in
                        self?.activeSession.session = nil
                        self?.dismiss?()
                    }
                    return
                }
            }
            
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
            self.activeSession.session = newSession
            self.merchant.activeSession = newSession
        }
    }
}
