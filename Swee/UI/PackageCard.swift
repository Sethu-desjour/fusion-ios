import SwiftUI
import SDWebImageSwiftUI

struct PackageCard: View {
    @State var package: Package
    @State private var imageLoaded = false
    
    var mockProduct: ProductDetailModel = .init(id: "id", image: Image("product-detail-img"), title: "Chinese new year", subtitle: "10 Zoomoov rides + 1 Hero mask + 1 Bingo draw", vendor: .Zoomoov, locations: Array(0..<12), price: "S$ 50", originalPrice: "S$ 69",
                                                description: """
                   Buy our **SUPERHERO** promo to get free rides from our Bingo Draws & Superhero Tuesday!
                   
                   Best promo of 15 Rides, you get 2 **SUPERHERO** masks and 3 **Bingo Draws** (guaranteed 1 free ride minimum each draw)
                   """,
                                                redemptionSteps: .init(title: "How to redeem", points: ["Go to the Zoomoov outlet", "Scan the QR code at the counter", "Our staff will provide you the mask if included", "Enjoy the ride"], type: .Numbered), aboutSteps: .init(title: "About package", points: ["Access to all play areas in the zone", "Expiry only after a year", "Free meals and beverages", "Other package benefit will also be listed here", "as different points"], type: .Bullet), tosText: "In no event shall Swee or its suppliers be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption) arising out In no event shall Swee or its suppliers be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption) arising out ")
    
    var body: some View {
        CustomNavLink(destination: ProductDetailView(product: mockProduct)) {
            VStack {
                ZStack {
                    WebImage(url: package.imageURL) { image in
                        image.resizable() // Control layout like SwiftUI.AsyncImage, you must use this modifier or the view will use the image bitmap size
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
                Text(package.description)
                    .font(.custom("Poppins-Medium", size: 12))
                    .foregroundStyle(Color.text.black60)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                HStack {
                    if let price = package.originalPrice {
                        Text("\(package.currency) \(String(format: "%.2f", price))".strikethroughText())
                            .font(.custom("Poppins-Medium", size: 10))
                            .foregroundStyle(Color.text.black40)
                    }
                    Text("\(package.currency) \(String(format: "%.2f", package.price))")
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
        Color.white
            .skeleton(with: true, shape: .rounded(.radius(12, style: .circular)))
            .frame(maxWidth: .infinity)
            .frame(height: 140)
    }
}
