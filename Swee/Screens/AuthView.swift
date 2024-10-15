import SwiftUI
import AuthenticationServices
import FirebaseAuth

struct AuthView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var api: API
    @EnvironmentObject private var appRootManager: AppRootManager
    
    @State private var phone: String = ""
    @State private var code: String = "🇸🇬 +65"
    @FocusState var isPhoneFocused: Bool
    @State private var goToOTP: Bool = false
    @State private var verificationID: String = ""
    @State private var loading = false
    @State private var errorMessage: String?
    
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
    
    private var phoneBorderColor: Color {
        if errorMessage != nil {
            return .red
        }
        
        return phoneFieldActive ? Color.text.black100 : Color(hex: "#E7EAEB")
    }
    
    var body: some View {
        ZStack {
            NavigationView {
                VStack {
                    NavigationLink(isActive: $goToOTP) {
                        OtpView(countryCode:"+65", phoneNumber: phone, verificationID: verificationID)
                    } label: {
                        
                    }
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
                            .foregroundStyle(errorMessage != nil ? .red : Color.text.black100)
                        HStack {
                            TextField("", text: $code) {
                                UIApplication.shared.endEditing()
                            }
                            .padding([.top, .bottom], 17)
                            .padding([.leading, .trailing], 10)
                            .frame(width: 82)
                            .disabled(true)
                            .focused($isPhoneFocused)
                            .font(.custom("Poppins-Regular", size: 14))
                            .overlay(RoundedRectangle(cornerRadius: 12)
                                .stroke(codeFieldActive ? Color.text.black100 : Color(hex: "#E7EAEB"),
                                        lineWidth: 1))
                            TextField("Phone number", text: $phone) {
                                UIApplication.shared.endEditing()
                            }
                            .keyboardType(.numberPad)
                            .padding([.top, .bottom], 17)
                            .onChange(of: phone, perform: { newValue in
                                errorMessage = nil
                            })
                            .padding([.leading, .trailing], 14)
                            .focused($isPhoneFocused)
                            .foregroundStyle(errorMessage != nil ? .red : Color.text.black100)
                            .font(.custom("Poppins-Regular", size: 14))
                            .overlay(RoundedRectangle(cornerRadius: 12)
                                .stroke(phoneBorderColor,
                                        lineWidth: 1))
                            .toolbar {
                                ToolbarItemGroup(placement: .keyboard) {
                                    HStack {
                                        Spacer()
                                        Button("Done") {
                                            isPhoneFocused = false
                                        }
                                        .foregroundStyle(Color.primary.brand)
                                        .font(.custom("Poppins-Bold", size: 16))
                                    }
                                }
                            }
                        }
                        if errorMessage != nil {
                            Text(errorMessage)
                                .font(.custom("Poppins-Regular", size: 12))
                                .foregroundStyle(.red)
                        }
                    }
                    Spacer()
                    Spacer()
                    AsyncButton(progressWidth: .infinity) {
                        // @todo validate and navigate next
                        let result = await Authentication().verify(phone: "+65" + phone)
                        switch result {
                        case .success(let verificationId):
                            UserDefaults.standard.set(verificationId, forKey: Keys.authVerificationID)
                            self.verificationID = verificationId
                            goToOTP = true
                            print("verificationID ====", verificationId)
                        case .failure(let error):
                            if case .incorrectPhone = error {
                                errorMessage = "Check your phone number"
                            } else {
                                errorMessage = "Something went wrong. Please try again"
                            }
                            print(error.localizedDescription)
                        }
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
                            loading = true
                            Task {
                                do {
                                    let token = try await Authentication().appleSignIn()
                                    try await api.signIn(with: token)
                                    await MainActor.run {
                                        loading = false
                                        appRootManager.currentRoot = .home
                                    }
                                } catch {
                                    await MainActor.run {
                                        loading = false
                                    }
                                    print("AppleAuthorization failed: \(error)")
                                    // @todo handle error
                                }
                            }
                        } label: {
                            HStack {
                                Image("apple")
                                Text("Apple")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(SocialButton())
                        Button {
                            loading = true
                            Task {
                                do {
                                    let token = try await Authentication().googleSignIn()
                                    try await api.signIn(with: token)
                                    await MainActor.run {
                                        loading = false
                                        appRootManager.currentRoot = .home
                                    }
                                } catch(let error) {
                                    await MainActor.run {
                                        loading = false
                                    }
                                    print("google auth error ====", error)
                                    // @todo handle error
                                }
                            }
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
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
            if loading {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(Color.white)
            }
        }
        .animation(.default, value: loading)
    }
}

#Preview {
    AuthView()
        .environmentObject(AppRootManager())
}
