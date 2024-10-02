import SwiftUI

struct Ticket: Hashable {
    let merchant: String
    let quantity: Int
    let type: String
    let expirationDate: Date
    let colors: [Color]
}

enum ZoomoovRedemptionSteps {
    case setup
    case redemptionQueue(Redemption)
    case loading
    // case error @todo maybe?
    case completed
}

struct ZoomoovRedemptionModel {
    let purchaseId: UUID
    var totalQuantity: Int
    var qtyToRedeem: Int = 1
    var currentTicket: Int = 1
    let merchant: String
    let type: String
    let disclaimer: String?
    let productType: ProductType
}

struct ZoomoovRedemptionSetupView: View {
    @Binding var model: ZoomoovRedemptionModel
//    var purchase: Purchase
    var closure: () async throws -> Void
    
    var body: some View {
        VStack {
            Text("\(model.merchant) \(model.type)")
                .font(.custom("Poppins-SemiBold", size: 24))
            HStack {
                Text("\(model.type.capitalized) quantity")
                    .font(.custom("Poppins-Medium", size: 16))
                    .foregroundStyle(Color.text.black60)
                Spacer()
                HStack {
                    Button {
                        if model.qtyToRedeem == 1 {
                            return
                        }
                        model.qtyToRedeem -= 1
                    } label: {
                        Image("minus-circle")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                    .tint(model.qtyToRedeem == 1 ? Color.text.black20 : Color.secondary.brand)
                    Spacer()
                    Text("\(model.qtyToRedeem)")
                        .font(.custom("Poppins-Medium", size: 20))
                        .foregroundStyle(Color.secondary.brand)
                        .lineLimit(1)
                    Spacer()
                    Button {
                        if model.qtyToRedeem == model.totalQuantity {
                            return
                        }
                        model.qtyToRedeem += 1
                    } label: {
                        Image("plus-circle")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                    .tint(model.qtyToRedeem == model.totalQuantity ? Color.text.black20 : Color.secondary.brand)
                }
                .frame(width: 100)
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(Color.background.pale))
            
            VStack(alignment: .leading) {
                Text("Note:")
                    .font(.custom("Poppins-Bold", size: 18))
                    .foregroundStyle(Color.text.black100)
                if let disclaimer = model.disclaimer {
                    Text(disclaimer)
                        .font(.custom("Poppins-Medium", size: 14))
                        .foregroundStyle(Color.text.black80)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(Color.background.pale))
            .padding(.bottom, 37)
            AsyncButton(progressWidth: .infinity) {
                try? await closure()
            } label: {
                HStack {
                    Text("Redeem now")
                        .font(.custom("Roboto-Bold", size: 16))
                }
            }
            .foregroundStyle(Color.background.white)
            .padding(.vertical, 18)
            .frame(maxWidth: .infinity)
            .background(Color.secondary.brand)
            .clipShape(Capsule())
            .padding(.bottom, 16)
            //            .buttonStyle(EmptyStyle())
        }
    }
}

struct ZoomoovBottomSheet: View {
    @EnvironmentObject var api: API
    @State var step: ZoomoovRedemptionSteps = .setup
    @Binding var model: ZoomoovRedemptionModel
    private var successfulScans: Int {
        redemptions.filter { $0.status == .success }.count
    }
    @State private var redemptions: [Redemption] = []
    
    var onComplete: () -> Void
    
    func poll(for redemption: Redemption) {
        print("polling for \(redemption.id.uuidString.lowercased()).....")
        Task {
            let status = try await checkRedemptionStatus(for: redemption.id)
            guard status != .success else {
                print("poll successful for \(redemption.id.uuidString.lowercased())")
                return
            }
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            poll(for: redemption)
        }
    }
    
    func checkRedemptionStatus(for id: UUID) async throws -> RedemptionStatus {
        let redemptionUpdate = try await api.checkRedemptionStatus(for: id)
        await MainActor.run {
            if redemptionUpdate.status == .success, let index = redemptions.firstIndex(where: { $0.id == id }) {
                redemptions[index] = redemptionUpdate.toRedemption()
                goToNextRedemption()
            }
        }
        
        return redemptionUpdate.status
    }
    
    func goToNextRedemption() {
        if let nextRedemption = redemptions.first(where: { $0.status != .success }) {
            step = .redemptionQueue(nextRedemption)
            poll(for: nextRedemption)
        } else {
            step = .completed
        }
    }
    
    var body: some View {
        switch step {
        case .setup:
            ZoomoovRedemptionSetupView(model: $model) {
                do {
                    let redemptions = try await api.startRedemptions(for: model.purchaseId,
                                                                     quantity: model.qtyToRedeem)
                    .map { $0.toRedemption() }
                    await MainActor.run {
                        self.redemptions = redemptions
                        guard !redemptions.isEmpty else {
                            // @todo show error screen
                            return
                        }
                        goToNextRedemption()
                    }
                } catch {
                    print("error =======", error)
                    // @todo show error screen
                }
            }
        case .redemptionQueue(let redemption):
            RedemptionScanView(model: .init(header: "\(model.type.capitalized) \(successfulScans + 1)/\(model.qtyToRedeem)",
                                            title: model.productType == .coupon ? "Scan QR to start your ride" : "Scar QR to get a mask", // @todo this should be optimized from BE
                                            qr: redemption.qrCodeImage,
                                            description: model.productType == .coupon ? "Show this QR code at the counter, our staff will scan this QR to mark your presence" : "Show this QR code at the counter, our staff will scan this QR to provide you the mask", // @todo this as well
                                            actionTitle: "Next QR")) {
                
                do {
                    // @todo NEEDS TO BE DELETED
//                    try? await api.DEBUGchangeRedemptionStatus(for: redemption.id, merchantId: .init())
                    // @todo NEEDS TO BE DELETED
                    
                    let status = try await checkRedemptionStatus(for: redemption.id)
                    guard status != .success else { return }
                    // @todo what do we show when it hasn't been scanned yet?
                } catch {
                    // @todo show error screen
                }
//                step = .loading
            }
        case .loading:
            RedemptionLoadingView(model: .init(header: "",
                                               title: "Scanning for \(model.type.capitalized) \(model.currentTicket)")) {
                if model.currentTicket == model.qtyToRedeem {
                    step = .completed
                } else {
                    model.currentTicket += 1
//                    step = .redemptionQueue
                }
            }
        case .completed:
            RedemptionCompletedView(model: .init(header: "\(model.type.capitalized) \(successfulScans)/\(model.qtyToRedeem)",
                                                 title: "\(model.qtyToRedeem) Coupons redeemed successfully!",
                                                 description: "",
                                                 actionTitle: "Done")) {
                onComplete()
                step = .setup
            }
        }
        
    }
}

struct ZoomoovRedemptionView: View {
    @Environment(\.tabIsShown) private var tabIsShown
    @EnvironmentObject private var api: API
    @StateObject private var viewModel = ZoomoovRedemptionViewModel()
    @State var merchant: MyWalletMerchant
    
    @State var step: ZoomoovRedemptionSteps = .setup
    @State var currentRedemption: ZoomoovRedemptionModel = .init(purchaseId: .init(),
                                                                 totalQuantity: 10,
                                                                 merchant: "Zoomoov",
                                                                 type: "rides",
                                                                 disclaimer: "Ride cannot be refunded, or anything that the parent should be aware of will take up this space.",
                                                                 productType: .coupon)
    
    @State var hidden = true
    
//    var shouldDismissOnTap: Bool {
//        switch tempStep {
//        case .setup:
//            return true
//        case .redemptionQueue:
//            return true
//        case .loading:
//            return false
//        case .completed:
//            return false
//        }
//    }
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 24) {
                    ForEach(viewModel.merchant.products, id: \.id) { product in
                        VStack(alignment: .leading, spacing: 0) {
                            Text(product.name)
                                .font(.custom("Poppins-SemiBold", size: 20))
                            ForEach(product.purchases, id: \.id) { purchase in
                                TicketView(ticket: .init(merchant: viewModel.merchant.name,
                                                         quantity: purchase.remainingValue,
                                                         type: product.name,
                                                         expirationDate: purchase.expiresAt,
                                                         colors: Color.gradient.secondary /*merchant.bgColors*/)) // @todo change back to using the merchant colors
                                    .onTapGesture {
                                        currentRedemption = .init(purchaseId: purchase.id,
                                                                  totalQuantity: purchase.remainingValue,
                                                                  merchant: viewModel.merchant.name,
                                                                  type: product.name,
                                                                  disclaimer: purchase.note,
                                                                  productType: product.type)
                                        hidden = false
                                    }
                            }
                        }
                    }
                }
                .padding([.horizontal, .top], 16)
                .navigationBarBackButtonHidden(true)
                .navigationBarTitleDisplayMode(.inline)
            }
            .onAppear(perform: {
                viewModel.api = api
                viewModel.merchant = merchant
                Task {
                    try? await viewModel.fetch()
                }
                tabIsShown.wrappedValue = false
            })
            .background(Color.background.pale)
        }
        .customNavigationTitle(viewModel.merchant.name)
        .customBottomSheet(hidden: $hidden) {
            ZoomoovBottomSheet(model: $currentRedemption) {
                Task {
                    try? await viewModel.fetch()
                }
                hidden = true
            }
        }
    }
}

