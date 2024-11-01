import Foundation

struct Strings {
    static let baseURL: String = "http://fusion-core-1481052354.ap-southeast-1.elb.amazonaws.com/v1"
    static let stripeReturnURL = "com.fusion.green://stripe-redirect"
    static let stripePublishableKey = "pk_test_51LUUoYK8RYfweLYTt9LSdAlQaxjwIyk7UPjXYme3J1zstiC0mcQA2zTMeEj4yTZryjzTsPJcnTWpjj9J5Epf7hzE002MVGVeVE" // @todo replace the publishable key with the live version
    static let stripeMerchantId = "merchant.com.desjour.fusion"
    static let stripeMerchantName = "Green"
}

struct Keys {
    static let authToken: String = "AuthTokenKey"
    static let authVerificationID: String = "AuthVerificationID"
    static let onboardingFlagKey: String = "OnboardingFlagKey"
}
