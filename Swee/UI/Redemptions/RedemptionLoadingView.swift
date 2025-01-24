import SwiftUI

struct RedemptionLoadingView: View {
    struct Model {
        let header: String
        let title: String
    }

    var model: Model
    var tint: Color = Color.primary.brand
    var closure: (() -> Void)?
    
    var body: some View {
        ZStack(alignment: .top) {
            Text(model.header)
                .font(.custom("Poppins-SemiBold", size: 24))
                .foregroundStyle(Color.text.black100)
            VStack {
                Image("spinner")
                    .padding(.top, 150)
                    .onTapGesture {
                        closure?()
                    }
                    .padding(.bottom, 22)
                Text(model.title)
                    .font(.custom("Poppins-SemiBold", size: 20))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.text.black100)
                    .padding(.bottom, 150)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
