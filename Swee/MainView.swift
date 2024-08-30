import SwiftUI

enum Tabs: Int, CaseIterable{
    case home = 0
    case purchases
    case alerts
    case profile
    
    var title: String{
        switch self {
        case .home:
            return "Home"
        case .purchases:
            return "My Purchases"
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
}

enum NotificationUpsellNamespace {}
enum ActivityFiltersNamespace {}
enum TabBarNamespace {}

struct MainView: View {
    @State var selectedTab = 0
    @StateObject private var hideNotificationUpsell = ObservableWrapper<Bool, NotificationUpsellNamespace>(true)
    @StateObject private var hideActivityFilters = ObservableWrapper<Bool, ActivityFiltersNamespace>(true)
    @StateObject private var hideTabBar = ObservableWrapper<Bool, TabBarNamespace>(false)
    
    func TabItem(imageName: String, title: String, isActive: Bool) -> some View {
            VStack {
                Image(imageName)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(Color.text.black60)
                    .frame(width: 24, height: 24)
                Text(title)
                    .font(isActive ? .custom("Roboto-Bold", size: 12) : .custom("Roboto-Medium", size: 12))
                    .foregroundStyle(isActive ? Color.primary.brand : Color.text.black60)
            }
            .animation(.default, value: selectedTab)
            .frame(maxWidth: 100, maxHeight: 50)
    }
    
    var body: some View {
        
        NavigationView {
        ZStack(alignment: .bottom) {
                TabView(selection: $selectedTab) {
                    HomeView()
                        .tag(0)
                    ActivityView()
                        .tag(1)
                    CompleteProfileView()
                        .tag(2)
                    HomeView()
                        .tag(3)
                }
                
                ZStack {
                    VStack(spacing: 0) {
                        HStack {
                            ForEach((Tabs.allCases.indices), id: \.self) { index in
                                Rectangle()
                                    .fill(selectedTab == index ? Color.primary.brand : .clear)
                                    .frame(maxWidth: .infinity, maxHeight: 1)
                                    .padding([.leading, .trailing], 20)
                                    .animation(.default, value: selectedTab)
                            }
                        }
                        HStack{
                            ForEach((Tabs.allCases), id: \.self){ item in
                                Button{
                                    selectedTab = item.rawValue
                                } label: {
                                    TabItem(imageName: item.iconName, title: item.title, isActive: (selectedTab == item.rawValue))
                                }
                                .buttonStyle(EmptyStyle())
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .background(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.15), radius: 15, y: 5)
                    }
                }
                .hidden(hideTabBar.prop)
            BottomSheet(hide: $hideNotificationUpsell.prop) {
                NotificationUpsell(hide: $hideNotificationUpsell.prop)
            }
            BottomSheet(hide: $hideActivityFilters.prop) {
                FiltersView()
            }
            }
        }
        .environmentObject(hideNotificationUpsell)
        .environmentObject(hideActivityFilters)
        .environmentObject(hideTabBar)
    }
}

#Preview {
    MainView()
}
