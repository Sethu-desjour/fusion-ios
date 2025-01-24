import SwiftUI

struct RedemptionErrorView: View {
    struct Model {
        let header: String
        let title: String
        let qr: Image?
        let description: String
        let actionTitle: String
        var showCurrentTime: Bool = false
    }
    
    var model: Model
    var tint: Color = Color.primary.brand
    var closure: () async throws -> Void
    
    var body: some View {
        VStack {
            Text(model.header)
                .font(.custom("Poppins-SemiBold", size: 24))
                .foregroundStyle(Color.text.black100)
            Image("warning")
                .padding(.top, 70)
            Text(model.title)
                .font(.custom("Poppins-SemiBold", size: 20))
                .foregroundStyle(Color.text.black100)
            Text(model.description)
                .font(.custom("Poppins-Medium", size: 12))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.text.black60)
                .padding(.bottom, 100)
            AsyncButton(progressWidth: .infinity, progressTint: tint) {
                try? await closure()
            } label: {
                HStack {
                    Spacer()
                    Text(model.actionTitle)
                        .font(.custom("Roboto-Bold", size: 16))
                    Spacer()
                }
                .foregroundStyle(tint)
                .frame(maxWidth: .infinity)
                .contentShape(Capsule())
            }
            .buttonStyle(OutlineButton(strokeColor: tint))
            .padding(.bottom, 16)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

#Preview {
    RedemptionErrorView(model: .init(header: "Redemption failed", title: "Failed to initiate redemption", qr: nil, description: "", actionTitle: "Retry")) {
        
    }
}
