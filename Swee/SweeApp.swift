import SwiftUI

final class AppRootManager: ObservableObject {
    
    @Published var currentRoot: eAppRoots = .authentication
    
    enum eAppRoots {
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
