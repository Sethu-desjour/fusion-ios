import Foundation
import UIKit
import UserNotifications

final class PushNotificationManager: NSObject, ObservableObject {
    @Published var isEnabled: Bool = false
    @Published var shouldAsk: Bool = true
    @Published private(set) var authorizationStatus: UNAuthorizationStatus?
    
    func hasPermissions() async -> Bool {
        return await withCheckedContinuation { continuation in
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                DispatchQueue.main.async {
                    self.authorizationStatus = settings.authorizationStatus
                    if case .denied = settings.authorizationStatus {
                        self.shouldAsk = false
                    }
                    if case .authorized = settings.authorizationStatus {
                        self.isEnabled = true
                        continuation.resume(returning: true)
                    } else {
                        self.isEnabled = false
                        continuation.resume(returning: false)
                    }
                }
            }
        }
    }
    
    func askForPermission() async {
        DispatchQueue.main.async {
            self.shouldAsk = false
            if self.authorizationStatus == .denied {
                if #available(iOS 16.0, *) {
                    UIApplication.shared.open(URL(string: UIApplication.openNotificationSettingsURLString)!)
                } else {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                }
                return
            }
        }
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        await withCheckedContinuation { continuation in
            UNUserNotificationCenter.current().requestAuthorization(
              options: authOptions,
              completionHandler: { enabled, _ in
                  DispatchQueue.main.async {
                      self.isEnabled = enabled
                      continuation.resume()
                  }
              }
            )
        }
    }
}
