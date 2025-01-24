import SwiftUI

struct StateView: View {
    enum Images {
        case success
        case error
        case custom(String)
        
        var image: Image {
            switch self {
            case .success:
                Image("checkout-success")
            case .error:
                Image("error")
            case .custom(let imageName):
                Image(imageName)
            }
        }
    }
    
    let image: Images
    let title: String?
    let description: String?
    let buttonTitle: String
    let buttonAction: () async -> Void
    
    
    var body: some View {
        VStack {
            image.image
            if let title = title {
                Text(title)
                    .font(.custom("Poppins-Medium", size: 24))
            }
            if let description = description {
                Text(description)
                    .font(.custom("Poppins-Medium", size: 16))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.text.black40)
                    .padding(.bottom, 57)
            }
            AsyncButton(progressWidth: .infinity) {
                await buttonAction()
            } label: {
                HStack {
                    Text(buttonTitle)
                        .font(.custom("Roboto-Bold", size: 16))
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButton())
        }
        .padding(.horizontal, 24)
    }
}

extension StateView {
    static func error(title: String = "Something went wrong", description: String = "We are unable to load the content, please try to reload the page", buttonTitle: String = "Reload", buttonAction: @escaping () async -> Void) -> StateView {
        StateView(image: .error,
                  title: title,
                  description: description,
                  buttonTitle: buttonTitle) {
            await buttonAction()
        }
    }
}

#Preview {
    StateView.error {
        
    }
}
