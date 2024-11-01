import Foundation
import SwiftUI
import SDWebImageSwiftUI
import SDWebImage
import SkeletonUI

struct HomeView: View {
    
    @EnvironmentObject private var api: API
    @EnvironmentObject private var cart: Cart
    @EnvironmentObject private var locationManager: LocationManager
    @EnvironmentObject private var activeSession: ActiveSession
    @StateObject private var viewModel = HomeViewModel()
    @Environment(\.tabIsShown) private var tabIsShown
    @Environment(\.route) private var route
    @State private var hideBottomSheet: Bool = true
    @State private var navView: UINavigationController? = nil
    @State private var goToPackage = false
    @State private var deepLinkPackage: Package?
    
    func section(at index: Int) -> any View {
        let section = viewModel.sections[index]
        switch section.content {
        case .bannerCarousel(let banners):
            return BannersCarousel(banners: banners)
        case .packages(let packages):
            return PackagesCarousel(model: PackageCarouselModel(sectionID: section.id, title: section.title ?? "", packages: packages))
        case .merchants(let merchants):
            return MerchantList(model: .init(title: section.title ?? "", merchants: merchants))
                .padding(.horizontal, 16)
        case .bannerStatic(let banners):
            if banners.isEmpty {
                return EmptyView()
            }
            return ReferalCard(banner: banners[0])
                    .padding(.horizontal, 16)
        }
    }
    
    var skeletonUI: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 30) {
                BannersView
                    .skeleton.equatable.view
                PackagesCarousel
                    .skeleton.equatable.view
                PackagesCarousel
                    .skeleton.equatable.view
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.vertical, 20)
            .padding(.leading, 16)
        }
        .introspect(.scrollView, on: .iOS(.v15, .v16, .v17, .v18), customize: { scrollView in
            scrollView.isUserInteractionEnabled = false
        })
    }
    
    var mainUI: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(viewModel.sections.indices, id: \.self) { index in
                    section(at: index).equatable.view
                }
            }
            .padding(.vertical, 20)
//                        .padding(.horizontal, 16)
            .padding(.bottom, activeSession.sessionIsActive ? 160 : 100)
        }
        .ignoresSafeArea()
    }
    
    var body: some View {
        CustomNavView {
            ZStack {
                if let package = deepLinkPackage {
                    CustomNavLink(isActive: $goToPackage, destination: PackageDetailView(package: package))
                }
                VStack {
                    if viewModel.showError {
                        StateView.error {
                            try? await viewModel.fetch()
                        }
                    } else if viewModel.sections.isEmpty {
                        skeletonUI
                    } else {
                        mainUI
                    }
                }
                .onChange(of: hideBottomSheet, perform: { newValue in
                    tabIsShown.wrappedValue = hideBottomSheet
                })
                .onAppear(perform: {
                    viewModel.api = api
                    viewModel.cart = cart
                    Task {
                        try? await viewModel.fetch()
                    }
                    tabIsShown.wrappedValue = true
                    locationManager.checkLocationAuthorization()
                })
                .customNavigationBackButtonHidden(true)
                .customNavLeadingItem {
                    LogoNavItem()
                }
                .customNavTrailingItem {
                    CartButton()
                    //                Button(action: {
                    //                    hideBottomSheet = false
                    //                }, label: {
                    //                    Image("cart")
                    //                        .foregroundStyle(Color.text.black60)
                    //                })
                    //                .buttonStyle(EmptyStyle())
                }
                .customBottomSheet(hidden: $hideBottomSheet) {
                    NotificationUpsell(hide: $hideBottomSheet)
                }
            }
        }
        .onChange(of: route) { newValue in
            guard let route = route.wrappedValue else {
                return
            }
            
            switch route {
            case .package(let id):
                defer {
                    self.route.wrappedValue = nil
                }
                Task {
                    do {
                        let package = try await viewModel.package(for: id)
                        await MainActor.run {
                            deepLinkPackage = package
                            goToPackage = true
                        }
                    } catch {
                        // fail silently
                    }
                }
            }
        }
        .environment(\.navView, $navView)
        .introspect(.navigationView(style: .stack), on: .iOS(.v15, .v16, .v17, .v18), customize: { navView in
            self.navView = navView
            navView.tabBarController?.tabBar.isHidden = true
        })
    }
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
            .padding(.horizontal, 16)
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
//        .introspect(.scrollView, on: .iOS(.v15, .v16, .v17, .v18), customize: { scrollView in
//            scrollView.clipsToBounds = false
//        })
    }
}

extension BannersView: Skeletonable {
    static var skeleton: any View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: [.init()]) {
                ForEach(0...3, id: \.self) { index in
                    BannerView
                        .skeleton.equatable.view
                }
            }
        }
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
                        HStack(spacing: 4) {
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
                    .transition(.fade(duration: 0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .frame(width: 70, height: 70)
                }
            }
            .padding(16)
        }
        .frame(width: 210, height: 190)
    }
}

extension BannerView: Skeletonable {
    static var skeleton: any View {
        Color.white
            .skeleton(with: true, shape: .rounded(.radius(12, style: .circular)))
            .frame(width: 210, height: 190)
    }
}

struct PackageCarouselModel {
    let sectionID: UUID
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
                    CustomNavLink(destination: SeeAllView(sectionID: model.sectionID, title: model.title)) {
                        HStack(spacing: 4) {
                            Text("See all")
                                .font(.custom("Poppins-Regular", size: 14))
                                .foregroundStyle(Color.text.black60)
                            Image("chevron-right")
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: [.init()], spacing: 16) {
                    ForEach(model.packages.indices, id: \.self) { index in
                        let package = model.packages[index]
                        PackageCard(package: package)
                            .frame(width: 165)
                    }
                }
                .padding(.horizontal, 16)
            }
//            .introspect(.scrollView, on: .iOS(.v15, .v16, .v17, .v18), customize: { scrollView in
//                scrollView.clipsToBounds = false
//            })
        }
    }
}

extension PackagesCarousel: Skeletonable {
    static var skeleton: any View {
        VStack(alignment: .leading, spacing: 14) {
            Text("")
                .skeleton(with: true, shape: .rounded(.radius(12, style: .circular)))
                .frame(maxWidth: 200)
                .frame(height: 20)
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: [.init()], spacing: 16) {
                    ForEach(0...2, id: \.self) { index in
                        PackageCard
                            .skeleton
                            .frame(width: 165)
                            .equatable.view
                    }
                }
                .frame(maxHeight: 200)
            }
        }
//        .frame(maxHeight: 400)
    }
}

#Preview(body: {
    ScrollView {
        VStack(spacing: 30) {
            BannersView
                .skeleton.equatable.view
            PackagesCarousel
                .skeleton.equatable.view
            PackagesCarousel
                .skeleton.equatable.view
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
    }
})

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
            .padding()
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
        .environmentObject(API())
}
