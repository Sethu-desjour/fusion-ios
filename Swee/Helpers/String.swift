import SwiftUI

extension String {
    func underline(font: Font = .custom("Poppins-Medium", size: 14),
                   color: Color = Color.text.black80) -> AttributedString {
        var string = AttributedString(self)
        string.font = font
        string.foregroundColor = color
        string.underlineStyle = Text.LineStyle(pattern: .solid, color: color)
        
        return string
    }
}
