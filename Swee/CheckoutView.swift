import SwiftUI

struct Product {
    let id: String
    let title: String
    let description: String
    let priceString: String
    let price: Double
    let image: Image
    let validity: String
}

struct CheckoutProduct {
    let product: Product
    let quantity: Int
}

struct CheckoutView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.tabIsShown) private var tabIsShown
//    @EnvironmentObject private var hideTabBarWrapper: ObservableWrapper<Bool, TabBarNamespace>
    @Environment(\.currentTab) private var selectedTab
    
    @State var uiNavController: UINavigationController?
    @State var products: [CheckoutProduct] = [
        .init(product: .init(id: "1", title: "Merchant 1", description: "10 Zoomoov rides + 1 Hero mask + 1 bingo draw", priceString: "S$ 125", price: 125, image: Image("product-1"), validity: "Validity - 1 year"), quantity: 2),
        .init(product: .init(id: "2", title: "Package name", description: "10 Zoomoov rides + 1 Hero mask + 1 bingo draw", priceString: "S$ 125", price: 125, image: Image("product-2"), validity: "Validity - 1 year"), quantity: 1),
    ]
    
    @State private var text: String = ""
    @State private var showPaymentSuccess: Bool = false
    
    enum QuantityChange {
        case increase, decrease
    }
    
    func changeQuantity(for product: CheckoutProduct, at index: Int, change: QuantityChange) {
        if change == .decrease && product.quantity == 1 {
            products.remove(at: index)
            return
        }
        
        let newProduct: CheckoutProduct = .init(product: product.product, quantity: change == .decrease ? product.quantity - 1 : product.quantity + 1)
        
        if let index = products.firstIndex(where: { element in
            element.product.id == product.product.id
        }) {
            products[index] = newProduct
        }
    }
    
    var quantity: Int {
        return products.reduce(0) { sum, prod in
            return sum + prod.quantity
        }
    }
    
    var cartTotal: Double {
        return products.reduce(0) { sum, prod in
            return sum + prod.product.price * Double(prod.quantity)
        }
    }
    
    var gst: Double {
        return cartTotal * 0.18
    }
    
    var finalTotal: Double {
        return cartTotal + gst
    }
    
    var mainUI: some View {
        VStack(spacing: 0) {
            ScrollView {
                HStack {
                    Text("\(quantity) Items")
                        .font(.custom("Poppins-Bold", size: 20))
                    Spacer()
                }
                .padding(.horizontal, 16)
                LazyVGrid(columns: [.init(.flexible())], spacing: 0) {
                    ForEach(products.indices, id: \.self) { index in
                        let element = products[index]
                        let product = element.product
                        HStack {
                            product.image
                                .resizable()
                                .scaledToFill()
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                                .padding(.trailing, 16)
                                .frame(width: 127, height: 145)
                            VStack(alignment: .leading) {
                                Text(product.title)
                                    .foregroundStyle(Color.text.black100)
                                    .font(.custom("Poppins-SemiBold", size: 16))
                                Text(product.description)
                                    .foregroundStyle(Color.text.black80)
                                    .font(.custom("Poppins-Medium", size: 12))
                                Text(product.validity)
                                    .foregroundStyle(Color.text.black80)
                                    .font(.custom("Poppins-Medium", size: 12))
                                Text("\(element.quantity) x Qty")
                                    .foregroundStyle(Color.text.black80)
                                    .font(.custom("Poppins-Medium", size: 12))
                                Spacer()
                                HStack {
                                    Text(product.priceString)
                                        .foregroundStyle(Color.text.black100)
                                        .font(.custom("Poppins-SemiBold", size: 14))
                                    Spacer()
                                    HStack {
                                        Button {
                                            changeQuantity(for: element, at: index, change: .decrease)
                                        } label: {
                                            Image("minus")
                                                .resizable()
                                                .frame(width: 16, height: 16)
                                        }
                                        .tint(Color.secondary.brand)
                                        Spacer()
                                        Text("\(element.quantity)")
                                            .font(.custom("Poppins-Bold", size: 16))
                                            .foregroundStyle(Color.secondary.brand)
                                            .lineLimit(1)
                                        Spacer()
                                        Button {
                                            changeQuantity(for: element, at: index, change: .increase)
                                        } label: {
                                            Image("plus")
                                                .resizable()
                                                .frame(width: 16, height: 16)
                                        }
                                        .tint(Color.secondary.brand)
                                    }
                                    .frame(maxWidth: 90)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
//                                    .frame(maxWidth: .infinity, maxHeight: 55)
                                    .clipShape(Capsule())
                                    .overlay(RoundedRectangle(cornerRadius: 24)
                                        .stroke(Color.secondary.brand,
                                                lineWidth: 1)
                                    )
                                }
                            }
                        }
                        .padding(16)
                    }
                }
                .background(Color.background.white)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                VStack(alignment: .leading) {
                    Text("Order summary")
                        .font(.custom("Poppins-Bold", size: 16))
                        .padding(.bottom, 16)
                    HStack {
                        TextField("Enter coupon code", text: $text)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .overlay(RoundedRectangle(cornerRadius: 4)
                                .stroke(.black.opacity(0.15),
                                        lineWidth: 1)
                            )
                        Button {
                            
                        } label: {
                            Text("Apply")
                                .font(.custom("Roboto-Bold", size: 16))
                                .foregroundStyle(Color.text.black80)
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 32)
                        .clipShape(Capsule())
                        .overlay(RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.text.black20,
                                    lineWidth: 1)
                        )
                    }
                    .padding(.bottom, 24)
                    SummaryRow(title: "Total amount", price: cartTotal)
                        .padding(.bottom, 4)
                    SummaryRow(title: "GST 18%", price: gst)
                        .padding(.bottom, 19)
                    Rectangle()
                        .fill(.black.opacity(0.05))
                        .frame(height: 1)
                        .padding(.bottom, 8)
                    SummaryRow(title: "Total", price: finalTotal, allBold: true)
                }
                .padding(16)
                .frame(maxWidth: .infinity)
                .background(Color.background.white)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .padding([.horizontal, .bottom], 16)
            }
            VStack(spacing: 0) {
                Button {
                    // @todo make request
                    showPaymentSuccess = true
                } label: {
                    HStack {
                        Text("Proceed to payment")
                            .font(.custom("Roboto-Bold", size: 16))
                    }
                    .foregroundStyle(Color.background.white)
                    .frame(maxWidth: .infinity, maxHeight: 55)
                    .background(LinearGradient(colors: Color.gradient.primary, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .clipShape(Capsule())
                }
                .buttonStyle(EmptyStyle())
            }
            .padding([.leading, .trailing, .top], 16)
            .overlay(Rectangle().frame(width: nil, height: 1, alignment: .top).foregroundColor(Color.text.black10), alignment: .top)
        }
        .background(Color.background.pale)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image("back")
                }
                .padding(.bottom, 15)
            }
            ToolbarItem(placement: .principal) {
                Text("Checkout")
                    .font(.custom("Poppins-Bold", size: 18))
                    .foregroundStyle(Color.text.black100)
                    .padding(.bottom, 15)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            if showPaymentSuccess {
                VStack {
                    Image("checkout-success")
                    Text("Payment success")
                        .font(.custom("Poppins-Medium", size: 24))
                    Text("2 Rides have been added to your purchase") // @todo compute this
                        .font(.custom("Poppins-Medium", size: 16))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.text.black40)
                        .padding(.bottom, 57)
                    Button {
                        dismiss()
                    } label: {
                        HStack {
                            Text("View my purchases")
                                .font(.custom("Roboto-Bold", size: 16))
                        }
                        .foregroundStyle(Color.background.white)
                        .frame(maxWidth: .infinity, maxHeight: 55)
                        .background(LinearGradient(colors: Color.gradient.primary, startPoint: .topLeading, endPoint: .bottomTrailing))
                        .clipShape(Capsule())
                    }
                    .buttonStyle(EmptyStyle())
                }
                .padding(.horizontal, 24)
            } else {
                mainUI
            }
        }
        .introspect(.navigationView(style: .stack), on: .iOS(.v15, .v16, .v17, .v18), customize: { navBar in
            navBar.tabBarController?.tabBar.isHidden = true
            uiNavController = navBar
        })
        .onWillAppear({
            tabIsShown.wrappedValue = false
        })
        .onWillDisappear({
            uiNavController?.tabBarController?.tabBar.isHidden = false
            tabIsShown.wrappedValue = true
            if showPaymentSuccess {
                selectedTab.wrappedValue = .purchases
            }
        })
        .navigationBarTitle("")
        .navigationBarHidden(true)
    }
}

struct SummaryRow: View {
    var title: String
    var price: Double
    var allBold: Bool = false
    
    var body: some View {
        HStack {
            Text(title)
                .font(allBold ? .custom("Poppins-SemiBold", size: 18) : .custom("Poppins-Medium", size: 16))
                .foregroundStyle(allBold ? Color.text.black100 : Color.text.black60)
            Spacer()
            Text("S$ ")
                .font(.custom("Poppins-SemiBold", size: 16))
            + Text("\(price, specifier: "%.2f")")
                .font(.custom(allBold ? "Poppins-Bold" : "Poppins-Regular", size: 16))
        }
    }
}

#Preview {
    CheckoutView()
}


extension Double {
    func toPrice() -> String {
        return "S$ \(self)"
    }
}
