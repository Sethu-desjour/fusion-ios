import SwiftUI

enum Tabs: Int, CaseIterable, Identifiable {
    
    case home = 0
    case purchases
    case alerts
    case profile
    
    @ViewBuilder
    var screen: some View {
        switch self {
        case .home:
            HomeView()
        case .purchases:
            MyPurchasesView()
        case .alerts:
            CompleteProfileView()
        case .profile:
            HomeView()
        }
    }
    
    var title: String{
        switch self {
        case .home:
            return "Home"
        case .purchases:
            return "My Wallet"
        case .alerts:
            return "Alerts"
        case .profile:
            return "Profile"
        }
    }
    
    var iconName: String{
        switch self {
        case .home:
            return "home"
        case .purchases:
            return "purchases"
        case .alerts:
            return "alerts"
        case .profile:
            return "profile"
        }
    }
    
    var id: Tabs { self }
}

struct MainView: View {
    @State private var selectedTab: Tabs = .home
    @State private var showTabBar = true
//    @State private var bottomSheetData: BottomSheetData = .init(view: FiltersView().equatable)
    
    func TabItem(imageName: String, title: String, isActive: Bool) -> some View {
        VStack {
            Image(isActive ? "\(imageName)"+"-active" : imageName)
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(isActive ? Color.primary.brand : Color.text.black60)
                .frame(width: 24, height: 24)
            Text(title)
                .font(isActive ? .custom("Poppins-Medium", size: 12) : .custom("Poppins-SemiBold", size: 12))
                .foregroundStyle(isActive ? Color.primary.brand : Color.text.black60)
        }
        .animation(.default, value: selectedTab)
        .padding(.top, 7)
        .frame(maxWidth: 100, maxHeight: 60)
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                ForEach(Tabs.allCases) { tab in
                    tab.screen
                        .tag(tab as Tabs?)
                }
            }
            ZStack {
                VStack(spacing: 0) {
//                    HStack {
//                        ForEach((Tabs.allCases), id: \.self) { tab in
//                            Rectangle()
//                                .fill(selectedTab == tab ? Color.primary.brand : .clear)
//                                .frame(maxWidth: .infinity, maxHeight: 1)
//                                .padding([.leading, .trailing], 20)
//                                .animation(.default, value: selectedTab)
//                        }
//                    }
                    HStack{
                        Spacer()
                        ForEach((Tabs.allCases), id: \.self){ item in
                            Button{
                                selectedTab = item
                            } label: {
                                TabItem(imageName: item.iconName, title: item.title, isActive: (selectedTab == item))
                            }
                            .buttonStyle(EmptyStyle())
                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .background(.ultraThickMaterial)
                    .compositingGroup()
                    .shadow(color: .black.opacity(0.15), radius: 2, y: -2)
                }
            }
            .hidden(!showTabBar)
//            BottomSheet(hide: bottomSheetData.hidden) {
//                bottomSheetData.view.view
//            }
        }
        .environment(\.tabIsShown, $showTabBar)
        .environment(\.currentTab, $selectedTab)
//        .environment(\.bottomSheetData, $bottomSheetData)
    }
}

#Preview {
    MainView()
}
