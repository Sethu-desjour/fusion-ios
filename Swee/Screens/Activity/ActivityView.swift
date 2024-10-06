import SwiftUI

enum ActivityTab {
    case Purchased
    case Redeemed
    
    var emptyDescription: String {
        switch self {
        case .Purchased:
            "You have not made any purchases yet"
        case .Redeemed:
            "You have not redeemed anything yet"
        }
    }
}

struct RedemptionsSection: Hashable {
    let date: Date
    let redemptions: [Redemption]
}

struct PurchasesSection: Hashable {
    let date: Date
    let purchases: [Order]
}

struct ActivityView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.tabIsShown) private var tabIsShown
    @Environment(\.currentTab) private var currentTab
    @EnvironmentObject private var api: API
    
    @StateObject private var viewModel = ActivityViewModel()
    @State private var hideBottomSheet: Bool = true
    @State private var tab = ActivityTab.Purchased
    
    var noData: Bool {
        return viewModel.purchaseSections.isEmpty && 
        viewModel.redemptionSections.isEmpty &&
        viewModel.loadedData &&
        !viewModel.showError
    }
    
    func emptyUI(description: String) -> some View {
        VStack(spacing: 0) {
            Spacer()
            Image("empty-activity")
            Text("It's empty here")
                .font(.custom("Poppins-SemiBold", size: 24))
                .padding(.horizontal, 44)
                .foregroundStyle(Color.text.black100)
                .multilineTextAlignment(.center)
                .padding(.top, 24)
            Text(description)
                .font(.custom("Poppins-Regular", size: 14))
                .padding([.leading, .trailing], 16)
                .foregroundStyle(Color.text.black60)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
            Button {
                dismiss()
                currentTab.wrappedValue = .home
            } label: {
                HStack {
                    Text("Start Exploring")
                        .font(.custom("Roboto-Bold", size: 16))
                }
                .foregroundStyle(Color.background.white)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
                .background(LinearGradient(colors: Color.gradient.primaryDark, startPoint: .topLeading, endPoint: .bottomTrailing))
                .clipShape(Capsule())
            }
            .padding(.horizontal, 22)
            .padding(.top, 60)
            Spacer()
            Spacer()
        }
    }
    
    var currentTabIsEmpty: Bool {
        switch tab {
        case .Purchased:
            viewModel.purchaseSections.isEmpty
        case .Redeemed:
            viewModel.redemptionSections.isEmpty
        }
    }
    
    var mainUI: some View {
        VStack(spacing: 0) {
            GeometryReader { metrics in
                ZStack {
                    HStack {
                        Capsule()
                            .frame(maxWidth: metrics.size.width / 2.2, maxHeight: 45, alignment: .leading)
                            .foregroundStyle(Color.primary.brand)
                    }
                    .frame(maxWidth: .infinity, alignment: tab == .Purchased ? .leading : .trailing)
                    .animation(.default, value: tab)
                    HStack {
                        Button {
                            tab = .Purchased
                        } label: {
                            Text("Purchased")
                                .frame(maxWidth: .infinity)
                                .font(.custom(tab == .Purchased ? "Poppins-Bold" : "Poppins-Medium", size: 14))
                                .foregroundStyle(.white)
                        }
                        //                        .buttonStyle(EmptyStyle())
                        Spacer()
                        Button {
                            tab = .Redeemed
                        } label: {
                            Text("Redeemed")
                                .frame(maxWidth: .infinity)
                                .font(.custom(tab == .Redeemed ? "Poppins-Bold" : "Poppins-Medium", size: 14))
                                .foregroundStyle(.white)
                        }
                        //                        .buttonStyle(EmptyStyle())
                    }
                    .animation(.default, value: tab)
                    
                }
                .background(Capsule()
                    .foregroundStyle(Color.primary.lighter))
                .padding()
            }
            .frame(height: 80)
            if !viewModel.loadedData {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        PurchaseRow.skeleton.equatable.view
                        PurchaseRow.skeleton.equatable.view
                        PurchaseRow.skeleton.equatable.view
                        PurchaseRow.skeleton.equatable.view
                    }
                }
            } else if currentTabIsEmpty {
                emptyUI(description: tab.emptyDescription)
            } else {
                List {
                    if tab == .Purchased {
                        ForEach(Array(viewModel.purchaseSections.enumerated()), id: \.offset) { sectionIndex, section in
                            Section {
                                ForEach(Array(section.purchases.enumerated()), id: \.offset) { index, purchase in
                                    PurchaseRow(purchase: purchase, hideDivider: index == 0)
                                }
                                
                            } header: {
                                ActivitySectionHeader(date: section.date)
                            }
                            
                        }
                        .listRowSeparator(.hidden, edges: .all)
                    } else {
                        ForEach(Array(viewModel.redemptionSections.enumerated()), id: \.offset) { sectionIndex, section in
                            Section {
                                ForEach(Array(section.redemptions.enumerated()), id: \.offset) { index, redemption in
                                    RedemptionRow(redemption: redemption, hideDivider: index == 0)
                                }
                            } header: {
                                ActivitySectionHeader(date: section.date)
                            }
                            
                        }
                        .listRowSeparator(.hidden, edges: .all)
                    }
                    HStack {
                        Rectangle()
                            .fill(Color.text.black10)
                            .frame(height: 1)
                        Text("End of Actvity".uppercased())
                            .font(.custom("Poppins-Medium", size: 10))
                            .foregroundStyle(Color.text.black40)
                        Rectangle()
                            .fill(Color.text.black10)
                            .frame(height: 1)
                    }
                    .padding(.top, 20)
                    .padding([.leading, .trailing], -10)
                    .listRowSeparator(.hidden, edges: .all)
                }
                .listStyle(.inset)
            }
        }
    }
    
    var body: some View {
        ZStack {
            // @todo add error state
            if !noData {
              mainUI
            } else {
               emptyUI(description: "You have not made any actions yet")
            }
        }
        .onAppear(perform: {
            viewModel.api = api
            Task {
                try? await viewModel.fetch()
            }
            tabIsShown.wrappedValue = false
        })
        .customNavigationTitle("My Activity")
        .customNavTrailingItem {
            if noData {
                CartButton()
            } else {
                Button {
                    hideBottomSheet = false
                } label: {
                    Image("filter")
                }
            }
        }
        .customBottomSheet(hidden: $hideBottomSheet) {
            FiltersView()
        }
    }
}

