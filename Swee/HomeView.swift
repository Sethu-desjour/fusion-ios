import SwiftUI

struct HomeView: View {
    
    var body: some View {
        BannersCarousel()
            .frame(maxWidth: .infinity, maxHeight: 190)
    }
}

struct BannerModel {
    let title: String
    let description: String
    let buttonTitle: String
    let backgroundImage: Image
    let badgeImage: Image
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
              badgeImage: .init("badge-2"))
    ]
    
    var body: some View {
        BannersView(bannerModels: $banners, page: $page)
            .onPageChange { newValue in
                page = newValue
            }
        //        HStack(spacing: 15, content: {
        //            ForEach(colors.indices, id:\.self) { index in
        //                Capsule()
        //                    .fill(page == index ? Color(hex: "#17223B") : Color(hex: "#17223B", opacity: 0.20))
        //                    .frame(width: page == index ? 40 : 7, height: 7, alignment: .center)
        //                    .animation(.default, value: page)
        //            }
        //        })
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
                        Image("arrow-right")
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

#Preview {
    HomeView()
}
