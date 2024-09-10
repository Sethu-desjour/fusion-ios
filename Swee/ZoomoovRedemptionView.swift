import SwiftUI

struct Ticket: Hashable {
    let merchant: String
    let quantity: Int
    let description: String
    let type: String
    let expirationDate: Date
    let colors: [Color]
}

enum ZoomoovRedemptionSteps {
    case setup
    case redemptionQueue
    case loading
    // case error @todo maybe?
    case completed
}

struct ZoomoovRedemptionModel {
    var totalQuantity: Int
    var qtyToRedeem: Int = 1
    var currentTicket: Int = 1
    let merchant: String
    let type: String
    let disclaimer: String
}

struct ZoomoovRedemptionSetupView: View {
    @Binding var model: ZoomoovRedemptionModel
    var closure: (() -> Void)? = nil
    
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
                Text(model.disclaimer)
                    .font(.custom("Poppins-Medium", size: 14))
                    .foregroundStyle(Color.text.black80)
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(Color.background.pale))
            .padding(.bottom, 37)
            Button {
                // @todo make request
                closure?()
            } label: {
                HStack {
                    Text("Redeem now")
                        .font(.custom("Roboto-Bold", size: 16))
                }
                .foregroundStyle(Color.background.white)
                .padding(.vertical, 18)
                .frame(maxWidth: .infinity)
                .background(LinearGradient(colors: Color.gradient.primaryDark, startPoint: .topLeading, endPoint: .bottomTrailing))
                .clipShape(Capsule())
            }
            .padding(.bottom, 16)
            //            .buttonStyle(EmptyStyle())
        }
    }
}

struct ZoomoovRedemptionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.tabIsShown) private var tabIsShown
    
    @State var tempQuantity = 1
    @State var tempCurrentRide = 1
    @State var tempStep: ZoomoovRedemptionSteps = .setup
    @State var tempModel: ZoomoovRedemptionModel = .init(totalQuantity: 4,
                                                         merchant: "Zoomoov",
                                                         type: "rides",
                                                         disclaimer: "Ride cannot be refunded, or anything that the parent should be aware of will take up this space.")
    @State var hidden = true
    
    @State var tickets: [Ticket]
    
    var shouldDismissOnTap: Bool {
        switch tempStep {
        case .setup:
            return true
        case .redemptionQueue:
            return true
        case .loading:
            return false
        case .completed:
            return false
        }
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 24) {
                    ForEach(tickets, id: \.self) { ticket in
                        VStack(alignment: .leading, spacing: 0) {
                            Text(ticket.type)
                                .font(.custom("Poppins-SemiBold", size: 20))
                            TicketView(ticket: ticket)
                                .onTapGesture {
                                    hidden = false
                                }
                        }
                    }
                }
                .padding([.horizontal, .top], 16)
                .navigationBarBackButtonHidden(true)
                .navigationBarTitleDisplayMode(.inline)
            }
            .onWillAppear({
                tabIsShown.wrappedValue = false
            })
            .background(Color.background.pale)
            BottomSheet(hide: $hidden, shouldDismissOnBackgroundTap: shouldDismissOnTap) {
                switch $tempStep.wrappedValue {
                case .setup:
                    ZoomoovRedemptionSetupView(model: $tempModel) {
                        $tempStep.wrappedValue = .redemptionQueue
                    }
                case .redemptionQueue:
                    RedemptionScanView(model: .init(header: "\(tempModel.type.capitalized) \(tempModel.currentTicket)/\(tempModel.qtyToRedeem)",
                                                    title: "Scan QR to start your ride",
                                                    qr: Image("qr"),
                                                    description: "Show this QR code at the counter, our staff will scan this QR to mark your presence",
                                                    actionTitle: "Next QR")) {
                        $tempStep.wrappedValue = .loading
                    }
                case .loading:
                    RedemptionLoadingView(model: .init(header: "",
                                                       title: "Scanning for \(tempModel.type.capitalized) \(tempModel.currentTicket)")) {
                        if tempModel.currentTicket == tempModel.qtyToRedeem {
                            $tempStep.wrappedValue = .completed
                        } else {
                            tempModel.currentTicket += 1
                            $tempStep.wrappedValue = .redemptionQueue
                        }
                    }
                case .completed:
                    RedemptionCompletedView(model: .init(header: "\(tempModel.type.capitalized) \(tempModel.currentTicket)/\(tempModel.qtyToRedeem)",
                                                         title: "\(tempModel.qtyToRedeem) Coupons redeemed successfully!",
                                                         description: "",
                                                         actionTitle: "Done")) {
                        hidden = true
                        $tempStep.wrappedValue = .setup
                    }
                }
            }
        }
        .customNavigationTitle(tickets[0].merchant)
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
    @State var ticket: Ticket
    
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
                        Text(" " + ticket.description)
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

#Preview {
    CustomNavView {
        ZoomoovRedemptionView(tickets: [
            .init(merchant: "Zoomoov", quantity: 12, description: "Rides", type: "Rides", expirationDate: Date(), colors: Color.gradient.primary),
            .init(merchant: "Zoomoov", quantity: 1, description: "Masks", type: "Mask", expirationDate: Date(), colors: [Color(hex: "#EC048A"), Color(hex: "#F0971C")])
        ]
        )
    }
}
