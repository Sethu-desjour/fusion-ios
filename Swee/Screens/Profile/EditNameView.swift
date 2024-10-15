import SwiftUI

struct EditNameView: View {
    @EnvironmentObject private var api: API
    @Environment(\.dismiss) private var dismiss
    @State var name: String
    @FocusState private var isKeyboardShowing: Bool
    private var nameFieldActive: Bool {
        return name != "" || isKeyboardShowing
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Full name")
                .font(.custom("Poppins-Medium", size: 16))
                .foregroundStyle(Color.text.black80)
            TextField("Enter your full name", text: $name)
                .padding([.top, .bottom], 17)
                .padding([.leading, .trailing], 14)
                .focused($isKeyboardShowing)
                .font(.custom("Poppins-Regular", size: 16))
                .submitLabel(.done)
                .overlay(RoundedRectangle(cornerRadius: 12)
                    .stroke(nameFieldActive ? Color.primary.brand : Color(hex: "#E7EAEB"),
                            lineWidth: nameFieldActive ? 2 : 1))
            Spacer()
            AsyncButton(progressWidth: .infinity) {
                do {
                    let _ = try await api.update(name: name)
                    dismiss()
                } catch {
                    self.name = api.user?.name ?? name
                }
            } label: {
                Text("Update")
                    .frame(maxWidth: .infinity)
                    .font(.custom("Roboto-Bold", size: 16))
            }
            .disabled(name.trimmingCharacters(in: .whitespaces) == "")
            .buttonStyle(PrimaryButton())
        }
        .padding()
        .customNavigationTitle("Name")
    }
}

#Preview {
    CustomNavView {
        EditNameView(name: "Darth Vader")
    }
}
