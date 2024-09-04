import SwiftUI

struct Ticket: Hashable {
    let merchant: String
    let quantity: Int
    let description: String
    let type: String
    let expirationDate: Date
    let colors: [Color]
}

struct TicketsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.tabIsShown) private var tabIsShown

    @State var uiNavController: UINavigationController?
    @State var tickets: [Ticket]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    ForEach(tickets, id: \.self) { ticket in
                        VStack(alignment: .leading, spacing: 0) {
                            Text(ticket.type)
                                .font(.custom("Poppins-SemiBold", size: 20))
                            TicketView(ticket: ticket)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .navigationBarBackButtonHidden(true)
                .navigationBarTitleDisplayMode(.inline)
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
                    Text(tickets[0].merchant)
                        .font(.custom("Poppins-Bold", size: 18))
                        .foregroundStyle(Color.text.black100)
                        .padding(.bottom, 10)
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
            })
            .background(Color.background.pale)
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
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
    TicketsView(tickets: [
        .init(merchant: "Zoomoov", quantity: 12, description: "Rides", type: "Rides", expirationDate: Date(), colors: Color.gradient.primary),
        .init(merchant: "Zoomoov", quantity: 1, description: "Masks", type: "Mask", expirationDate: Date(), colors: [Color(hex: "#EC048A"), Color(hex: "#F0971C")])
    ]
    )
}

struct ZoomoovRedemptionUpsell: View {
    var body: some View {
        VStack {
            Text("Zoomoov rides")
        }
    }
}
