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
        var string = text.underline()
        string.link = URL(string: "https://google.com")
        
        return string
    }
    
    var body: some View {
        NavigationView {
            VStack {
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
                }
                Spacer()
                Spacer()
                Button {
                    // validate and navigate next
                } label: {
                    Text("Verify")
                        .frame(maxWidth: .infinity)
                        .font(.custom("Roboto-Bold", size: 16))
                    
                }
                .disabled(phone.isEmpty)
                .buttonStyle(PrimaryButton())
                Spacer()
                Spacer()
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
                        NavigationLink(destination: OtpView()) {
                            HStack {
                                Image("apple")
                                Text("Apple")
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(SocialButton())
                    Button {
                        
                    } label: {
                        NavigationLink(destination: OtpView()) {
                            HStack {
                                Image("google")
                                Text("Google")
                            }
                            .frame(maxWidth: .infinity)
                        }
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
        .navigationBarTitle("")
        .navigationBarHidden(true)
    }
}

#Preview {
    AuthView()
}
