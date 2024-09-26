import SwiftUI

struct StoresView: View {
    var stores: [MerchantStore]
    
    var body: some View {
        VStack(spacing: 0) {
            Text("\(stores.count) Locations")
                .font(.custom("Poppins-SemiBold", size: 24))
                .foregroundStyle(Color.text.black100)
                .padding(.bottom, 24)
            ScrollView {
                ForEach(stores) { store in
                    HStack {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("•  \(store.name)")
                                .font(.custom("Poppins-Bold", size: 16))
                                .foregroundStyle(Color.text.black80)
                                .padding(.bottom, 3)
                            if let address = store.address {
                                Text(address)
                                    .font(.custom("Poppins-Regular", size: 12))
                                    .foregroundStyle(Color.text.black60)
                                    .padding(.leading, 15)
                                    .padding(.bottom, 3)
                            }
                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 5)
            }
            .frame(height: 300)
        }
    }
}
