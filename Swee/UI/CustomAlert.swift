import SwiftUI

struct CustomAlert: View {
    struct Data: Equatable {
        struct Style: Equatable {
            var width: CGFloat = .infinity
            var titleFont: Font = .custom("Poppins-SemiBold", size: 18)
            var messageFont: Font = .custom("Poppins-Regular", size: 14)
            var mainButtonColor: Color = .red
        }
        let title: String
        let message: String
        let buttonTitle: String
        var cancelTitle: String? = nil
//        let showConfetti: Bool
        var style: Style = .init()
        let action: EquatableAsyncVoidClosure
    }
    
    @Binding var isActive: Bool
    var data: Data
    
    var body: some View {
        ZStack {
            if isActive {
                Color(.black)
                    .opacity(0.5)
                    .onTapGesture {
                        close()
                    }
                    .transition(.opacity)
                VStack {
                    Text(data.title)
                        .font(data.style.titleFont)
                        .foregroundStyle(Color.text.black100)
                        .padding()
                    
                    Text(data.message)
                        .font(data.style.messageFont)
                        .foregroundStyle(Color.text.black60)
                        .multilineTextAlignment(.center)
                    
                    AsyncButton(progressWidth: .infinity) {
                        try? await data.action.closure()
                        close()
                    } label: {
                        Text(data.buttonTitle)
                            .font(.custom("Poppins-Bold", size: 16))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .buttonStyle(PrimaryButton(backgroundColor: data.style.mainButtonColor))
                    if let cancelTitle = data.cancelTitle {
                        Button {
                            close()
                        } label: {
                            Text(cancelTitle)
                                .font(.custom("Poppins-SemiBold", size: 16))
                                .foregroundStyle(Color.text.black60)
                        }
                        .padding(.bottom, 24)
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
                .padding()
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .shadow(radius: 20)
                .padding(30)
//                .frame(width: data.style.width)
                .transition(.flipFromBottom.combined(with: .opacity))
            }
        }
        .animation(.spring(duration: 0.2), value: isActive)
        .ignoresSafeArea()
    }
    
    func close() {
        withAnimation(.spring()) {
            isActive = false
        }
    }
}

struct CustomAlert_Previews: PreviewProvider {
    static var previews: some View {
        CustomAlert(isActive: .constant(false), data: .init(title: "Delete?",
                                message: "This will delete all your data",
                                buttonTitle: "Delete",
                                cancelTitle: "Keep my account",
                                action: .init(closure: {}))
        )
    }
}
