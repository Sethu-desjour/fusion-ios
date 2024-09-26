import SwiftUI

struct SocialButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding([.top, .bottom], 20)
            .foregroundStyle(.black)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12)
                .stroke(Color.text.black20,
                        lineWidth: 1)
            )
    }
}

struct PrimaryButton: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled: Bool
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.primary.brand.opacity(isEnabled ? 1 : 0.5))
            .foregroundStyle(.white)
            .clipShape(Capsule())
    }
}

struct EmptyStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

struct OutlineButton: ButtonStyle {
    var strokeColor: Color = .black
    var cornerRadius: CGFloat = 24
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(.clear)
            .foregroundStyle(.white)
            .clipShape(Capsule())
            .overlay(RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(strokeColor,
                        lineWidth: 1)
            )
    }
}