struct FiltersView: View {
    
    enum DateFilters: Int, CaseIterable {
        case Anytime
        case ThisWeek
        case Past30Days
        case Past90Days
        case Past6Months
        case PastYear
        
        func toString() -> String {
            switch self {
            case .Anytime:
                return "Anytime"
            case .ThisWeek:
                return "This Week"
            case .Past30Days:
                return "Past 30 days"
            case .Past90Days:
                return "Past 90 days"
            case .Past6Months:
                return "Past 6 months"
            case .PastYear:
                return "Past year"
            }
        }
    }
    
//    @State private var vendorFilters: Set<Vendors> = [.Zoomoov, .Jollyfield]
    @State private var dateFilter: DateFilters = .Anytime
    
    var body: some View {
        VStack {
            HStack {
                Text("Filter")
                    .font(.custom("Poppins-SemiBold", size: 24))
                Spacer()
                Button {
                    
                } label: {
                    Text("Apply")
                        .font(.custom("Poppins-Medium", size: 16))
                        .foregroundStyle(Color.primary.brand)
                }
            }
            .padding([.leading, .trailing], 8)
            .padding(.top, -16)
            Rectangle()
                .fill(Color.text.black20)
                .frame(height: 1)
                .padding(.bottom)
                .padding([.leading, .trailing], -20)
//            VStack(spacing: 8) {
//                Text("By Merchant")
//                    .font(.custom("Poppins-SemiBold", size: 16))
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                VStack(spacing: 2) {
//                    ForEach(Vendors.allCases, id: \.self) { vendor in
//                        FilterRow(title: vendor.toString(),
//                                  selected: vendorFilters.contains(vendor)) {
//                            if vendorFilters.contains(vendor) {
//                                vendorFilters.remove(vendor)
//                            } else {
//                                vendorFilters.insert(vendor)
//                            }
//                        }
//                    }
//                }
//            }
//            .padding(.bottom)
            VStack(spacing: 8) {
                Text("By Date")
                    .font(.custom("Poppins-SemiBold", size: 16))
                    .frame(maxWidth: .infinity, alignment: .leading)
                VStack(spacing: 2) {
                    ForEach(DateFilters.allCases, id: \.self) { filter in
                        FilterRow(title: filter.toString(),
                                  selected: dateFilter == filter) {
                            dateFilter = filter
                        }
                    }
                }
            }
        }
    }
}

struct FilterRow: View {
    var title: String
    var selected: Bool
    var onTapClosure: () -> Void
    
    var body: some View {
        Button {
            onTapClosure()
        } label: {
            HStack {
                Text(title)
                    .font(.custom("Poppins-Medium", size: 14))
                    .foregroundStyle(selected ? Color.primary.brand : Color.text.black60)
                Spacer()
                Image("checkmark")
                    .hidden(!selected)
            }
        }
        .padding([.trailing, .leading], 12)
        .padding([.top, .bottom], 10)
        .background(selected ? Color.primary.lighter.opacity(0.15) : .white)
    }
    
}

struct ActivitySectionHeader: View {
    @State var date: Date
    
