import SwiftUI

struct OffersView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.tabIsShown) private var tabIsShown
    
    @State var model: PackageCarouselModel = PackageCarouselModel(title: "Package just for you",
                                                    packages: [
                                                        .init(merchant: "Zoomoov", image: .init("offer-1"), imageURL: URL(string:"https://i.ibb.co/7zZQ2Fs/offer-2-3x.png"), title: "10 Zoomoov Rides", description: "Get 3 rides free", price: 50, originalPrice: 69, currency: "SGD"),
                                                        .init(merchant: "Jollyfield", image: .init("offer-2"), imageURL: URL(string:"https://i.ibb.co/7zZQ2Fs/offer-2-3x.png"), title: "8 Hours of playtime", description: "Get 30 minutes free", price: 50, originalPrice: 69, currency: "SGD"),
                                                        .init(merchant: "Jollyfield", image: .init("offer-2"), imageURL: URL(string:"https://i.ibb.co/7zZQ2Fs/offer-2-3x.png"), title: "8 Hours of playtime", description: "Get 30 minutes free", price: 50, originalPrice: 69, currency: "SGD"),
                                                        .init(merchant: "Jollyfield", image: .init("offer-2"), imageURL: URL(string:"https://i.ibb.co/7zZQ2Fs/offer-2-3x.png"), title: "8 Hours of playtime", description: "Get 30 minutes free", price: 50, originalPrice: 69, currency: "SGD"),
                                                        .init(merchant: "Jollyfield", image: .init("offer-2"), imageURL: URL(string:"https://i.ibb.co/7zZQ2Fs/offer-2-3x.png"), title: "8 Hours of playtime", description: "Get 30 minutes free", price: 50, originalPrice: 69, currency: "SGD"),
                                                        .init(merchant: "Jollyfield", image: .init("offer-1"), imageURL: URL(string:"https://i.ibb.co/7zZQ2Fs/offer-2-3x.png"), title: "10 Zoomoov Rides", description: "Get 3 rides free", price: 50, originalPrice: 69, currency: "SGD"),
                                                        .init(merchant: "Jollyfield", image: .init("offer-2"), imageURL: URL(string:"https://i.ibb.co/7zZQ2Fs/offer-2-3x.png"), title: "8 Hours of playtime", description: "Get 30 minutes free", price: 50, originalPrice: 69, currency: "SGD"),
                                                        
                                                    ])
    
    var columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
    var body: some View {
        //            VStack(spacing: 0) {
        //                Divider()
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(model.packages.indices, id: \.self) { index in
                    PackageCard(package: model.packages[index])
                }
            }
            .padding([.leading, .trailing, .top], 16)
        }
        .customNavigationTitle("Packages just for you")
        .customNavTrailingItem {
            Button {
                // handle tap
            } label: {
                Image("cart")
            }
            .buttonStyle(EmptyStyle())
        }
        .onWillAppear({
            tabIsShown.wrappedValue = false
        })
    }
}

#Preview {
    OffersView()
}
