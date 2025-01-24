import Foundation

struct PaymentIntent: Codable, Hashable {
    let id: String
    let clientSecret: String
    let ephemeralKey: String
    let customerId: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case clientSecret = "client_secret"
        case ephemeralKey = "ephemeral_key"
        case customerId = "customer_id"
    }
}
