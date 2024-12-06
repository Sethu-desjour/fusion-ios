import Foundation

struct Strings {
    #if BETA
    static let baseURL: String = "https://api.fusionkidsapp.com/v1"
    #else
    static let baseURL: String = "https://api.greenkidsapp.com/v1"
    #endif
    
    static let stripeReturnURL = "com.zoomoov.greenapp://stripe-redirect"
    static let stripePublishableKey = "pk_test_51LUUoYK8RYfweLYTt9LSdAlQaxjwIyk7UPjXYme3J1zstiC0mcQA2zTMeEj4yTZryjzTsPJcnTWpjj9J5Epf7hzE002MVGVeVE" // @todo replace the publishable key with the live version
    static let stripeMerchantId = "merchant.com.desjour.fusion"
    static let stripeMerchantName = "Green"
}

struct Keys {
    static let authToken: String = "AuthTokenKey"
    static let authVerificationID: String = "AuthVerificationID"
    static let onboardingFlagKey: String = "OnboardingFlagKey"
}
