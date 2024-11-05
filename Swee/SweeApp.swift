import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseMessaging
import GoogleSignIn
import StripePaymentSheet

final class AppRootManager: ObservableObject {
    
    @Published var currentRoot: AppRoots = .splash
    
    enum AppRoots {
        case splash
        case onboarding
        case authentication
        case home
    }
}

enum Route: Hashable {
    case package(UUID)
}

@main
struct SweeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var appRootManager = AppRootManager()
    @StateObject var api = API()
    @StateObject var cart = Cart()
    @StateObject var locationManager = LocationManager()
    @State var route: Route?
    @State private var delayedRoute: Route?
    @State var fcmToken: String?
    
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
            .onOpenURL(perform: { url in
                let stripeHandled = StripeAPI.handleURLCallback(with: url)
                guard !stripeHandled else {
                    return
                }
                if url.scheme == "com.fusion.green" {
                    if url.host == "stripe-redirect" {
                        return
                    }
                    let newRoute = Route.package(.init(uuidString: "8da6f2c0-691f-41ce-9ea7-8bd16c77c2ee".uppercased())!) // @todo remove the test UUID and parse the url
                    if appRootManager.currentRoot != .home {
                        delayedRoute = newRoute
                    } else {
                        route = newRoute
                    }
                }
            })
            .onChange(of: delegate.fcmToken, perform: { newValue in
                fcmToken = newValue
                guard let newValue else {
                    return
                }
                Task {
                    try? await api.savePushToken(newValue)
                }
            })
            .onChange(of: appRootManager.currentRoot, perform: { newValue in
                if newValue == .home {
                    route = delayedRoute
                    delayedRoute = nil
                }
            })
            .onChange(of: api.sendToAuth, perform: { newValue in
                if newValue {
                    cart.reset()
                    appRootManager.currentRoot = .authentication
                }
            })
            .environment(\.route, $route)
            .environment(\.fcmToken, $fcmToken)
            .environmentObject(appRootManager)
            .environmentObject(api)
            .environmentObject(cart)
            .environmentObject(locationManager)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate, ObservableObject {
    
    @Published var fcmToken: String?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
          options: authOptions,
          completionHandler: { _, _ in }
        )

        application.registerForRemoteNotifications()
        return true
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("fcmToken =====", fcmToken)
        self.fcmToken = fcmToken
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
