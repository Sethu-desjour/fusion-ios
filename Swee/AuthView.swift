import SwiftUI

struct AuthView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var phone: String = ""
    @State private var code: String = "🇸🇬 +65"
    @FocusState var isPhoneFocused: Bool
    private var phoneFieldActive: Bool {
        return phone != "" && isPhoneFocused
    }
    private var codeFieldActive: Bool {
        return phone.count == 8
    }
    
    private var tosText: (String) -> AttributedString =  { text in
        var string = AttributedString(text)
        string.font = .custom("Poppins-Regular", size: 14)
        string.foregroundColor = Color.text.black60
        
        return string
    }
    
    private var tosLink: (String) -> AttributedString =  { text in
        var string = AttributedString(text)
        string.font = .custom("Poppins-Medium", size: 14)
        string.foregroundColor = Color.text.black80
        string.link = URL(string: "https://google.com")
        string.underlineStyle = Text.LineStyle(pattern: .solid, color: Color.text.black80)
        
        return string
    }
    
    var body: some View {
        VStack {
            //            Spacer()
            Spacer()
            Text("Enter your phone number")
                .font(.custom("Poppins-SemiBold", size: 24))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 8)
            Text("Logging in with an unregistered phone number will automatically create a new Swee account.")
                .font(.custom("Poppins-Regular", size: 14))
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(Color.text.black60)
                .padding(.bottom, 32)
            VStack {
                Text("Your Phone number")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.custom("Poppins-Medium", size: 16))
                HStack {
                    TextField("", text: $code) {
                        // Called when the user tap the return button
                        // see `onCommit` on TextField initializer.
                        UIApplication.shared.endEditing()
                    }
                    .padding([.top, .bottom], 17)
                    .padding([.leading, .trailing], 10)
                    .frame(width: 82)
                    .focused($isPhoneFocused)
                    .font(.custom("Poppins-Regular", size: 14))
                    .overlay(RoundedRectangle(cornerRadius: 12)
                        .stroke(codeFieldActive ? Color.primary.brand : Color(hex: "#E7EAEB"),
                                lineWidth: codeFieldActive ? 2 : 1))
                    TextField("Phone number", text: $phone) {
                        // Called when the user tap the return button
                        // see `onCommit` on TextField initializer.
                        UIApplication.shared.endEditing()
                    }
                    .padding([.top, .bottom], 17)
                    .padding([.leading, .trailing], 14)
                    .focused($isPhoneFocused)
                    .font(.custom("Poppins-Regular", size: 14))
                    .overlay(RoundedRectangle(cornerRadius: 12)
                        .stroke(phoneFieldActive ? Color.primary.brand : Color(hex: "#E7EAEB"),
                                lineWidth: phoneFieldActive ? 2 : 1))
                }
                //                .textFieldStyle(OutlinedTextFieldStyle())
            }
            Spacer()
            Spacer()
            Button {
                // validate and navigate next
                print("PRESSED ====")
            } label: {
                Text("Verify")
                    .frame(maxWidth: .infinity)
                    .font(.custom("Roboto-Bold", size: 16))
                
            }
            .disabled(phone.isEmpty)
            .buttonStyle(PrimaryButton())
            Spacer()
            Spacer()
            //                .padding([.top, .bottom], 60)
            
            HStack {
                Rectangle()
                    .fill(Color.text.black20)
                    .frame(height: 1)
                Text("Or continue with")
                    .foregroundStyle(Color.black.opacity(0.7))
                    .font(.custom("Poppins-Regular", size: 14))
                    .layoutPriority(1)
                Rectangle()
                    .fill(Color.text.black20)
                    .frame(height: 1)
            }
            HStack(spacing: 12) {
                Button {
                    
                } label: {
                    HStack {
                        Image("apple")
                        Text("Apple")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(SocialButton())
                Button {
                    
                } label: {
                    HStack {
                        Image("google")
                        Text("Google")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(SocialButton())
            }
            Spacer()
            Spacer()
            Spacer()
            Spacer()
            HStack {
                Text(tosText("By continuing, you accept Swee’s \n") + tosLink("Terms and Condition") + tosText(" and ") + tosLink("Privacy Policy"))
            }
            .multilineTextAlignment(.center)
            
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
        }
    }
}

struct OutlinedTextFieldStyle: TextFieldStyle {
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding([.leading, .trailing], 14)
            .padding([.top, .bottom], 17)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.primary.brand, lineWidth: 2)
            )
    }
}

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
            .background(isEnabled ? 
                        AnyShapeStyle(LinearGradient(gradient: .init(colors: Color.gradient.primary),
                                                                 startPoint: .topLeading,
                                                                 endPoint: .bottomTrailing)) 
                        : AnyShapeStyle(Color.primary.brand.opacity(0.5)))
            .foregroundStyle(.white)
            .clipShape(Capsule())
            .overlay(RoundedRectangle(cornerRadius: 24)
                .stroke(Color.primary.brand,
                        lineWidth: isEnabled ? 1 : 0)
            )
    }
}


extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    AuthView()
}
