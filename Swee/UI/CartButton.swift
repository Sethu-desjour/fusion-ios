import SwiftUI

struct CartButton: View {
    @EnvironmentObject private var cart: Cart
    @State var goToCart = false
    
    var body: some View {
        Button {
            goToCart = true
        } label: {
            ZStack {
                CustomNavLink(isActive: $goToCart, destination: CheckoutView(), label: {})
                Image("cart")
                if cart.quantity > 0 {
                    VStack(alignment: .trailing, spacing: 0) {
                        HStack(spacing: 0) {
                            Spacer()
                            Text("\(cart.quantity)")
                                .font(.custom("Roboto-Regular", size: 12))
                                .foregroundStyle(.white)
                                .padding(6)
                                .background(
                                    Circle()
                                        .foregroundStyle(Color(hex: "#DA1E28"))
                                )
                                .padding(.trailing, -4)
                                .padding(.top, -12)
                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .animation(.default, value: cart.quantity)
            .frame(width: 40, height: 24)
            //                        .background(.green)
        }
        .buttonStyle(EmptyStyle())
    }
}

#Preview {
    CartButton()
}
