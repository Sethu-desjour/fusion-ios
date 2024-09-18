import SwiftUI
import SDWebImageSwiftUI
import SDWebImage
import SkeletonUI

struct HomeView: View {
    
    @EnvironmentObject private var api: API
    @StateObject private var viewModel = HomeViewModel()
    
//    @Environment(\.bottomSheetData) private var bottomSheetData
    @Environment(\.tabIsShown) private var tabIsShown
    @State private var hideBottomSheet: Bool = true
    
    func section(at index: Int) -> any View {
        let section = viewModel.sections[index]
        switch section.content {
        case .bannerCarousel(let banners):
            return BannersCarousel(banners: banners)
        case .packages(let packages):
            return PackagesCarousel(model: PackageCarouselModel(title: section.title ?? "", packages: packages))
        case .merchants(let merchants):
            return MerchantList(model: .init(title: section.title ?? "", merchants: merchants))
        case .bannerStatic(let banners):
            if banners.isEmpty {
                return VStack {}
            }
            return ReferalCard(banner: banners[0])
        }
    }
    
    var body: some View {
        CustomNavView {
            VStack {
                if viewModel.sections.isEmpty {
                    ZStack {
                        ProgressView()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack {
                            ForEach(viewModel.sections.indices, id: \.self) { index in
                                section(at: index).equatable.view
                            }
                        }
                        .padding(.vertical, 20)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 80)
                    }
                    .ignoresSafeArea()
                }
            }
            .onChange(of: hideBottomSheet, perform: { newValue in
                tabIsShown.wrappedValue = hideBottomSheet
            })
            .onAppear(perform: {
                viewModel.api = api
                viewModel.fetch()
                tabIsShown.wrappedValue = true
//                Uncomment to keep the images loading indefinately
//                SDImageCachesManager.shared.caches = []
//                SDWebImageManager.defaultImageCache = SDImageCachesManager.shared
            })
            .customNavigationBackButtonHidden(true)
            .customNavLeadingItem {
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
            }
            .customNavTrailingItem {
                Button(action: {
//                    bottomSheetData.wrappedValue.hidden.wrappedValue = false
                    hideBottomSheet = false
                }, label: {
                    Image("cart")
                })
                .buttonStyle(EmptyStyle())
            }
            .customBottomSheet(hidden: $hideBottomSheet) {
                NotificationUpsell(hide: $hideBottomSheet)
            }
        }
        .introspect(.navigationView(style: .stack), on: .iOS(.v15, .v16, .v17, .v18), customize: { navBar in
            navBar.tabBarController?.tabBar.isHidden = true
        })
    }
}


struct Banner {
    enum Background {
        case image(URL)
        case gradient([Color])
    }
    
    let title: String
    let description: String
    let buttonTitle: String?
    let background: Background
    let badgeImage: URL?
}

struct BannersView: View {
    @Binding var bannerModels: [Banner]
    @Binding var page: Int
    @State private var contentOffset: CGFloat = 0
    
