import SwiftUI
import SwiftUIIntrospect
import DispatchIntrospection

struct OffersView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.tabIsShown) private var tabIsShown

    @State var uiNavController: UINavigationController?
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
    
    var columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
    var body: some View {
        NavigationView {
//            VStack(spacing: 0) {
//                Divider()
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(model.offers.indices, id: \.self) { index in
                            OfferCard(offer: model.offers[index])
                        }
                    }
                    .padding([.leading, .trailing, .top], 16)
                }
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
                        Text("Packages just for you")
                            .font(.custom("Poppins-Bold", size: 18))
                            .foregroundStyle(Color.text.black100)
                            .padding(.bottom, 15)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            // handle tap
                        } label: {
                            Image("cart")
                        }
                        .buttonStyle(EmptyStyle())
                        .padding(.bottom, 15)
                    }
                }
//            }
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
        })
        .navigationBarTitle("")
        .navigationBarHidden(true)
    }
}

#Preview {
    OffersView()
}
