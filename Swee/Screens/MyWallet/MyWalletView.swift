import SwiftUI
import SDWebImageSwiftUI

struct MerchantPurchases {
    let image: Image
    let merchant: String
    let summary: String
    let colors: [Color]
}

struct MyWalletView: View {
    @Environment(\.tabIsShown) private var tabIsShown
    @Environment(\.currentTab) private var currentTab
    @EnvironmentObject private var api: API
    @StateObject private var viewModel = MyWalletViewModel()
    
    var emptyUI: some View {
        VStack(spacing: 0) {
            Image("wallet-empty")
                .padding(.vertical, 32)
            VStack {
                Text("No coupons found")
                    .font(.custom("Poppins-SemiBold", size: 18))
                    .foregroundStyle(Color.text.black80)
                    .padding(.bottom, 8)
                Text("Browse packages and save your coupons in your wallet here")
                    .font(.custom("Poppins-Medium", size: 14))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.text.black60)
                    .padding(.bottom, 24)
                Button {
                    currentTab.wrappedValue = .home
                } label: {
                    HStack {
                        Text("Explore package")
                            .font(.custom("Poppins-Bold", size: 16))
                            .foregroundStyle(Color.primary.brand)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(OutlineButton(strokeColor: Color.primary.brand, cornerRadius: 28))
            }
            .padding(.horizontal, 60)
        }
    }
    
    var body: some View {
        CustomNavView {
            ScrollView {
                HStack {
                    Text("My purchases")
                        .font(.custom("Poppins-SemiBold", size: 18))
                    Spacer()
                    CustomNavLink(destination: ActivityView()) {
                        HStack {
                            Image("activity")
                            Text("All activity")
                                .font(.custom("Poppins-Medium", size: 14))
                        }
                    }
                    .padding(8)
                    .tint(Color.text.black60)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.black.opacity(0.15),
                                    lineWidth: 1)
                    )
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding(.top, 8)
                .padding(.horizontal, 16)
                if viewModel.showError {
                    StateView.error {
                        try? await viewModel.fetch()
                    }
                } else if !viewModel.loadedData, viewModel.merchants.isEmpty {
                    VStack(spacing: 16) {
                        MerchantPurchasesCard.skeleton.equatable.view
                        MerchantPurchasesCard.skeleton.equatable.view
                    }
                    .padding(.horizontal, 16)
                } else if viewModel.merchants.isEmpty {
                    emptyUI
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.merchants, id: \.id) { merchant in
                            let view = MerchantPurchasesCard(merchant: merchant)
                            if merchant.name.lowercased() == "zoomoov" {
                                CustomNavLink(destination: ZoomoovRedemptionView(merchant: merchant)) {
                                    view
                                }
                            } else {
                                CustomNavLink(destination: JollyfieldRedemptionView()) {
                                    view
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 60)
                }
            }
            .background(Color.background.pale)
            .onAppear(perform: {
                viewModel.api = api
                Task {
                    try? await viewModel.fetch()
                }
                tabIsShown.wrappedValue = true
            })
            .customNavigationBackButtonHidden(true)
            .customNavLeadingItem {
                LogoNavItem()
            }
            .customNavTrailingItem {
                CartButton()
            }
        }
    }
}

struct MerchantPurchasesCard: View {
    var merchant: WalletMerchant
    
    var body: some View {
        VStack {
            WebImage(url: merchant.photoURL) { image in
                image.resizable()
                    .scaledToFit()
            } placeholder: {
                Color.white
                    .skeleton(with: true, shape: .rounded(.radius(12, style: .circular)))
                        .frame(height: 154)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            HStack {
                VStack(alignment: .leading) {
                    Text(merchant.name)
                        .font(.custom("Poppins-Bold", size: 12))
                        .foregroundStyle(.white)
                        .padding([.top, .bottom], 4)
                        .padding([.leading, .trailing], 8)
                        .background {
                            Rectangle()
                                .fill(.black.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    Text(merchant.purchaseSummary)
                        .font(.custom("Poppins-SemiBold", size: 18))
                        .foregroundStyle(Color.background.white)
                }
                Spacer()
                Image("arrow-right")
                    .padding(4)
                    .background {
                        Circle()
                            .fill(.white.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
            }
        }
        .padding(16)
        .background(LinearGradient(colors: merchant.bgColors, startPoint: .topLeading, endPoint: .bottomTrailing))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

extension MerchantPurchasesCard: Skeletonable {
    static var skeleton: any View {
        ZStack {
            Color.white
            .skeleton(with: true, shape: .rounded(.radius(16, style: .circular)))
                .frame(height: 300)
            VStack(alignment: .leading, spacing: 16)  {
                Color.white
                    .skeleton(with: true, shape: .rounded(.radius(12, style: .circular)))
                    .frame(width: 320, height: 154)
                Text("")
                    .skeleton(with: true, shape: .rounded(.radius(12, style: .circular)))
                    .frame(width: 100, height: 20)
                Text("")
                    .skeleton(with: true, shape: .rounded(.radius(12, style: .circular)))
                    .frame(width: 170, height: 20)
            }
        }
        .frame(height: 300)
    }
}

#Preview {
    MerchantPurchasesCard
        .skeleton
}

#Preview {
    MyWalletView()
}
