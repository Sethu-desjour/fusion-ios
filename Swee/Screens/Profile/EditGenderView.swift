import SwiftUI

struct EditGenderView: View {
    @EnvironmentObject private var api: API
    @Environment(\.dismiss) private var dismiss
    @Environment(\.tabIsShown) private var tabIsShown
    @State var gender: User.Gender?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Gender")
                .font(.custom("Poppins-Medium", size: 16))
                .foregroundStyle(Color.text.black80)
            Menu {
                ForEach(User.Gender.allCases, id: \.rawValue) { gender in
                    Button {
                        self.gender = gender
                    } label: {
                        Text(gender.toString)
                    }
                }
            } label: {
                HStack {
                    Text(gender != nil ? "\(gender!.toString)" : "Select")
                        .font(.custom("Poppins-Medium", size: gender != nil ? 16 : 14))
                        .foregroundStyle(gender != nil ? Color.text.black80 : Color.text.black60)
                    Spacer()
                    Image("chevron-down")
                        .foregroundStyle(Color.text.black60)
                }
                .padding(.vertical, 15)
                .padding(.leading, 20)
                .padding(.trailing, 12)
                .background(RoundedRectangle(cornerRadius: 8)
                    .stroke(style: .init(lineWidth: 1))
                    .foregroundStyle(Color(hex: "#C8C8C8"))
                )
            }
            Spacer()
            AsyncButton(progressWidth: .infinity) {
                do {
                    let _ = try await api.update(gender: gender)
                    dismiss()
                } catch {
                    self.gender = api.user?.gender ?? gender
                }
            } label: {
                Text("Update")
                    .frame(maxWidth: .infinity)
                    .font(.custom("Roboto-Bold", size: 16))
            }
            .disabled(gender == nil)
            .buttonStyle(PrimaryButton())
        }
        .padding()
        .customNavigationTitle("Gender")
        .onAppear(perform: {
            tabIsShown.wrappedValue = false
        })
    }
}

#Preview {
    EditGenderView(gender: nil)
}
