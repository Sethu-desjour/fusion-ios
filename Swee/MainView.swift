import SwiftUI

struct MainView: View {
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "list.dash")
                }
        }
    }
}

#Preview {
    MainView()
}
