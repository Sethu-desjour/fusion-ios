import SwiftUI

struct ZoomoovBottomSheet: View {
    @EnvironmentObject var api: API
    @State var step: ZoomoovRedemptionSteps = .setup
    @Binding var model: ZoomoovRedemptionModel
    private var successfulScans: Int {
        redemptions.filter { $0.status == .success }.count
    }
    @State private var redemptions: [Redemption] = []
    @State var timer: DispatchSourceTimer?
    @State private var currentRedemption: Redemption?
    
    var onComplete: () -> Void
    
    func poll(for redemption: Redemption) {
        self.timer?.cancel()
        currentRedemption = redemption
        let queue = DispatchQueue.global(qos: .background)
        let timer = DispatchSource.makeTimerSource(queue: queue)
        timer.schedule(deadline: .now(), repeating: .seconds(2), leeway: .seconds(1))
        timer.setEventHandler(handler: {
            print("polling for \(redemption.id.uuidString.lowercased()).....")
            Task {
                let status = try await checkRedemptionStatus(for: redemption.id)
                guard status != .success else {
                    print("poll successful for \(redemption.id.uuidString.lowercased())")
                    if let currentRedemption = currentRedemption, currentRedemption.id == redemption.id {
                        self.timer?.cancel()
                        self.timer = nil
                    }
                    return
                }
                try? await Task.sleep(nanoseconds: 1_000_000_000)
            }
        })
        timer.resume()
        
        print("reset timer")
        self.timer = timer
    }
    
    func checkRedemptionStatus(for id: UUID) async throws -> RedemptionStatus {
        let redemptionUpdate = try await api.checkRedemptionStatus(for: id)
        await MainActor.run {
            if redemptionUpdate.status == .success, let index = redemptions.firstIndex(where: { $0.id == id }) {
                redemptions[index] = redemptionUpdate.toLocal()
                goToNextRedemption()
            }
        }
        
        return redemptionUpdate.status
    }
    
    func goToNextRedemption() {
        if let nextRedemption = redemptions.first(where: { $0.status != .success }) {
            step = .redemptionQueue(nextRedemption)
            poll(for: nextRedemption)
        } else {
            step = .completed
        }
    }
    
    var body: some View {
        VStack {
            switch step {
            case .setup:
                ZoomoovRedemptionSetupView(model: $model) {
                    do {
                        let redemptions = try await api.startRedemptions(for: model.purchaseId,
                                                                         quantity: model.qtyToRedeem)
                        .map { $0.toLocal() }
                        await MainActor.run {
                            self.redemptions = redemptions
                            guard !redemptions.isEmpty else {
                                // @todo show error screen
                                return
                            }
                            goToNextRedemption()
                        }
                    } catch {
                        print("error =======", error)
                        // @todo show error screen
                    }
                }
            case .redemptionQueue(let redemption):
                RedemptionScanView(model: .init(header: "\(model.type.capitalized) \(successfulScans + 1)/\(model.qtyToRedeem)",
                                                title: model.productType == .coupon ? "Scan QR to start your ride" : "Scan QR to get a mask", // @todo this should be optimized from BE to accomodate other types
                                                qr: redemption.qrCodeImage,
                                                description: model.productType == .coupon ? "Show this QR code at the counter, our staff will scan this QR to mark your presence" : "Show this QR code at the counter, our staff will scan this QR to provide you the mask", // @todo this as well
                                                actionTitle: "Next QR"),
                                   tint: Color.secondary.brand) {
                    do {
                        let status = try await checkRedemptionStatus(for: redemption.id)
                        guard status != .success else { return }
                        self.timer?.cancel()
                        self.timer = nil
                    } catch {
                        // @todo show error screen
                    }
    //                step = .loading
                }
            case .loading:
                RedemptionLoadingView(model: .init(header: "",
                                                   title: "Scanning for \(model.type.capitalized) \(model.currentTicket)"),
                                      tint: Color.secondary.brand) {
                    if model.currentTicket == model.qtyToRedeem {
                        step = .completed
                    } else {
                        model.currentTicket += 1
    //                    step = .redemptionQueue
                    }
                }
            case .completed:
                RedemptionCompletedView(model: .init(header: "\(model.type.capitalized) \(successfulScans)/\(model.qtyToRedeem)",
                                                     title: "\(model.qtyToRedeem) \(model.type) redeemed successfully!",
                                                     description: "",
                                                     actionTitle: "Done"),
                                        tint: Color.secondary.brand) {
                    onComplete()
                    step = .setup
                }
            }
        }
        .onDisappear {
            timer?.cancel()
            timer = nil
        }
    }
}
