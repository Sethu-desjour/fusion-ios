import SwiftUI

struct CustomNavBarView: View {
    @Environment(\.dismiss) private var dismiss
    
    var showBackButton: Bool = true
    var leadingItem: EquatableViewContainer
    var trailingItem: EquatableViewContainer
    var title: String = "Title" // ""
    
    
    private var backButton: some View {
        Button {
            dismiss()
        } label: {
            Image("back")
        }
    }
    
    var body: some View {
        ZStack {
            Text(title)
                .font(.custom("Poppins-Bold", size: 18))
                .foregroundStyle(.black)
            HStack {
                if showBackButton {
                    backButton
                } else {
                    leadingItem.view
                }
                Spacer()
                trailingItem.view

            }
        }
        .padding([.horizontal, .bottom], 16)
        .tint(Color.text.black100)
        .frame(maxWidth: .infinity)
        .overlay(Rectangle().frame(width: nil, height: 1, alignment: .bottom).foregroundColor(Color.text.black10), alignment: .bottom)
//        .background(.red)
    }
}

#Preview {
    VStack {
        CustomNavBarView(showBackButton: true, leadingItem: EquatableViewContainer(view: AnyView(VStack(alignment: .leading) {
            Image("logo")
            HStack {
                Image("location")
                Text("Singapore")
            }
        })), trailingItem: EquatableViewContainer(view: AnyView(Text("Add child"))), title: "Zoomoov")
        Spacer()
    }
}
