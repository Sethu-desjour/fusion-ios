import SwiftUI

struct OtpView: View {
    @Environment(\.dismiss) private var dismiss
    @State var otpText: String = ""
    @FocusState private var isKeyboardShowing: Bool
    @State var timeRemaining = 0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var showError: Bool = false
    
    var body: some View {
        VStack {
            Spacer()
            Text("Enter your OTP")
                .font(.custom("Poppins-SemiBold", size: 24))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 8)
            Text("We’ve sent an SMS with an OTP to your phone +65-86445476")
                .font(.custom("Poppins-Regular", size: 14))
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(Color.text.black60)
                .padding(.bottom, 32)
            VStack {
                Text("Enter OTP")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.custom("Poppins-Medium", size: 16))
                
                HStack(spacing: 15) {
                    ForEach(0..<5, id: \.self) { index in
                        OTPTextBox(otpText: $otpText,
                                   showError: $showError,
                                   isKeyboardShowing: $isKeyboardShowing,
                                   index: index)
                    }
                }
                .background {
                    TextField("", text: $otpText.limit(5))
                        .keyboardType(.numberPad)
                        .textContentType(.oneTimeCode)
                        .frame(width: 1, height: 1)
                        .opacity(0.001)
                        .blendMode(.screen)
                        .focused($isKeyboardShowing)
                        .onChange(of: otpText) { newValue in
                            showError = false
                        }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    isKeyboardShowing.toggle()
                }
            }
            Text(showError ? "Wrong code, please try again" : "")
                .font(.custom("Poppins-Regular", size: 16))
                .foregroundStyle(Color.secondary.brand)
                .padding([.bottom, .top], 10)
                .frame(height: 40)
            Button {
                // validate and navigate next
                showError = true
            } label: {
                Text("Login")
                    .frame(maxWidth: .infinity)
                    .font(.custom("Roboto-Bold", size: 16))
                
            }
            .disabled(otpText.count != 5)
            .buttonStyle(PrimaryButton())
            Spacer()
            Spacer()
            Spacer()
        }
        .padding()
        .ignoresSafeArea(.keyboard)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image("back_auth", bundle: .main)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    if timeRemaining == 0 {
                        timeRemaining = 20
                    }
                } label: {
                    if timeRemaining == 0 {
                        Text("Resend OTP")
                            .frame(maxWidth: .infinity)
                            .font(.custom("Poppins-Bold", size: 16))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: Color.gradient.primary,
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    } else {
                        Text("Resend OTP again in 0:\(timeRemaining >= 10 ? "" : "0")\(timeRemaining)")
                            .frame(maxWidth: .infinity)
                            .font(.custom("Poppins-Bold", size: 16))
                            .foregroundStyle(Color.text.black60)
                            .onReceive(timer, perform: { _ in
                                if timeRemaining > 0 {
                                    timeRemaining -= 1
                                }
                            })
                    }
                    
                }
            }
        }
    }
}

struct OTPTextBox: View {
    @Binding var otpText: String
    @Binding var showError: Bool
    var isKeyboardShowing: FocusState<Bool>.Binding
    @State var index: Int
    @State var boxText: String = ""
    
    var text: String {
        if otpText.count > index {
            let startIndex = otpText.startIndex
            let charIndex = otpText.index(startIndex, offsetBy: index)
            let charToString = String(otpText[charIndex])
            return charToString
        } else {
            return " "
        }
    }
    
    var isActive: Bool {
        return ((isKeyboardShowing.wrappedValue && otpText.count == index) || otpText.count > index)
    }
    
    var borderColor: Color {
        if otpText.count == 5 && showError {
            return Color.secondary.brand
        }
        return isActive ? Color.primary.brand : .text.black20
    }
    
    var body: some View {
        ZStack {
            TextField("", text: $boxText)
                .onChange(of: otpText) { newValue in
                    boxText = text
                }
                .allowsHitTesting(false)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: 70)
        .font(.custom("Poppins-SemiBold", size: 24))
        .background {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .stroke(borderColor, lineWidth: 1)
                .animation(.easeInOut, value: isActive)
        }
    }
}

extension Binding where Value == String {
    func limit(_ length: Int) -> Self {
        if self.wrappedValue.count > length {
            DispatchQueue.main.async {
                self.wrappedValue = String(self.wrappedValue.prefix(length))
            }
        }
        return self
    }
}

#Preview {
    OtpView()
}
