import SwiftUI

final class AppRootManager: ObservableObject {
    
    @Published var currentRoot: AppRoots = .authentication
    
    enum AppRoots {
//        case splash
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
