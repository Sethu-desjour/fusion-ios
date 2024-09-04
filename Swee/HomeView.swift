import SwiftUI

struct HomeView: View {
    
    @Environment(\.bottomSheetData) private var bottomSheetData
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    BannersCarousel()
                    OfferRow()
                    ExploreView()
                    ReferalCard()
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 16)
            }
            .onWillAppear {
                bottomSheetData.wrappedValue.view = NotificationUpsell(hide: bottomSheetData.hidden)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    VStack(alignment: .leading, spacing: 0) {
                        Image("logo")
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
                    .padding(.bottom, 15)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        bottomSheetData.wrappedValue.hidden = false
                    }, label: {
                        Image("cart")
                    })
                    .buttonStyle(EmptyStyle())
                    .padding(.bottom, 15)
//                    NavigationLink(destination: CheckoutView(), label: {
//                        Image("cart")
//                    })
//                    .buttonStyle(EmptyStyle())
//                    .padding(.bottom, 15)
                }
            }
        }
    }
}


struct BannerModel {
    let title: String
    let description: String
    let buttonTitle: String
    let backgroundImage: Image
    let badgeImage: Image
}

struct BannersView: View {
    @Binding var bannerModels: [BannerModel]
    @Binding var page: Int
    @State private var contentOffset: CGFloat = 0
    
    var body: some View {
        
        ObservableScrollView(.horizontal, showIndicators: false, contentOffset: $contentOffset) {
            LazyHGrid(rows: [.init()]) {
                ForEach(bannerModels.indices, id: \.self) { index in
                    Banner(banner: bannerModels[index])
                }
            }
            .onChange(of: contentOffset) { newValue in
                var offset = newValue
                offset.negate()
                if offset < 100  {
                    page = 0
                    return
                }
                page = min(Int(offset / 210) + 1, bannerModels.count - 1)
            }
        }
        .introspect(.scrollView, on: .iOS(.v15, .v16, .v17, .v18), customize: { scrollView in
            scrollView.clipsToBounds = false
        })
    }
}

struct BannersCarousel: View {
    @State var page: Int = 0
    @State var banners: [BannerModel] = [
        .init(title: "Complete your profile to win rewards",
              description: "Free 20 mins ride for every sign up",
              buttonTitle: "Complete",
              backgroundImage: .init("banner-bg-1"),
              badgeImage: .init("badge-1")),
        .init(title: "Super hero Tuesday",
              description: "One free ride when you bring Zoomoov hero mask",
              buttonTitle: "View",
              backgroundImage: .init("banner-bg-2"),
              badgeImage: .init("badge-2")),
        .init(title: "Super hero Tuesday",
              description: "One free ride when you bring Zoomoov hero mask",
              buttonTitle: "View",
              backgroundImage: .init("banner-bg-2"),
              badgeImage: .init("badge-2")),
        .init(title: "Super hero Tuesday",
              description: "One free ride when you bring Zoomoov hero mask",
              buttonTitle: "View",
              backgroundImage: .init("banner-bg-2"),
              badgeImage: .init("badge-2")),
        .init(title: "Super hero Tuesday",
              description: "One free ride when you bring Zoomoov hero mask",
              buttonTitle: "View",
              backgroundImage: .init("banner-bg-2"),
              badgeImage: .init("badge-2"))
    ]
    
    var body: some View {
        VStack {
            BannersView(bannerModels: $banners, page: $page)
            HStack(spacing: 8, content: {
                ForEach(banners.indices, id:\.self) { index in
                    Capsule()
                        .fill(page == index ? Color(hex: "#17223B") : Color(hex: "#17223B", opacity: 0.20))
                        .frame(width: page == index ? 37 : 8, height: page == index ? 26 : 8, alignment: .center)
                        .animation(.default, value: page)
                        .overlay(
                            Text(page == index ? "\(index + 1)/\(banners.count)" : "")
                                .font(.custom("Poppins-Regular", size: 12))
                                .foregroundStyle(.white)
                        )
                }
            })
        }
        
    }
}

struct Banner: View {
    @State var banner: BannerModel
    
    var body: some View {
        ZStack {
            banner.backgroundImage
                .resizable()
                .scaledToFill()
                .frame(minWidth: 0)
                .edgesIgnoringSafeArea(.all)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            VStack {
                Text(banner.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.custom("Poppins-Bold", size: 14))
                    .foregroundColor(Color.background.white)
                    .shadow(radius: 1, y: 1)
                Text(banner.description)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.custom("Poppins-Regular", size: 12))
                    .foregroundColor(Color.background.white)
                Spacer()
                HStack(alignment: .bottom) {
                    HStack {
                        Text(banner.buttonTitle)
                            .font(.custom("Poppins-Medium", size: 10))
                            .foregroundStyle(Color.background.white)
                        Image("circled-arrow-right")
                    }
                    .padding(.bottom, 8)
                    Spacer()
                    banner.badgeImage
                }
            }
            .padding(16)
        }
        .frame(width: 210, height: 190)
    }
}


