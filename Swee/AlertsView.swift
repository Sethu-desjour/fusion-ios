import SwiftUI

enum Routes {
    case profile
    case merchant(_ id: String)
}

struct AlertsView: View {
    protocol AlertType {
        var title: String { get }
        var read: Bool { get set }
    }
    
    struct Action {
        let title: String
        let route: Routes
    }
    
    struct LocalCTA: AlertType {
        var read: Bool
        let title: String
        var image: Image?
        var description: String?
        var action: Action?
    }
    
    struct RedeemActivity: AlertType {
        var read: Bool
        let title: String
        let interval: TimeInterval
        let merchant: String
    }
    
    struct Announcement: AlertType {
        var read: Bool
        let title: String
        var description: String?
        var action: Action?
        let merchant: String
        var image: Image?
    }
    
    enum Alert {
        case localCTA(LocalCTA)
        case redeemActivity(RedeemActivity)
        case announcement(Announcement)
    }
    
    @Environment(\.tabIsShown) private var tabIsShown
    @Environment(\.currentTab) private var selectedTab
    @State private var goToMerchant: Bool = false
    @State private var nrOfAlerts: Int = 6
    @State private var alerts: [Alert] = [
        .localCTA(.init(read: false, title: "Complete your profile and win 1 zoomoov ride", action: .init(title: "Complete profile", route: .profile))),
        .redeemActivity(.init(read: true, title: "Jollyride active", interval: 8000, merchant: "Jollyfield")),
        .announcement(.init(read: true, title: "Zoomoov is now on Swee", description: "We’re pleased to introduce that Zoomoov is now available in Swee", action: .init(title: "Explore", route: .merchant("Some id")), merchant: "Zoomoov", image: Image("alert-avatar"))),
        .announcement(.init(read: true, title: "Celebrate your kids birthday at any of the Zoomoov location!", description: "50% off on all Zoomoov packages", merchant: "Zoomoov")),
    ]
    
    func handle(route: Routes) -> Void {
        switch route {
        case .profile:
            selectedTab.wrappedValue = .profile
        case .merchant(_):
            goToMerchant = true
        }
    }
    
    func row(at index: Int) -> any View {
        switch alerts[index] {
        case .localCTA(let cta):
            return AlertRow(index: index,
                            read: cta.read,
                            title: cta.title,
                            description: cta.description,
                            image: cta.image,
                            action: cta.action.toClosure({ route in
                handle(route: route)
            }))
        case .redeemActivity(let activity):
            return AlertRow(index: index,
                            read: activity.read,
                            title: activity.title,
                            merchant: activity.merchant,
                            activityInterval: activity.interval)
        case .announcement(let announcement):
            return AlertRow(index: index,
                            read: announcement.read,
                            title: announcement.title,
                            description: announcement.description,
                            image: announcement.image,
                            merchant: announcement.merchant,
                            action: announcement.action.toClosure({ route in
                handle(route: route)
            }))
        }
    }
    
    var body: some View {
        CustomNavView {
            VStack {
                ScrollView {
                    ForEach(alerts.indices, id: \.self) { index in
                        row(at: index).equatable.view
                    }
                    CustomNavLink(isActive: $goToMerchant, destination: MerchantPageView()) {
                    }
                }
            }
            .onWillAppear {
                tabIsShown.wrappedValue = true
            }
            .customNavigationBackButtonHidden(true)
            .customNavLeadingItem {
                HStack(alignment: .center, spacing: 4) {
                    Text("Alerts")
                        .font(.custom("Poppins-SemiBold", size: 20))
                    Text("(\(nrOfAlerts))")
                        .font(.custom("Poppins-SemiBold", size: 16))
                        .foregroundStyle(Color.text.black60)
                }
            }
            .customNavTrailingItem {
                Button {
                    // @todo mark as read
                } label: {
                    Text("Mark all as read")
                        .font(.custom("Poppins-Medium", size: 14))
                }
                .tint(Color.primary.brand)
            }
        }
    }
}

