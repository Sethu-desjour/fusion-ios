import SwiftUI

struct ListModel {
    enum Option {
        case Bullet, Numbered
    }
    let title: String
    let points: [String]
    let type: Option
}

struct ProductDetailModel {
    let id: String
    let image: Image
    let title: String
    let subtitle: String
    let vendor: Vendors
    let locations: [Int] // will replace with location model once there's a design for it
    let price: String
    let originalPrice: String?
    let description: LocalizedStringKey
    let redemptionSteps: ListModel
    let aboutSteps: ListModel
    let tosText: String
}

struct ProductDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var hideTabBarWrapper: ObservableWrapper<Bool, TabBarNamespace>
    @State private var uiNavController: UINavigationController?
    @State private var isExpanded: Bool = false
    @State var product: ProductDetailModel
    @State private var quantity: Int = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        product.image
                            .resizable()
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(product.subtitle)
                                    .font(.custom("Poppins-Bold", size: 20))
                                    .foregroundStyle(Color.text.black100)
                                Spacer()
                                Button {
                                    
                                } label: {
                                    Image("share-system")
                                        .tint(Color.text.black80)
                                }
                                .frame(width: 56, height: 56)
                            }
                            Text("By \(product.vendor.toString())")
                                .font(.custom("Poppins-SemiBold", size: 14))
                                .foregroundStyle(Color.text.black80)
                            HStack(spacing: 4) {
                                Text("See all \(product.locations.count) locations")
                                    .font(.custom("Poppins-Regular", size: 12))
                                    .foregroundStyle(Color.text.black60)
                                Image("chevron-right")
                            }
                        }
                        Rectangle()
                            .frame(height: 1)
                            .foregroundStyle(.black.opacity(0.15))
                        HStack {
                            Text(product.price)
                                .font(.custom("Poppins-Bold", size: 20))
                                .foregroundStyle(Color.text.black100)
                            if let originalPrice = product.originalPrice {
                                Text(originalPrice.strikethroughText(color: Color.text.black60))
                                    .font(.custom("Poppins-SemiBold", size: 14))
                                    .foregroundStyle(Color.text.black60)
                            }
                        }
                        Text(product.description)
                            .font(.custom("Poppins-Medium", size: 16))
                            .foregroundStyle(Color.text.black60)
                        Rectangle()
                            .frame(height: 1)
                            .foregroundStyle(.black.opacity(0.15))
                        VStack(alignment: .leading) {
                            Text(product.redemptionSteps.title)
                                .font(.custom("Poppins-Bold", size: 18))
                                .foregroundStyle(Color.text.black100)
                            ForEach(product.redemptionSteps.points.indices, id: \.self) { index in
                                HStack(alignment: .top) {
                                    Text("\(index + 1).")
                                    Text(product.redemptionSteps.points[index])
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.custom("Poppins-Medium", size: 16))
                                .foregroundStyle(Color.text.black60)
                            }
                        }
                        Rectangle()
                            .frame(height: 1)
                            .foregroundStyle(.black.opacity(0.15))
                        VStack(alignment: .leading) {
                            Text(product.aboutSteps.title)
                                .font(.custom("Poppins-Bold", size: 18))
                                .foregroundStyle(Color.text.black100)
                            ForEach(product.aboutSteps.points.indices, id: \.self) { index in
                                HStack(alignment: .top) {
                                    Text(" • ")
                                    Text(product.aboutSteps.points[index])
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.custom("Poppins-Regular", size: 16))
                                .foregroundStyle(Color.text.black60)
                            }
                        }
                        ZStack {
                            VStack(alignment: .leading) {
                                Text("Terms & Conditions")
                                    .font(.custom("Poppins-Bold", size: 18))
                                    .foregroundStyle(Color.text.black100)
                                VStack {
                                    Text(product.tosText)
                                        .lineLimit(isExpanded ? nil : 6)
                                        .font(.custom("Poppins-Medium", size: 16))
                                        .foregroundStyle(Color.text.black80)
                                        .overlay(
                                            GeometryReader { proxy in
                                                Button(action: {
                                                    isExpanded.toggle()
                                                }) {
                                                    Text(isExpanded ? "see less".underline(font: .custom("Roboto-Medium", size: 16), color: Color.primary.brand) : "see more".underline(font: .custom("Roboto-Medium", size: 16), color: Color.primary.brand))
                                                        .padding(.leading, 8.0)
                                                        .background(Color.background.pale)
                                                        .shadow(color: Color.background.pale, radius: 4, x: -8)
                                                }
                                                .frame(width: proxy.size.width, height: proxy.size.height - 2, alignment: .bottomTrailing)
                                            }
                                        )
                                }
                            }
                            .padding()
                            .background(Color.background.pale)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.bottom, 16)
                    }
                    .padding(.horizontal, 16)
                }
                VStack(spacing: 0) {
                    if quantity == 0 {
                        Button {
                            quantity += 1
                        } label: {
                            HStack {
                                Text("Add to cart")
                                    .font(.custom("Poppins-Medium", size: 18))
                                Image("cart-thick")
                                    .resizable()
                                    .frame(width: 16, height: 16)
                            }
                            .foregroundStyle(Color.background.white)
                            .frame(maxWidth: .infinity, maxHeight: 55)
                            .background(Color.primary.brand)
                            .clipShape(Capsule())
                        }
                        .buttonStyle(EmptyStyle())
                    } else {
                        HStack {
                            Spacer()
                            Button {
                                if quantity == 0 {
                                    return
                                }
                                quantity -= 1
                            } label: {
                                Image("minus")
                            }
                            .tint(.white)
                            Spacer()
                            Text("\(quantity)")
                                .font(.custom("Roboto-Bold", size: 24))
                                .foregroundStyle(.white)
                            Spacer()
                            Button {
                                quantity += 1
                            } label: {
                                Image("plus")
                            }
                            .tint(.white)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: 55)
                        .background(Color.primary.brand)
                        .clipShape(Capsule())
                    }
                }
                .animation(.default, value: quantity)
                .padding([.leading, .trailing, .top], 16)
                .overlay(Rectangle().frame(width: nil, height: 1, alignment: .top).foregroundColor(Color.text.black10), alignment: .top)
                
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image("back")
                    }
                    .padding(.bottom, 10)
                }
                ToolbarItem(placement: .principal) {
                    Text(product.title)
                        .font(.custom("Poppins-Bold", size: 18))
                        .foregroundStyle(Color.text.black100)
                        .padding(.bottom, 10)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        
                    } label: {
                        ZStack {
                            Image("cart")
                            if quantity > 0 {
                                VStack(alignment: .trailing, spacing: 0) {
                                    HStack(spacing: 0) {
                                        Spacer()
                                        Text("\(quantity)")
                                            .font(.custom("Roboto-Regular", size: 12))
                                            .foregroundStyle(.white)
                                            .padding(6)
                                            .background(
                                                Circle()
                                                    .foregroundStyle(Color(hex: "#DA1E28"))
                                            )
                                            .padding(.trailing, 4)
                                            .padding(.top, 4)
                                    }
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                        }
                        .animation(.default, value: quantity)
                        .frame(width: 56, height: 56)
//                        .background(.green)
                    }
                    .buttonStyle(EmptyStyle())
                    .padding(.bottom, 10)
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
        }
        .introspect(.navigationView(style: .stack), on: .iOS(.v15, .v16, .v17, .v18), customize: { navBar in
            navBar.tabBarController?.tabBar.isHidden = true
            uiNavController = navBar
        })
        .onWillAppear({
            hideTabBarWrapper.prop = true
        })
        .onWillDisappear({
            uiNavController?.tabBarController?.tabBar.isHidden = false
            hideTabBarWrapper.prop = false
        })
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.bottom)
    }
}

#Preview {
    ProductDetailView(product: .init(id: "id", image: Image("product-detail-img"), title: "Chinese new year", subtitle: "10 Zoomoov rides + 1 Hero mask + 1 Bingo draw", vendor: .Zoomoov, locations: Array(0..<12), price: "S$ 50", originalPrice: "S$ 69",
                                     description: """
Buy our **SUPERHERO** promo to get free rides from our Bingo Draws & Superhero Tuesday!

Best promo of 15 Rides, you get 2 **SUPERHERO** masks and 3 **Bingo Draws** (guaranteed 1 free ride minimum each draw)
""",
                                     redemptionSteps: .init(title: "How to redeem", points: ["Go to the Zoomoov outlet", "Scan the QR code at the counter", "Our staff will provide you the mask if included", "Enjoy the ride"], type: .Numbered), aboutSteps: .init(title: "About package", points: ["Access to all play areas in the zone", "Expiry only after a year", "Free meals and beverages", "Other package benefit will also be listed here", "as different points"], type: .Bullet), tosText: "In no event shall Swee or its suppliers be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption) arising out In no event shall Swee or its suppliers be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption) arising out "))
}
