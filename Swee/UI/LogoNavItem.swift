import SwiftUI

struct LogoNavItem: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Image("logo")
                .resizable()
                .frame(width: 60, height: 18)
            Button {
            } label: {
                HStack(spacing: 4) {
                    Image("location")
                    Text("Singapore")
                        .font(.custom("Poppins-Regular", size: 14))
                        .foregroundStyle(Color.text.black80)
                }
            }
        }
    }
}

#Preview {
    LogoNavItem()
}
