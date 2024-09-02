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
    
    func strikethroughText(color: Color = Color.text.black40) -> AttributedString {
        var string = AttributedString(self)
        string.strikethroughStyle = Text.LineStyle(color: color)
        
        return string
    }
}
