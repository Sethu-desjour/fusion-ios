import SwiftUI

struct CompleteProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @State var fullName: String = ""
    @FocusState private var isKeyboardShowing: Bool
    
    @EnvironmentObject private var appRootManager: AppRootManager
    @EnvironmentObject var api: API
    
    private var nameFieldActive: Bool {
        return fullName != "" || isKeyboardShowing
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Text("Almost there!")
                    .font(.custom("Poppins-SemiBold", size: 24))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 8)
                Text("Please provide your name so we can personalise your experience")
                    .font(.custom("Poppins-Regular", size: 14))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(Color.text.black60)
                    .padding(.bottom, 32)
                VStack {
                    Text("Full name")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.custom("Poppins-Medium", size: 16))
                    TextField("Enter your full name", text: $fullName) {
                        UIApplication.shared.endEditing()
                    }
                    .padding([.top, .bottom], 17)
                    .padding([.leading, .trailing], 14)
                    .focused($isKeyboardShowing)
                    .font(.custom("Poppins-Regular", size: 14))
                    .submitLabel(.done)
                    .overlay(RoundedRectangle(cornerRadius: 12)
                        .stroke(nameFieldActive ? Color.primary.brand : Color(hex: "#E7EAEB"),
                                lineWidth: nameFieldActive ? 2 : 1))
                }
                .padding([.bottom], 70)
                AsyncButton(progressWidth: .infinity) {
                    // validate and navigate next
                    do {
                        try await api.completeUser(with: fullName.trimmingCharacters(in: .whitespaces))
                        appRootManager.currentRoot = .home
                    } catch(let error) {
                        print("complete profile error =====", error)
                        // @todo handle error case
                    }
                } label: {
                    Text("Complete")
                        .frame(maxWidth: .infinity)
                        .font(.custom("Roboto-Bold", size: 16))
                }
                .disabled(fullName.trimmingCharacters(in: .whitespaces) == "")
                .buttonStyle(PrimaryButton())
                Spacer()
                Spacer()
                Spacer()
            }
            .padding()
            .ignoresSafeArea(.keyboard)
            .navigationBarBackButtonHidden(true)
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
    }
}

#Preview {
    CompleteProfileView()
        .environmentObject(AppRootManager())
        .environmentObject(API())
}
