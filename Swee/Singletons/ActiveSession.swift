import SwiftUI
import Combine

class ActiveSession: ObservableObject {
    private let api = API()
    @Published var session: Session?
    var sessionIsActive: Bool {
        session != nil
    }
    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    private var cancellables = Set<AnyCancellable>()

    init() {
        print("*ACTIVE SESSION INITTED*")
        timer
            .prepend(.now)
            .sink { [weak self] time in
            print("triggered session timer...")
            Task { [weak self] in
                guard let weakSelf = self else {
                    return
                }
                let sessions = try? await weakSelf.api.getSessions().toLocal()
                await MainActor.run {
                    guard let session = sessions?.first else {
                        weakSelf.session = nil
                        return
                    }
                    weakSelf.session = session
                }
            }
        }.store(in: &cancellables)
    }
    
    deinit {
        print("*ACTIVE SESSION DEINITTED*")
    }
}
