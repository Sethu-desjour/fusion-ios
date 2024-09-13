import SwiftUI

extension Color {
    struct primary {
        static let brand = Color(hex:"#00B7AA")
        static let dark = Color(hex:"#008980")
        static let light = Color(hex:"#005C55")
        static let lighter = Color(hex:"#80DBD5")
    }
    
    struct secondary {
        static let brand = Color(hex:"#F57A5B")
        static let dark = Color(hex:"#DC6E52")
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
        static let primary: [Color] = [Color(hex: "#80DBD5"), Color(hex: "#00B7AA"), Color(hex: "#008980")]
        static let secondary: [Color] = [Color(hex: "#F57A5B"), Color(hex: "#F09819")]
        static let primaryDark: [Color] = [Color(hex: "#03959A"), Color(hex: "#01AA8F")]
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
