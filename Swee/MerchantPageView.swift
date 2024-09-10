import SwiftUI
import SwiftUIIntrospect

struct MerchantPageView: View {
    @State private var size: CGRect = .zero
    @State private var topInset: Double = 0
    @Environment(\.dismiss) private var dismiss
    @Environment(\.tabIsShown) private var tabIsShown

    @State var model: OfferRowModel = OfferRowModel(title: "Package just for you",
                                                    offers: [
                                                        .init(vendor: .Zoomoov, image: .init("offer-1"), title: "10 Zoomoov Rides", description: "Get 3 rides free", price: 50, originalPrice: 69),
                                                        .init(vendor: .Jollyfield, image: .init("offer-2"), title: "8 Hours of playtime", description: "Get 30 minutes free", price: 50, originalPrice: 69),
                                                        .init(vendor: .Jollyfield, image: .init("offer-2"), title: "8 Hours of playtime", description: "Get 30 minutes free", price: 50, originalPrice: 69),
                                                        .init(vendor: .Jollyfield, image: .init("offer-2"), title: "8 Hours of playtime", description: "Get 30 minutes free", price: 50, originalPrice: 69),
                                                        .init(vendor: .Jollyfield, image: .init("offer-2"), title: "8 Hours of playtime", description: "Get 30 minutes free", price: 50, originalPrice: 69),
                                                        .init(vendor: .Zoomoov, image: .init("offer-1"), title: "10 Zoomoov Rides", description: "Get 3 rides free", price: 50, originalPrice: 69),
                                                        .init(vendor: .Jollyfield, image: .init("offer-2"), title: "8 Hours of playtime", description: "Get 30 minutes free", price: 50, originalPrice: 69),
                                                        
                                                    ])
    
    @State var venueModels: [VenueCard.Model] = [
        .init(title: "Jurong point mall", distance: "0.5 km away", image: Image("location-1")),
        .init(title: "United square mall", distance: "1.5 km away", image: Image("location-2"))
    ]
    
    var columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
    private var positionDetector: some View {
        GeometryReader { proxy in
            let frame = proxy.frame(in: .global)
            
            Color.clear
                .onChange(of: frame) { newVal in
                    size = newVal
                }
        }
    }

    private var bgImage: some View {
        GeometryReader { proxy in
            let h = proxy.size.height
            let minY = proxy.frame(in: .global).minY
            Image("merchant-bg")
                .resizable()
                .scaledToFill()
                .frame(height: max(h, size.maxY - 60))
                .frame(maxWidth: proxy.size.width)
                .offset(y: min(0, -minY + topInset + 80))
        }
    }
    
    var body: some View {
//            NavigationView {
                GeometryReader { geometry in
                    let insets = geometry.safeAreaInsets
                    ScrollView {
                        VStack {
                            VStack(spacing: 0) {
                                VStack {
                                    Spacer()
                                    HStack {
                                        VStack(alignment: .leading, spacing: 0) {
                                            Text("Zoomoov")
                                                .font(.custom("Poppins-Bold", size: 24))
                                                .foregroundStyle(.white)
                                            Text("24 locations".underline(font: .custom("Poppins-SemiBold", size: 14),
                                                                          color: .white))
                                        }
                                        Spacer()
                                        Image("share-system")
                                            .foregroundStyle(.white)
                                    }
                                    .padding([.leading, .trailing], 16)
                                }
                                .frame(height: 200)
                                .frame(maxWidth: .infinity)
                                .padding(.bottom, 40)
                                .background(LinearGradient(colors: [.black, .black.opacity(0.2), .clear], startPoint: .bottom, endPoint: .top))
                            }
                            .padding(.bottom, -40)
                            .onChange(of: size) { newVal in
                                topInset = insets.top
                            }
                            .background { positionDetector }
                            .background { bgImage }
                            VStack(alignment: .leading, spacing: 20) {
                                Text("""
                                 Zoomoov is a vast farming area where characters indulge in farming activities and conjures a farming process – dig, sow, harvest with the emphasis on cooperative teamwork.
                                 There is never a lack of PLAYtime with.
                                 """)
                                .font(.custom("Poppins-Medium", size: 16))
                                .foregroundStyle(Color.text.black80)
                                VStack(alignment: .leading) {
                                    Text("Legendary deals just for today")
                                        .font(.custom("Poppins-Bold", size: 20))
                                    DealBanner(banner: .init(expiryDate: "06:00 hrs left",
                                                             title: "Super hero Tuesday",
                                                             description: "One free ride when you bring Zoomoov hero mask",
                                                             image: .init("badge-2"),
                                                             bgColors: [Color(hex:"#3900B1"), Color(hex:"#9936CE"), Color(hex:"#FDC093")],
                                                             timerColors: [Color(hex: "#FFC107"), Color(hex: "#FFC107", opacity: 0)]))
                                }
                                Text("Package just for you")
                                    .font(.custom("Poppins-Bold", size: 20))
                                LazyVGrid(columns: columns, spacing: 16) {
                                    ForEach(model.offers.indices, id: \.self) { index in
                                        OfferCard(offer: model.offers[index])
                                    }
                                }
                                Text("Nearby location")
                                    .font(.custom("Poppins-Bold", size: 20))
                                ScrollView(.horizontal, showsIndicators: false) {
                                    LazyHGrid(rows: [.init()], content: {
                                        ForEach(venueModels.indices, id: \.self) { index in
                                            VenueCard(model: venueModels[index])
                                        }
                                    })
                                }
                                .padding(.bottom, 20)
                                .introspect(.scrollView, on: .iOS(.v15, .v16, .v17, .v18), customize: { scrollView in
                                    scrollView.clipsToBounds = false
                                })
                            }
                            .padding([.leading, .trailing, .top], 16)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                        .padding(.bottom, 30)
                    }
                    .ignoresSafeArea()
                    .customNavigationTitle("Zoomoov")
                    .customNavTrailingItem {
                        Button {

                        } label: {
                            Image("cart")
                        }
                        .buttonStyle(EmptyStyle())
                    }
                }
                .onWillAppear({
                    tabIsShown.wrappedValue = false
                })
//            }
    }
}

struct DealBannerModel {
    let expiryDate: String
    let title: String
    let description: String
    let image: Image
    let bgColors: [Color]
    let timerColors: [Color]
}

struct DealBanner: View {
    @State var banner: DealBannerModel
    