fileprivate extension Optional where Wrapped == AlertsView.Action {
    func toClosure(_ closure: @escaping (Routes) -> Void) -> AlertRow.Action? {
        switch self {
        case .none:
            return nil
        case .some(let action):
            return .init(title: action.title, closure: {
                closure(action.route)
            })
        }
    }
}

struct AlertRow: View {
    struct Action {
        let title: String
        let closure: () -> Void
    }
    
    var read: Bool
    var title: String
    var description: String?
    var image: Image?
    var merchant: String?
    @State var activityInterval: TimeInterval?
    var action: Action?
    var index: Int
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    init(index: Int,
         read: Bool = true,
         title: String,
         description: String? = nil,
         image: Image? = nil,
         merchant: String? = nil,
         activityInterval: TimeInterval? = nil,
         action: Action? = nil) {
        self.index = index
        self.title = title
        self.description = description
        self.image = image
        self.merchant = merchant
        self.activityInterval = activityInterval
        self.action = action
        self.read = read
    }
    
    private var avatar: any View {
        ZStack {
            if !read {
                Circle()
                    .foregroundStyle(Color.primary.brand)
                    .frame(width: 8, height: 8)
                    .padding(.leading, -40)
            }
            if let image = image {
                image
            } else if let merchant = merchant, !merchant.isEmpty {
                Circle()
                    .foregroundStyle(Color.text.black20)
                    .frame(width: 48, height: 48)
                    .overlay {
                        Text(String(merchant.first!))
                            .foregroundStyle(Color.text.black60)
                            .font(.custom("Poppins-SemiBold", size: 20))
                    }
            } else {
                Circle()
                    .foregroundStyle(Color.random())
                    .frame(width: 48, height: 48)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if index != 0 {
                Rectangle()
                    .fill(Color.text.black10)
                    .frame(height: 1)
                    .padding(.leading, 65)
                    .padding(.trailing, -20)
                Spacer()
            }
            HStack(alignment: .top) {
                avatar.equatable.view
                    .padding(.leading, 8)
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.custom("Poppins-SemiBold", size: 14))
                    if let description = description {
                        Text(description)
                            .font(.custom("Poppins-Regular", size: 14))
                    }
                    if let unwrappedInterval = activityInterval {
                        HStack() {
                            RoundedRectangle(cornerRadius: 1)
                                .fill(Color.text.black10)
                                .frame(width: 4, height: 40)
                            
                            Text(unwrappedInterval.toString(includeSeconds: true))
                                .font(.custom("Poppins-Regular", size: 24)) +
                            Text(" Hrs")
                                .font(.custom("Poppins-Regular", size: 14))
                        }
                        .onReceive(timer, perform: { _ in
                            if unwrappedInterval > 0 {
                                activityInterval = unwrappedInterval - 1
                            }
                        })
                    }
                    if let action = action {
                        Button {
                            action.closure()
                        } label: {
                            Text(action.title)
                                .font(.custom("Poppins-Medium", size: 14))
                                .foregroundStyle(Color.background.white)
                                .padding(.vertical, 5.5)
                                .padding(.horizontal, 14)
                                .background(Color.primary.brand)
                                .clipShape(Capsule())
                        }
                    }
                }
                Spacer()
                VStack(spacing: 0) {
                    Text("2m")
                        .font(.custom("Poppins-Thin", size: 12))
                    Image("ellipsis")
                    Spacer()
                }
            }
            .padding(.vertical, 24)
            Spacer()
        }
        .padding(.horizontal)
        .background(read ? .white : Color(hex: "#EDF3FF"))
    }
}


#Preview {
    AlertsView()
}


extension Color {
    
    static func random(randomOpacity: Bool = false) -> Color {
        Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1),
            opacity: randomOpacity ? .random(in: 0...1) : 1
        )
    }
}
