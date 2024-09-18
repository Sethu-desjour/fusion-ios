import SwiftUI

extension Color {
    struct primary {
        static let brand = Color(hex:"#FF7BA9")
        static let dark = Color(hex:"#EF739E")
        static let darker = Color(hex:"#34775C")
        static let light = Color(hex:"#FFBDD6")
        static let lighter = Color(hex:"#FFDEEB")
    }
    
    struct secondary {
        static let brand = Color(hex:"#07CE8C")
        static let dark = Color(hex:"#4DB28A")
        static let darker = Color(hex:"#4DB28A")
        static let light = Color(hex:"#B75C44")
        static let lighter = Color(hex:"#F9BCAD")
    }
    
    struct background {
        static let white = Color(hex:"#FFFFFF")
        static let pale = Color(hex:"#F7F9FA")
    }
    
    struct text {
        static let black100 = Color(hex:"#131414")
        static let black80 = Color(hex:"#424343")
        static let black60 = Color(hex:"#717272")
        static let black40 = Color(hex:"#A1A1A1")
        static let black20 = Color(hex:"#D0D0D0")
        static let black10 = Color(hex:"#E7E7E7")
    }
    
    struct gradient {
        static let primary: [Color] = [Color(hex: "#FFBDD6"), Color(hex: "#FF7BA9"), Color(hex: "#BF5C7F")]
        static let secondary: [Color] = [Color(hex: "#67EEB8"), Color(hex: "#07CE8C"), Color(hex: "#34775C")]
        static let primaryDark: [Color] = [Color(hex: "#FFDEEB"), Color(hex: "#BF5C7F")]
        static let secondaryDark: [Color] = [Color(hex: "#B3F7DB"), Color(hex: "#34775C")]
    }
}

extension Color {
    init(hex: String, opacity: Double = 1) {
        var cleanHexCode = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        cleanHexCode = cleanHexCode.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        Scanner(string: cleanHexCode).scanHexInt64(&rgb)
        let redValue = Double((rgb >> 16) & 0xFF) / 255.0
        let greenValue = Double((rgb >> 8) & 0xFF) / 255.0
        let blueValue = Double(rgb & 0xFF) / 255.0
        self.init(red: redValue, green: greenValue, blue: blueValue, opacity: opacity)
    }
}

extension Color: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let hexString = try container.decode(String.self)
        
        self = Color(hex: hexString)
    }
}