enum Vendors: CaseIterable {
    case Zoomoov
    case Jollyfield
}

extension Vendors {
    func toString() -> String {
        switch self {
        case .Jollyfield:
            return "Jollyfield"
        case .Zoomoov:
            return "Zoomoov"
        }
    }
}

struct Offer {
    let vendor: Vendors
    let image: Image // will be changed to URL
    let title: String
    let description: String
    let price: Double
    let originalPrice: Double?
    
    
}

struct OfferRowModel {
    let title: String
    let offers: [Offer]
}

struct OfferRow: View {
    @State var model: OfferRowModel = OfferRowModel(title: "Package just for you",
                                                    offers: [
                                                        .init(vendor: .Zoomoov, image: .init("offer-1"), title: "10 Zoomoov Rides 10 Zoomoov Rides", description: "Get 3 rides free", price: 50, originalPrice: 69),
                                                        .init(vendor: .Jollyfield, image: .init("offer-2"), title: "8 Hours of playtime", description: "Get 30 minutes free", price: 50, originalPrice: 69),
                                                        .init(vendor: .Zoomoov, image: .init("offer-1"), title: "10 Zoomoov Rides 10 Zoomoov Rides", description: "Get 3 rides free", price: 50, originalPrice: 69),
                                                        .init(vendor: .Jollyfield, image: .init("offer-2"), title: "8 Hours of playtime", description: "Get 30 minutes free", price: 50, originalPrice: 69),
                                                    ])
    
    var columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
    var body: some View {
        VStack {
            HStack {
                Text(model.title)
                    .textStyle(HomeRowTitleStyle())
                Spacer()
                NavigationLink(destination: OffersView()) {
                    HStack(spacing: 4) {
                        Text("See all")
                            .font(.custom("Poppins-Regular", size: 14))
                            .foregroundStyle(Color.text.black60)
                        Image("chevron-right")
                    }
                }
            }
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: [.init()], spacing: 16) {
                    ForEach(model.offers.indices, id: \.self) { index in
                        OfferCard(offer: model.offers[index])
                            .frame(width: 165)
                    }
                }
            }
            .introspect(.scrollView, on: .iOS(.v15, .v16, .v17, .v18), customize: { scrollView in
                scrollView.clipsToBounds = false
            })
        }
    }
}

struct OfferCard: View {
    @State var offer: Offer
    
    var mockProduct: ProductDetailModel = .init(id: "id", image: Image("product-detail-img"), title: "Chinese new year", subtitle: "10 Zoomoov rides + 1 Hero mask + 1 Bingo draw", vendor: .Zoomoov, locations: Array(0..<12), price: "S$ 50", originalPrice: "S$ 69",
                                                        description: """
                   Buy our **SUPERHERO** promo to get free rides from our Bingo Draws & Superhero Tuesday!

                   Best promo of 15 Rides, you get 2 **SUPERHERO** masks and 3 **Bingo Draws** (guaranteed 1 free ride minimum each draw)
                   """,
                                                        redemptionSteps: .init(title: "How to redeem", points: ["Go to the Zoomoov outlet", "Scan the QR code at the counter", "Our staff will provide you the mask if included", "Enjoy the ride"], type: .Numbered), aboutSteps: .init(title: "About package", points: ["Access to all play areas in the zone", "Expiry only after a year", "Free meals and beverages", "Other package benefit will also be listed here", "as different points"], type: .Bullet), tosText: "In no event shall Swee or its suppliers be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption) arising out In no event shall Swee or its suppliers be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption) arising out ")
    
    var body: some View {
        NavigationLink(destination: ProductDetailView(product: mockProduct)) {
            VStack {
                ZStack {
                    offer.image
                        .resizable()
                        .scaledToFill()
                        .frame(minWidth: 0)
                        .edgesIgnoringSafeArea(.all)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                .frame(maxWidth: .infinity, maxHeight: 140)
                Text(offer.title)
                    .font(.custom("Poppins-SemiBold", size: 16))
                    .foregroundStyle(Color.text.black100)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                Text(offer.description)
                    .font(.custom("Poppins-SemiBold", size: 12))
                    .foregroundStyle(Color.text.black80)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                HStack {
                    if let price = offer.originalPrice {
                        Text("SGD \(String(format: "%.2f", price))".strikethroughText())
                            .font(.custom("Poppins-Medium", size: 10))
                            .foregroundStyle(Color.text.black40)
                    }
                    Text("SGD \(String(format: "%.2f", offer.price))")
                        .font(.custom("Poppins-SemiBold", size: 12))
                    Spacer()
                }
            }
        }
        .buttonStyle(EmptyStyle())
    }
}

struct ExploreView: View {
    var body: some View {
        VStack {
            Text("Explore")
                .textStyle(HomeRowTitleStyle())
                .frame(maxWidth: .infinity, alignment: .leading)
            VStack(spacing: 8) {
                ExploreCard(vendor: .Zoomoov)
                ExploreCard(vendor: .Jollyfield)
            }
        }
    }
}

struct ExploreCard: View {
    @State var vendor: Vendors
    var body: some View {
        NavigationLink {
            MerchantPageView()
        } label: {
            ZStack {
                Image(vendor == .Jollyfield ? "explore-bg-1" : "explore-bg-2")
                    .resizable()
                    .scaledToFill()
                    .frame(minWidth: 0)
                    .edgesIgnoringSafeArea(.all)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                HStack {
                    Text(vendor.toString())
                        .font(.custom("Poppins-Bold", size: 20))
                        .foregroundStyle(.white)
                    Spacer()
                    Image("arrow-right")
                }
                .padding(.leading, 10)
                .padding(.trailing, 20)
            }
        }
    }
}

struct ReferalCard: View {
    @State private var show = false
    
