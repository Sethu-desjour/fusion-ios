import SwiftUI

final class AppRootManager: ObservableObject {
    
    @Published var currentRoot: AppRoots = .onboarding
    
    enum AppRoots {
//        case splash
        case onboarding
        case authentication
        case home
    }
}

@main
struct SweeApp: App {
    @StateObject private var appRootManager = AppRootManager()

    var body: some Scene {
        WindowGroup {
            Group {
                switch appRootManager.currentRoot {
                case .onboarding:
                    OnboardingView()
                case .authentication:
                    AuthView()
                case .home:
                    MainView()
                }
            }
            .environmentObject(appRootManager)
        }
    }
}
