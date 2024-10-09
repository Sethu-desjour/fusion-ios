import Foundation

extension Date {
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
}

extension Date {
    static let iso8601DateOnly: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
}

@propertyWrapper
struct DecodableDate: Equatable {
    var wrappedValue: Date
}

extension DecodableDate: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let dateString = try container.decode(String.self)
        
        wrappedValue = Date.iso8601Full.date(from: dateString) ?? Date()
    }
}

@propertyWrapper
struct DecodableDayDate<Value: Codable & Equatable> {
    var wrappedValue: Value
    
    init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
}

extension DecodableDayDate: Codable, Equatable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        // If the Value is an optional Date
        if Value.self == Date?.self {
            let dateString = try? container.decode(String.self)
            self.wrappedValue = dateString.flatMap { Date.iso8601DateOnly.date(from: $0) } as! Value
        }
        // If the Value is a non-optional Date
        else if Value.self == Date.self {
            let dateString = try container.decode(String.self)
            self.wrappedValue = (Date.iso8601DateOnly.date(from: dateString) ?? Date()) as! Value
        } else {
            throw DecodingError.typeMismatch(Value.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Invalid type for DecodableDate"))
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        // If the Value is an optional Date
        if let date = wrappedValue as? Date? {
            if let date = date {
                let dateString = Date.iso8601DateOnly.string(from: date)
                try container.encode(dateString)
            } else {
                try container.encodeNil()
            }
        }
        // If the Value is a non-optional Date
        else if let date = wrappedValue as? Date {
            let dateString = Date.iso8601DateOnly.string(from: date)
            try container.encode(dateString)
        } else {
            throw EncodingError.invalidValue(wrappedValue, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Invalid value for DecodableDate"))
        }
    }
}