    var body: some View {
        ZStack {
            Image("referal-bg")
                .resizable()
                .scaledToFill()
                .frame(minWidth: 0)
                .edgesIgnoringSafeArea(.all)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            GeometryReader { metrics in
                VStack(spacing: 8) {
                    HStack {
                        Text("Refer a friend and earn rewards ✨")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.custom("Roboto-Bold", size: 24))
                            .foregroundColor(Color.background.white)
                            .shadow(radius: 4, y: 4)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    HStack {
                        VStack {
                            Text("Enjoy a free Zoomoov ride for each friend who signs up through your referral, and your friend gets a free ride too!")
                                .frame(maxWidth: metrics.size.width * 0.60, alignment: .leading)
                                .font(.custom("Roboto-Bold", size: 12))
                                .foregroundColor(Color.background.white)
                                .lineLimit(6)
                                .fixedSize(horizontal: false, vertical: true)
                                .sheet(isPresented: $show, content: {
                                    Text("")
                                })
                            Spacer()
                            ZStack {
                                HStack {
                                    Image("share")
                                    Text("Share")
                                        .font(.custom("Roboto-Bold", size: 14))
                                        .foregroundStyle(.black)
                                }
                                .padding([.top, .bottom], 8)
                                .padding(.leading, 8)
                                .padding(.trailing, 14)
                                .background(
                                    Capsule()
                                        .fill(.white.opacity(0.65))
                                        .frame(alignment: .center))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding([.bottom], 24)
                        }
                        .frame(maxWidth: .infinity)
                        VStack() {
                            Spacer()
                            Image("referal-gift")
                        }
                        .frame(maxWidth: metrics.size.width * 0.40, alignment: .bottomTrailing)
                        .padding([.bottom], 10)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding([.top], 24)
        }
    }
}

struct NotificationUpsell: View {
    @Binding var hide: Bool
    
    private let bullets = ["Limited time only promotional alerts", "Expiry dates of coupons", "Child pick up alert messages"]
    private func bullet(_ text: String) -> some View {
        return HStack {
            Text("•")
            Text(text)
        }
        .font(.custom("Poppins-Medium", size: 12))
        .foregroundStyle(Color.text.black60)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    var body: some View {
        VStack {
            Image("alert-img")
                .padding(.bottom, 16)
            Text("Stay up to date")
                .font(.custom("Poppins-SemiBold", size: 20))
                .foregroundStyle(Color.text.black100)
                .padding(.bottom, 8)
            Text("Ensure a seamless experience by allowing notification - it’s the easiest way to keep track of your coupons")
                .font(.custom("Poppins-Medium", size: 12))
                .foregroundStyle(Color.text.black60)
                .multilineTextAlignment(.center)
                .padding(.bottom, 24)
            VStack {
                Text("If you allow notification, you’ll receive")
                    .font(.custom("Poppins-SemiBold", size: 14))
                    .foregroundStyle(Color.text.black80)
                    .padding(.bottom, 16)
                VStack {
                    ForEach(bullets, id: \.self) { text in
                        bullet(text)
                    }
                }
                .padding([.leading, .trailing], 50)
                .padding(.bottom, 38)
            }
            Button {
                
            } label: {
                Text("Allow Notification")
                    .frame(maxWidth: .infinity)
                    .font(.custom("Roboto-Bold", size: 16))
                
            }
            .buttonStyle(PrimaryButton())
            Button {
                hide.toggle()
            } label: {
                Text("Not now")
                    .frame(maxWidth: .infinity)
                    .font(.custom("Roboto-Bold", size: 16))
                    .foregroundColor(Color.text.black80)
                
            }
            .buttonStyle(OutlineButton())
        }
    }
}

struct HomeRowTitleStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.custom("Poppins-SemiBold", size: 20))
    }
}

#Preview {
    HomeView()
}
