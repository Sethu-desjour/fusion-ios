import SwiftUI

struct MerchantPurchases {
    let image: Image
    let merchant: String
    let summary: String
    let colors: [Color]
}

struct MyPurchasesView: View {
    @Environment(\.tabIsShown) private var tabIsShown
    @State var purchases: [MerchantPurchases] = [
        .init(image: Image("purhcase-1"), merchant: "Zoomoov AMK", summary: "24 Rides + 12 masks", colors: Color.gradient.secondary),
        .init(image: Image("purhcase-2"), merchant: "Jollyfield Bugis+", summary: "01:30 hrs left", colors: Color.gradient.primary)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                HStack {
                    Text("My purchases")
                        .font(.custom("Poppins-SemiBold", size: 18))
                    Spacer()
                    NavigationLink(destination: ActivityView()) {
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
                LazyVStack(spacing: 16) {
                    ForEach(purchases, id: \.merchant) { purchase in
                        NavigationLink(destination: TicketsView(tickets: [
                            .init(merchant: "Zoomoov", quantity: 12, description: "Rides", type: "Rides", expirationDate: Date(), colors: Color.gradient.primary),
                            .init(merchant: "Zoomoov", quantity: 1, description: "Masks", type: "Mask", expirationDate: Date(), colors: [Color(hex: "#EC048A"), Color(hex: "#F0971C")])
                        ])) {
                            MerchantPurchasesCard(purchase: purchase)
                        }
                    }
                }
                .padding(.horizontal, 16)
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
                    NavigationLink(destination: CheckoutView(), label: {
                        Image("cart")
                    })
                    .buttonStyle(EmptyStyle())
                    .padding(.bottom, 15)
                }
            }
            .background(Color.background.pale)
            .onWillAppear({
                tabIsShown.wrappedValue = true
            })
//            .onWillDisappear({
//                tabIsShown.wrappedValue = false
//            })
        }
    }
}

struct MerchantPurchasesCard: View {
    var purchase: MerchantPurchases
    
    var body: some View {
        VStack {
            purchase.image
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 12))
            HStack {
                VStack(alignment: .leading) {
                    Text(purchase.merchant)
                        .font(.custom("Poppins-Bold", size: 12))
                        .foregroundStyle(.white)
                        .padding([.top, .bottom], 4)
                        .padding([.leading, .trailing], 8)
                        .background {
                            Rectangle()
                                .fill(.black.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    Text(purchase.summary)
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
        .background(LinearGradient(colors: purchase.colors, startPoint: .topLeading, endPoint: .bottomTrailing))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    MyPurchasesView()
}
