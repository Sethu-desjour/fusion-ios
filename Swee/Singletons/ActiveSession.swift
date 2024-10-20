import SwiftUI
import Combine

class ActiveSession: ObservableObject {
    private let api = API()
    @Published var session: Session?
    @Published var merchant: WalletMerchant?
    var sessionIsActive: Bool {
        session != nil
    }
    
    private var timer: Publishers.Autoconnect<Timer.TimerPublisher>
    private var cancellables = Set<AnyCancellable>()

    init(refreshFrequencyInMin: Int = 1) {
        print("*ACTIVE SESSION INITTED*")
        self.timer = Timer.publish(every: Double(refreshFrequencyInMin * 60), on: .main, in: .common).autoconnect()
        setupTimer()
    }
    
    private func setupTimer() {
        timer
            .prepend(.now)
            .sink { [weak self] time in
            print("triggered session timer...")
            Task { [weak self] in
                guard let weakSelf = self else {
                    return
                }
                let sessions = try? await weakSelf.api.getSessions().toLocal()
                if let merchantId = sessions?.first?.merchantId {
                    let merchant = try? await weakSelf.api.walletMerchant(for: merchantId)
                    
                    await MainActor.run {
                        weakSelf.merchant = merchant?.toLocal()
                    }
                }
                await MainActor.run {
                    guard let session = sessions?.first else {
                        weakSelf.session = nil
                        weakSelf.merchant = nil
                        return
                    }
                    weakSelf.session = session
                }
            }
        }.store(in: &cancellables)
    }
    
    func changeFrequency(to min: Int) {
        self.timer.upstream.connect().cancel()
        self.timer = Timer.publish(every: Double(min * 60), on: .main, in: .common).autoconnect()
        setupTimer()
    }
    
    deinit {
        print("*ACTIVE SESSION DEINITTED*")
    }
}