    var body: some View {
        HStack {
            Rectangle()
                .fill(Color.text.black10)
                .frame(height: 1)
            Text("\(date.formatted(date: .abbreviated, time: .omitted))")
                .font(.custom("Poppins-Medium", size: 12))
                .foregroundStyle(Color.text.black40)
            Rectangle()
                .fill(Color.text.black10)
                .frame(height: 1)
        }
        .padding([.leading, .trailing], -10)
    }
}

struct PurchaseRow: View {
    @State var purchase: Order
    @State var hideDivider: Bool = false
    
    var body: some View {
        VStack {
            if !hideDivider {
                Divider()
                    .background(Color.text.black10)
            }
            HStack(spacing: 0) {
                Circle()
                    .foregroundStyle(LinearGradient(
                        colors: Color.gradient.secondary, // @todo change once provided from BE
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 40, height: 40)
                    .overlay {
                        Text(String(purchase.merchantName.first ?? "N"))
                            .foregroundStyle(.white)
                            .font(.custom("Poppins-Bold", size: 16))
                    }
                    .padding(.trailing, 16)
                VStack(alignment: .leading, spacing: 4) {
                    Text(purchase.merchantName)
                        .font(.custom("Poppins-SemiBold", size: 14))
                    Text("\(purchase.quantity) items")
                        .font(.custom("Poppins-SemiBold", size: 12))
                    Text("\(purchase.type.toString) | \(purchase.createdAtDate.formatted(date: .omitted, time: .shortened))")
                        .font(.custom("Poppins-SemiBold", size: 10))
                        .foregroundStyle(Color.text.black40)
                }
                Spacer()
                Text("\(purchase.currencyCode) \(purchase.totalPriceCents / 100)")
                    .font(.custom("Poppins-SemiBold", size: 18))
                    .foregroundStyle(Color.primary.brand)
            }
        }
    }
}

extension PurchaseRow: Skeletonable {
    static var skeleton: any View {
        VStack(alignment: .leading) {
            HStack {
                Color.white
                    .skeleton(with: true, shape: .circle)
                    .frame(width: 40, height: 40)
                VStack(alignment: .leading) {
                    Text("")
                        .skeleton(with: true, shape: .rounded(.radius(12, style: .circular)))
                        .frame(width: 170, height: 20)
                    Text("")
                        .skeleton(with: true, shape: .rounded(.radius(12, style: .circular)))
                        .frame(width: 70, height: 10)
                    Text("")
                        .skeleton(with: true, shape: .rounded(.radius(12, style: .circular)))
                        .frame(width: 70, height: 10)
                }
                Spacer()
                Text("")
                    .skeleton(with: true, shape: .rounded(.radius(12, style: .circular)))
                    .frame(width: 40, height: 30)
            }
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
    }
}

extension OrderType {
    var toString: String {
        switch self {
        case .online:
            return "Online"
        case .otc:
            return "Other the counter"
        }
    }
}

struct RedemptionRow: View {
    @State var redemption: Redemption
    @State var hideDivider: Bool = false
    private var storeAndTime: String {
        let string = "\(redemption.createdAt.formatted(date: .omitted, time: .shortened))"
        guard let storeName = redemption.storeName else {
            return string
        }
        
        return "\(storeName) | " + string
    }
    
    var body: some View {
        VStack {
            if !hideDivider {
                Divider()
                    .background(Color.text.black10)
            }
            HStack(spacing: 0) {
                Circle()
                    .foregroundStyle(LinearGradient(
                        colors: Color.gradient.secondary, // @todo change for BE content
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 40, height: 40)
                    .overlay {
                        Text("Z") // @todo change with BE content
                            .foregroundStyle(.white)
                            .font(.custom("Poppins-Bold", size: 16))
                    }
                    .padding(.trailing, 16)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Zoomoov ride") // @todo change with BE content
                        .font(.custom("Poppins-SemiBold", size: 14))
                    Text(storeAndTime)
                        .font(.custom("Poppins-SemiBold", size: 10))
                        .foregroundStyle(Color.text.black40)
                }
                Spacer()
                Text("- \(redemption.value) Rides") // @todo change with BE content
                    .font(.custom("Poppins-SemiBold", size: 14))
                    .foregroundStyle(Color.secondary.brand)
            }
            .padding(.top, 10)
        }
    }
}

#Preview {
    CustomNavView {
        ActivityView()
    }
}
