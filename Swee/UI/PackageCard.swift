import SwiftUI
import SDWebImageSwiftUI

struct PackageCard: View {
    @State var package: Package
    @State private var imageLoaded = false
        
    var body: some View {
        CustomNavLink(destination: PackageDetailView(package: package)) {
            VStack {
                ZStack {
                    WebImage(url: package.imageURL) { image in
                        image.resizable()
                    } placeholder: {
                        Color.white
                            .skeleton(with: true, shape: .rounded(.radius(4, style: .circular)))
                            .frame(height: 140)
                    }
                    .transition(.fade(duration: 0.5))
                    .scaledToFill()
                    .frame(minWidth: 0)
                    .edgesIgnoringSafeArea(.all)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                .frame(maxWidth: .infinity, maxHeight: 140)
                Text(package.title)
                    .font(.custom("Poppins-SemiBold", size: 16))
                    .foregroundStyle(Color.text.black100)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                Text(package.merchant)
                    .font(.custom("Poppins-Medium", size: 12))
                    .foregroundStyle(Color.text.black60)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                Text(package.summary)
                    .font(.custom("Poppins-Medium", size: 12))
                    .foregroundStyle(Color.text.black60)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                HStack {
                    if let originalPrice = package.originalPriceString {
                        Text(originalPrice.strikethroughText())
                            .font(.custom("Poppins-Medium", size: 10))
                            .foregroundStyle(Color.text.black40)
                    }
                    Text(package.priceString)
                        .font(.custom("Poppins-SemiBold", size: 12))
                    Spacer()
                }
            }
        }
        .buttonStyle(EmptyStyle())
    }
}

extension PackageCard: Skeletonable {
    static var skeleton: any View {
        VStack(alignment: .leading) {
            Color.white
                .skeleton(with: true, shape: .rounded(.radius(12, style: .circular)))
                .frame(maxWidth: .infinity)
                .frame(height: 140)
            Text("")
                .skeleton(with: true, shape: .rounded(.radius(12, style: .circular)))
                .frame(maxWidth: 140)
                .frame(height: 15)
            Text("")
                .skeleton(with: true, shape: .rounded(.radius(12, style: .circular)))
                .frame(maxWidth: 140)
                .frame(height: 10)
            Text("")
                .skeleton(with: true, shape: .rounded(.radius(12, style: .circular)))
                .frame(maxWidth: 80)
                .frame(height: 10)
        }
    }
}

#Preview {
    PackageCard.skeleton.equatable.view
        .frame(maxWidth: 160)
}
