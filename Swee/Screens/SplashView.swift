import SwiftUI

struct SplashView: View {
    @EnvironmentObject private var appRootManager: AppRootManager
    @EnvironmentObject private var api: API
    @EnvironmentObject private var cart: Cart
    
    @State private var goToCompleteProfile = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.background.pale
                NavigationLink(isActive: $goToCompleteProfile) {
                    CompleteProfileView()
                } label: {}
                VStack(spacing: 30) {
                    Image("splash_logo")
                        .resizable()
                        .frame(width: 190, height: 70)
                    ProgressView()
                }
                VStack(spacing: 0) {
                    Spacer()
                    Image("splash_bg")
                        .resizable()
                        .scaledToFit()
                        .ignoresSafeArea()
                }
            }
            .navigationBarHidden(true)
            .ignoresSafeArea()
            .onAppear {
                let onboardingSeen = UserDefaults.standard.bool(forKey: Keys.onboardingFlagKey)
                if !onboardingSeen {
                    appRootManager.currentRoot = .onboarding
                    return
                }
                guard let token = UserDefaults.standard.string(forKey: Keys.authToken) else {
                    Task {
                        await MainActor.run {
                            appRootManager.currentRoot = .authentication
                        }
                    }
                    return
                }
                Task {
                    do {
                        let result = try await api.signIn(with: token)
                        try? await cart.refresh()
                        await MainActor.run {
                            switch result {
                            case .loggedIn:
                                appRootManager.currentRoot = .main
                            case .withoutName:
                                goToCompleteProfile = true
                            }
                        }
                    } catch {
                        print("startup error ======", error)
                        await MainActor.run {
                            appRootManager.currentRoot = .authentication
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    SplashView()
}