struct TicketShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let cornerRadius: CGFloat = 12
        let notchSize: CGFloat = 15
        let notchOffset: CGFloat = 44 + notchSize / 2
        
        path.addRoundedRect(in: rect, cornerSize: CGSize(width: cornerRadius, height: cornerRadius))
        
        // Add the top-left notch
        path.move(to: CGPoint(x: rect.minX + notchOffset, y: rect.minY))
        path.addArc(center: CGPoint(x: rect.minX + notchOffset, y: rect.minY),
                    radius: notchSize,
                    startAngle: .degrees(180),
                    endAngle: .degrees(0),
                    clockwise: true)
        
        // Add the bottom-left notch
        path.move(to: CGPoint(x: rect.minX + notchOffset, y: rect.maxY))
        path.addArc(center: CGPoint(x: rect.minX + notchOffset, y: rect.maxY),
                    radius: notchSize,
                    startAngle: .degrees(0),
                    endAngle: .degrees(180),
                    clockwise: true)
        
        path.move(to: CGPoint(x: rect.minX + notchOffset, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        
        return path
    }
}

struct DottedLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        return path
    }
}


struct TicketView: View {
    var ticket: Ticket
    
    private let ticketHeight: CGFloat = 126
    private let notchSize: CGFloat = 15
    var notchOffset: CGFloat {
        return 44 + notchSize / 2
    }
    var body: some View {
        ZStack {
            TicketShape()
                .fill(LinearGradient(gradient: Gradient(colors: ticket.colors), startPoint: .topLeading, endPoint: .bottomTrailing).opacity(0.2))
                .frame(maxWidth: .infinity, maxHeight: ticketHeight)
                .padding([.top], 18)
                .padding([.leading], 8)
            TicketShape()
                .fill(LinearGradient(gradient: Gradient(colors: ticket.colors), startPoint: .topLeading, endPoint: .bottomTrailing).opacity(0.45))
                .frame(maxWidth: .infinity, maxHeight: ticketHeight)
                .padding([.top], 10)
                .padding([.leading, .trailing], 4)
            TicketShape()
                .fill(LinearGradient(gradient: Gradient(colors: ticket.colors), startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(maxWidth: .infinity, maxHeight: ticketHeight)
                .padding(.trailing, 8)
                .overlay(
                    DottedLine()
                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [8]))
                        .frame(width: 1, height: ticketHeight - notchSize * 2 - 10)
                        .foregroundColor(.black.opacity(0.25))
                        .position(CGPoint(x: notchOffset, y: ticketHeight / 2))
                )
                .overlay(
                    Text(ticket.merchant.uppercased())
                        .padding(.horizontal, 10)
                        .frame(width: 126)
                        .font(.custom("Poppins-SemiBold", size: 14))
                        .foregroundStyle(.black.opacity(0.3))
                        .transformEffect(.init(rotationAngle: -1.5708))
                        .position(CGPoint(x: 75, y: 136))
                        .lineLimit(1)
                )
            
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: -10) {
                    VStack {
                        Text("\(ticket.quantity)")
                            .font(.custom("Poppins-SemiBold", size: 66))
                        +
                        Text(" " + ticket.type)
                            .font(.custom("Poppins-Bold", size: 24))
                    }
                    .addInnerShadow()
                    VStack {
                        Text("Valid until  ")
                            .font(.custom("Poppins-SemiBold", size: 12))
                            .foregroundColor(.white.opacity(0.5)) +
                        Text("\(ticket.expirationDate.formatted(date: .abbreviated, time: .omitted))")
                            .font(.custom("Poppins-SemiBold", size: 12))
                            .foregroundColor(.white.opacity(0.86))
                    }
                    .padding(.leading, 8)
                }
                Spacer()
                Image("double-chevron")
                    .foregroundStyle(.white)
            }
            .padding(.leading, 90)
            .padding([.trailing, .bottom], 24)
        }
        .frame(height: ticketHeight + 20)
        //        .padding()
    }
    
}

//#Preview {
//    CustomNavView {
//        ZoomoovRedemptionView(tickets: [
//            .init(merchant: "Zoomoov", quantity: 12, description: "Rides", type: "Rides", expirationDate: Date(), colors: Color.gradient.primary),
//            .init(merchant: "Zoomoov", quantity: 1, description: "Masks", type: "Mask", expirationDate: Date(), colors: [Color(hex: "#EC048A"), Color(hex: "#F0971C")])
//        ]
//        )
//    }
//}
