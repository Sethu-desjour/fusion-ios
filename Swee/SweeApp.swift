import SwiftUI
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

final class AppRootManager: ObservableObject {
    
    @Published var currentRoot: AppRoots = .splash
    
    enum AppRoots {
        case splash
        case onboarding
        case authentication
        case home
    }
}


@main
struct SweeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var appRootManager = AppRootManager()
    @StateObject var api = API()
    @StateObject var cart = Cart()
    @StateObject var locationManager = LocationManager()
    
    var body: some Scene {
        WindowGroup {
            Group {
                switch appRootManager.currentRoot {
                case .splash:
                    SplashView()
                case .onboarding:
                    OnboardingView()
                case .authentication:
                    AuthView()
                case .home:
                    MainView()
                }
            }
            .onAppear(perform: {
                cart.api = api
            })
            .onChange(of: api.sendToAuth, perform: { newValue in
                // @todo probably show alert
                if newValue {
                    appRootManager.currentRoot = .authentication
                }
            })
            .environmentObject(appRootManager)
            .environmentObject(api)
            .environmentObject(cart)
            .environmentObject(locationManager)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Auth.auth().setAPNSToken(deviceToken, type: .unknown)
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification notification: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if Auth.auth().canHandleNotification(notification) {
            completionHandler(.noData)
            return
        }
        // This notification is not auth related; it should be handled separately.
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
      return GIDSignIn.sharedInstance.handle(url)
    }
}
