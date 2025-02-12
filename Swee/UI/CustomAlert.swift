import SwiftUI

struct CustomAlert: View {
    struct Data: Equatable {
        let title: String
        let message: String
        let buttonTitle: String
        let cancelTitle: String
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
                    Text(data.title.i18n)
                        .font(.custom("Poppins-SemiBold", size: 18))
                        .foregroundStyle(Color.text.black100)
                        .padding()
                    
                    Text(data.message.i18n)
                        .font(.custom("Poppins-Regular", size: 14))
                        .foregroundStyle(Color.text.black60)
                        .multilineTextAlignment(.center)
                    
                    AsyncButton(progressWidth: .infinity) {
                        try? await data.action.closure()
                        close()
                    } label: {
                        Text(data.buttonTitle.i18n)
                            .font(.custom("Poppins-Bold", size: 16))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .buttonStyle(PrimaryButton(backgroundColor: .error))
                    Button {
                        close()
                    } label: {
                        Text(data.cancelTitle.i18n)
                            .font(.custom("Poppins-SemiBold", size: 16))
                            .foregroundStyle(Color.text.black60)
                    }
                    .padding(.bottom, 24)
                }
                .fixedSize(horizontal: false, vertical: true)
                .padding()
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .shadow(radius: 20)
                .padding(30)
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