    var body: some View {
        
        ObservableScrollView(.horizontal, showIndicators: false, contentOffset: $contentOffset) {
            LazyHGrid(rows: [.init()]) {
                ForEach(bannerModels.indices, id: \.self) { index in
                    BannerView(banner: bannerModels[index])
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
    @State var banners: [Banner]
    
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

struct BannerView: View {
    @State var banner: Banner
    
    var body: some View {
        ZStack {
            switch banner.background {
            case .image(let url):
                WebImage(url: url) { image in
                    image.resizable()
                        .scaledToFit()
                } placeholder: {
                    Color.white
                        .skeleton(with: true, shape: .rounded(.radius(12, style: .circular)))
//                        .frame(width: 70, height: 70)
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
            case .gradient(let array):
                LinearGradient(colors: array, startPoint: .topLeading, endPoint: .bottomTrailing)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
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
                    if let buttonTitle = banner.buttonTitle {
                        HStack {
                            Text(buttonTitle)
                                .font(.custom("Poppins-Medium", size: 10))
                                .foregroundStyle(Color.background.white)
                            Image("circled-arrow-right")
                        }
                        .padding(.bottom, 8)
                    }
                    Spacer()
                    WebImage(url: banner.badgeImage) { image in
                        image.resizable()
                            .scaledToFit()
                    } placeholder: {
                        Color.white
                            .skeleton(with: true, shape: .circle)
                            .frame(width: 70, height: 70)
                    }
                    .transition(.fade(duration: 0.5)) // Fade Transition with duration
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .frame(width: 70, height: 70)
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

struct Package {
    let merchant: String
    let image: Image // will be changed to URL
    let imageURL: URL?
    let title: String
    let description: String
    let price: Double
    let originalPrice: Double?
    let currency: String
}

struct PackageCarouselModel {
    let title: String
    let packages: [Package]
}

struct PackagesCarousel: View {
    @State var model: PackageCarouselModel
    
    private let columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
    var body: some View {
        VStack {
            HStack {
                Text(model.title)
                    .textStyle(HomeRowTitleStyle())
                Spacer()
                if model.packages.count > 2 {
                    CustomNavLink(destination: OffersView()) {
                        HStack(spacing: 4) {
                            Text("See all")
                                .font(.custom("Poppins-Regular", size: 14))
                                .foregroundStyle(Color.text.black60)
                            Image("chevron-right")
                        }
                    }
                }
            }
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: [.init()], spacing: 16) {
                    ForEach(model.packages.indices, id: \.self) { index in
                        PackageCard(package: model.packages[index])
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
                    .transition(.fade(duration: 0.5)) // Fade Transition with duration
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

struct Merchant {
    let name: String
    let backgroundImage: URL?
    let backgroundColors: [Color]
    let storeImage: Image
}

struct MerchantListModel {
    let title: String
    let merchants: [Merchant]
}

struct MerchantList: View {
    @State var model: MerchantListModel
    
    var body: some View {
        VStack {
            Text(model.title)
                .textStyle(HomeRowTitleStyle())
                .frame(maxWidth: .infinity, alignment: .leading)
            VStack(spacing: 8) {
                ForEach(model.merchants.indices, id: \.self) { index in
                    MerchantCard(merchant: model.merchants[index])
                }
            }
        }
    }
}

struct MerchantCard: View {
    @State var merchant: Merchant
    var body: some View {
        CustomNavLink(destination: MerchantPageView(), label: {
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
                }
                .padding(.leading, 10)
                .padding(.trailing, 20)
            }
        })
    }
}

struct ReferalCard: View {
    @State var banner: Banner
    @State private var show = false

    var background: any View {
        switch banner.background {
        case .image(let url):
            WebImage(url: url) { image in
                image.resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } placeholder: {
                Color.white
                    .skeleton(with: true, shape: .rounded(.radius(12, style: .continuous)))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .frame(height: 290)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
        case .gradient(let array):
            LinearGradient(colors: array, startPoint: .topLeading, endPoint: .bottomTrailing)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    var body: some View {
        ZStack {
            background.equatable.view
            GeometryReader { metrics in
                VStack(spacing: 8) {
                    HStack {
                        Text(banner.title)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.custom("Roboto-Bold", size: 24))
                            .foregroundColor(Color.background.white)
                            .shadow(radius: 4, y: 4)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    HStack {
                        VStack {
                            Text(banner.description)
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
                                    Text(banner.buttonTitle)
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
                            WebImage(url: banner.badgeImage) { image in
                                image.resizable()
                                    .scaledToFit()
                            } placeholder: {
                                Color.white
                                    .skeleton(with: true, shape: .circle)
                                    .frame(width: 110, height: 110)
                            }
                            .transition(.fade(duration: 0.5)) // Fade Transition with duration
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                            .frame(width: 110, height: 110)
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
