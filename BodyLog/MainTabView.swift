import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            TodayView()
                .tabItem {
                    Label("首页", systemImage: "house.fill")
                }

            HomeView()
                .tabItem {
                    Label("追踪", systemImage: "square.stack.fill")
                }
        }
        .tint(Color.accentBlue)
    }
}
