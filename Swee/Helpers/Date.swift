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

extension Date {
    func yearsBetween(endDate: Date = .now) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: self, to: endDate)
        return components.year ?? 0
    }
}

extension Date {
    var timeElapsed: String {
        let calendar = Calendar.current
        let now = Date()
        
        if let seconds = calendar.dateComponents([.second], from: self, to: now).minute, seconds < 60 {
            return "\(seconds)s"
        }
        
        if let minutes = calendar.dateComponents([.minute], from: self, to: now).minute, minutes < 60 {
            return "\(minutes)m"
        }
        
        if let hours = calendar.dateComponents([.hour], from: self, to: now).hour, hours < 24 {
            return "\(hours)h"
        }
        
        if let days = calendar.dateComponents([.day], from: self, to: now).day, days < 30 {
            return "\(days)d"
        }
        
        if let months = calendar.dateComponents([.month], from: self, to: now).month, months < 12 {
            return "\(months)mo"
        }
        
        if let years = calendar.dateComponents([.year], from: self, to: now).year {
            return "\(years)y"
        }
        
        return ""
    }
}

@propertyWrapper
struct DecodableDate<Value: Codable & Equatable> {
    var wrappedValue: Value
    
    init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
}

extension DecodableDate: Codable, Equatable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        // If the Value is an optional Date
        if Value.self == Date?.self {
            let dateString = try? container.decode(String.self)
            self.wrappedValue = dateString.flatMap { Date.iso8601Full.date(from: $0) } as! Value
        }
        // If the Value is a non-optional Date
        else if Value.self == Date.self {
            let dateString = try container.decode(String.self)
            self.wrappedValue = (Date.iso8601Full.date(from: dateString) ?? Date()) as! Value
        } else {
            throw DecodingError.typeMismatch(Value.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Invalid type for DecodableDate"))
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        // If the Value is an optional Date
        if let date = wrappedValue as? Date? {
            if let date = date {
                let dateString = Date.iso8601Full.string(from: date)
                try container.encode(dateString)
            } else {
                try container.encodeNil()
            }
        }
        // If the Value is a non-optional Date
        else if let date = wrappedValue as? Date {
            let dateString = Date.iso8601Full.string(from: date)
            try container.encode(dateString)
        } else {
            throw EncodingError.invalidValue(wrappedValue, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Invalid value for DecodableDate"))
        }
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
            }
            
            return
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


// without this the decoder doesn't know when to treat the property as an optional and will fail decoding if the field is missing in json
extension KeyedDecodingContainer {
    func decode<T: ExpressibleByNilLiteral>(_ type: DecodableDate<T>.Type, forKey key: K) throws -> DecodableDate<T> {
        if let value = try self.decodeIfPresent(type, forKey: key) {
            return value
        }

        return DecodableDate(wrappedValue: nil)
    }
}

extension KeyedDecodingContainer {
    func decode<T: ExpressibleByNilLiteral>(_ type: DecodableDayDate<T>.Type, forKey key: K) throws -> DecodableDayDate<T> {
        if let value = try self.decodeIfPresent(type, forKey: key) {
            return value
        }

        return DecodableDayDate(wrappedValue: nil)
    }
}
