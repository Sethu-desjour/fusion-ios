import SwiftUI
import SDWebImageSwiftUI

//struct ListModel {
//    enum Option {
//        case Bullet, Numbered
//    }
//    let title: String
//    let points: [String]
//    let type: Option
//}

//struct ProductDetailModel {
//    let id: String
//    let image: Image
//    let title: String
//    let subtitle: String
//    let vendor: Vendors
//    let locations: [Int] // will replace with location model once there's a design for it
//    let price: String
//    let originalPrice: String?
//    let description: LocalizedStringKey
//    let redemptionSteps: ListModel
//    let aboutSteps: ListModel
//    let tosText: String
//}

struct PackageDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.tabIsShown) private var tabIsShown
    @EnvironmentObject private var api: API
    @State private var isExpanded: Bool = false
    @State var package: Package
    @State private var quantity: Int = 0
    @StateObject private var viewModel = PackageDetailViewModel()
    
//    init(package: Package) {
//        self.package = package
//        self.viewModel =
//    }
    
    var lowerButton: some View {
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
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    WebImage(url: package.imageURL) { image in
                        image.resizable()
                            .scaledToFit()
                    } placeholder: {
                        Color.white
                            .skeleton(with: true, shape: .rounded(.radius(12, style: .circular)))
    //                        .frame(width: 70, height: 70)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(package.summary)
                                .font(.custom("Poppins-Bold", size: 20))
                                .foregroundStyle(Color.text.black100)
                            Spacer()
                            Button {
                                
                            } label: {
                                Image("share-system")
                                    .tint(Color.text.black80)
                            }
                        }
                        Text("By \(package.merchant)")
                            .font(.custom("Poppins-SemiBold", size: 14))
                            .foregroundStyle(Color.text.black80)
                        if viewModel.stores.count > 0 {
                            HStack(spacing: 4) {
                                Text("See all \(viewModel.stores.count) locations")
                                    .font(.custom("Poppins-Regular", size: 12))
                                    .foregroundStyle(Color.text.black60)
                                Image("chevron-right")
                            }
                        }
                    }
                    .animation(.default, value: viewModel.stores.count)
                    Rectangle()
                        .frame(height: 1)
                        .foregroundStyle(.black.opacity(0.15))
                    HStack {
                        Text(package.priceString)
                            .font(.custom("Poppins-Bold", size: 20))
                            .foregroundStyle(Color.text.black100)
                        if let originalPrice = package.originalPriceString {
                            Text(originalPrice.strikethroughText(color: Color.text.black60))
                                .font(.custom("Poppins-SemiBold", size: 14))
                                .foregroundStyle(Color.text.black60)
                        }
                    }
                    Text(package.description)
                        .font(.custom("Poppins-Medium", size: 16))
                        .foregroundStyle(Color.text.black60)
                    ForEach(viewModel.package.details.indices, id: \.self) { detail in
                        VStack(alignment: .leading) {
                            Rectangle()
                                .frame(height: 1)
                                .foregroundStyle(.black.opacity(0.15))
                            Text(viewModel.package.details[detail].title)
                                .font(.custom("Poppins-Bold", size: 18))
                                .foregroundStyle(Color.text.black100)
                                .padding(.vertical, 8)
                            Text(viewModel.package.details[detail].content)
                                .font(.custom("Poppins-Medium", size: 16))
                                .foregroundStyle(Color.text.black60)
                        }
                    }
//                    VStack(alignment: .leading) {
//                        
//                        ForEach(package.redemptionSteps.points.indices, id: \.self) { index in
//                            HStack(alignment: .top) {
//                                Text("\(index + 1).")
//                                Text(package.redemptionSteps.points[index])
//                            }
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                            .font(.custom("Poppins-Medium", size: 16))
//                            .foregroundStyle(Color.text.black60)
//                        }
//                    }
//                    Rectangle()
//                        .frame(height: 1)
//                        .foregroundStyle(.black.opacity(0.15))
//                    VStack(alignment: .leading) {
//                        Text(package.aboutSteps.title)
//                            .font(.custom("Poppins-Bold", size: 18))
//                            .foregroundStyle(Color.text.black100)
//                        ForEach(package.aboutSteps.points.indices, id: \.self) { index in
//                            HStack(alignment: .top) {
//                                Text(" • ")
//                                Text(package.aboutSteps.points[index])
//                            }
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                            .font(.custom("Poppins-Regular", size: 16))
//                            .foregroundStyle(Color.text.black60)
//                        }
//                    }
                    if let tos = package.tos {
                        ZStack {
                            VStack(alignment: .leading) {
                                Text("Terms & Conditions")
                                    .font(.custom("Poppins-Bold", size: 18))
                                    .foregroundStyle(Color.text.black100)
                                VStack {
                                    Text(tos)
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
                }
                .padding([.horizontal, .top], 16)
            }
            lowerButton
            
        }
        .customNavigationTitle(package.title)
        .customNavTrailingItem {
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
                                    .padding(.trailing, -4)
                                    .padding(.top, -12)
                            }
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .animation(.default, value: quantity)
                .frame(width: 40, height: 24)
                //                        .background(.green)
            }
            .buttonStyle(EmptyStyle())
        }
        .onAppear(perform: {
            tabIsShown.wrappedValue = false
            viewModel.package = package
            viewModel.api = api
            viewModel.fetch()
        })
    }
}

#Preview {
    PackageDetailView(package: .init(id: .init(uuidString: "4cc469ee-7337-4644-b335-0cb6990a42c2")!, merchant: "Zoomoov", imageURL: nil, title: "Chinese New Year", description: "Some description", summary: "Some summary", price: 1000, originalPrice: 2000, currency: "SGD", details: [], tos: nil))
}
