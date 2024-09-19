import SwiftUI

struct SplashView: View {
    @EnvironmentObject private var appRootManager: AppRootManager
    @EnvironmentObject private var api: API
    
    @State private var goToCompleteProfile = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.background.pale
                NavigationLink(isActive: $goToCompleteProfile) {
                    CompleteProfileView()
                } label: {}
                Image("splash_logo")
                    .resizable()
                    .frame(width: 190, height: 70)
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
                guard let token = UserDefaults.standard.string(forKey: Keys.authToken) else {
                    appRootManager.currentRoot = .authentication
                    return
                }
                Task {
                    do {
                        let result = try await api.signIn(with: token)
                        await MainActor.run {
                            switch result {
                            case .loggedIn:
                                appRootManager.currentRoot = .home
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