    var body: some View {
        ZStack{
            HStack {
                VStack {
                    Text(banner.title)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.custom("Poppins-Bold", size: 18))
                        .foregroundColor(Color.background.white)
                        .shadow(radius: 1, y: 1)
                        .padding(.top, 15)
                    Text(banner.description)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.custom("Poppins-SemiBold", size: 12))
                        .foregroundColor(Color.background.white.opacity(0.75))
                    HStack(alignment: .bottom) {
                        HStack(spacing: 4) {
                            Text("Add to Cart")
                                .font(.custom("Poppins-Medium", size: 14))
                                .foregroundStyle(Color.background.white)
                            Image("cart")
                                .resizable()
                                .foregroundColor(.white)
                                .frame(width: 18, height: 18)
                        }
                        .padding([.leading, .trailing], 12)
                        .padding([.top, .bottom], 4)
                        .background(
                            Capsule()
                            .foregroundStyle(.white.opacity(0.2)))
                        Spacer()
                    }
                    .padding(.top, 20)
                }
                Spacer()
                VStack {
                    Spacer()
                    banner.image
                        .frame(width: 90, height: 90)
                }
            }
            .padding()
            .background(LinearGradient(colors: banner.bgColors, startPoint: .topLeading, endPoint: .bottomTrailing))
            VStack {
                HStack {
                    HStack {
                        Text(banner.expiryDate)
                            .font(.custom("Poppins-Bold", size: 12))
                            .foregroundStyle(.white)
                            .shadow(radius: 0, y: 1)
                    }
                    .padding([.trailing], 40)
                    .padding([.leading], 10)
                    .padding([.top], 4)
                    .background(LinearGradient(colors: banner.timerColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                    Spacer()
                }
                Spacer()
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct VenueCard: View {
    struct Model {
        let title: String
        let distance: String
        let image: Image
    }
    
    @State var model: VenueCard.Model
    
    var body: some View {
        ZStack {
            model.image
                .resizable()
                .scaledToFill()
                .frame(minWidth: 0, maxHeight: 230)
                .edgesIgnoringSafeArea(.all)
            VStack(alignment: .leading) {
                Spacer()
                HStack {
                    VStack(alignment: .leading) {
                        Text(model.title)
                            .font(.custom("Roboto-Bold", size: 14))
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.25), radius: 0, y: 2)
                        Text(model.distance)
                            .font(.custom("Roboto-Bold", size: 12))
                            .foregroundStyle(.white)
                    }
                    Spacer()
                }
                .padding(16)
                .background(LinearGradient(colors: [.black.opacity(0.9), Color(hex: "#D9D9D9", opacity: 0)], startPoint: .bottom, endPoint: .top))
            }
        }
        .frame(width:  200, height: 230)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    CustomNavView {
        MerchantPageView()
    }
}
