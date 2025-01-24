import SwiftUI
import SDWebImageSwiftUI

struct MerchantCard: View {
    @State var merchant: Merchant
    var body: some View {
        CustomNavLink(destination: MerchantPageView(merchant: merchant), label: {
            ZStack {
                WebImage(url: merchant.backgroundImage) { image in
                    image.resizable()
                } placeholder: {
                    Color.white
                        .skeleton(with: true, shape: .rounded(.radius(12, style: .circular)))
                        .frame(maxHeight: 90)
                }
                .transition(.fade(duration: 0.5))
                .scaledToFill()
                .frame(minWidth: 0)
                .edgesIgnoringSafeArea(.all)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                HStack {
                    Text(merchant.name)
                        .font(.custom("Poppins-Bold", size: 20))
                        .foregroundStyle(.white)
                    Spacer()
                    Image("arrow-right")
                        .tint(.white)
                }
                .padding(.leading, 10)
                .padding(.trailing, 20)
            }
        })
    }
}
