import SwiftUI

struct OffersView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.tabIsShown) private var tabIsShown
    
    @State var model: PackageCarouselModel = PackageCarouselModel(title: "Package just for you",
                                                    offers: [
                                                        .init(merchant: "Zoomoov", image: .init("offer-1"), title: "10 Zoomoov Rides", description: "Get 3 rides free", price: 50, originalPrice: 69),
                                                        .init(merchant: "Jollyfield", image: .init("offer-2"), title: "8 Hours of playtime", description: "Get 30 minutes free", price: 50, originalPrice: 69),
                                                        .init(merchant: "Jollyfield", image: .init("offer-2"), title: "8 Hours of playtime", description: "Get 30 minutes free", price: 50, originalPrice: 69),
                                                        .init(merchant: "Jollyfield", image: .init("offer-2"), title: "8 Hours of playtime", description: "Get 30 minutes free", price: 50, originalPrice: 69),
                                                        .init(merchant: "Jollyfield", image: .init("offer-2"), title: "8 Hours of playtime", description: "Get 30 minutes free", price: 50, originalPrice: 69),
                                                        .init(merchant: "Jollyfield", image: .init("offer-1"), title: "10 Zoomoov Rides", description: "Get 3 rides free", price: 50, originalPrice: 69),
                                                        .init(merchant: "Jollyfield", image: .init("offer-2"), title: "8 Hours of playtime", description: "Get 30 minutes free", price: 50, originalPrice: 69),
                                                        
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
                ForEach(model.offers.indices, id: \.self) { index in
                    PackageCard(offer: model.offers[index])
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
