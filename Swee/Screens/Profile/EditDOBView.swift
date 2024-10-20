import SwiftUI

struct EditDOBView: View {
    @EnvironmentObject private var api: API
    @Environment(\.dismiss) private var dismiss
    @Environment(\.tabIsShown) private var tabIsShown
    @State var dob: Date?
    @State private var editedDOB: Date = .now
    @State private var showError = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Date of birth")
                .font(.custom("Poppins-Medium", size: 16))
                .foregroundStyle(Color.text.black80)
            HStack {
                Text(dob != nil ? "\(dob!.formatted(date: .numeric, time: .omitted))" : "DD/MM/YYYY")
                    .font(.custom("Poppins-Medium", size: dob != nil ? 16 : 14))
                    .foregroundStyle(dob != nil ? Color.text.black80 : Color.text.black60)
                    .overlay {
                        DatePicker(
                            "",
                            selection: $editedDOB,
                            in: ...Date(),
                            displayedComponents: [.date]
                        )
                        .blendMode(.destinationOver)
                    }
                Spacer()
                Image("calendar-empty")
                    .foregroundStyle(Color.text.black60)
            }
            .padding(.vertical, 15)
            .padding(.leading, 20)
            .padding(.trailing, 12)
            .background(RoundedRectangle(cornerRadius: 8)
                .stroke(style: .init(lineWidth: 1))
                .foregroundStyle(Color(hex: "#C8C8C8"))
            )
            .onChange(of: editedDOB, perform: { newValue in
                dob = editedDOB
            })
            if showError {
                Text("Check your email format")
                    .font(.custom("Poppins-Regular", size: 12))
                    .foregroundStyle(.red)
            }
            Spacer()
            AsyncButton(progressWidth: .infinity) {
                // @todo add validation logic?
                do {
                    let _ = try await api.update(dob: dob)
                    dismiss()
                } catch {
                    self.dob = api.user?.dob ?? dob
                }
            } label: {
                Text("Update")
                    .frame(maxWidth: .infinity)
                    .font(.custom("Roboto-Bold", size: 16))
            }
            .disabled(dob == nil)
            .buttonStyle(PrimaryButton())
        }
        .padding()
        .customNavigationTitle("Date of birth")
        .onAppear(perform: {
            tabIsShown.wrappedValue = false
        })
    }
}

#Preview {
    EditDOBView(dob: .now)
}
