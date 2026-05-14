import SwiftUI

struct MainTabView: View {
    @State private var selection: Int = 0
    @State private var todayPath = NavigationPath()
    @State private var homePath = NavigationPath()

    var body: some View {
        TabView(selection: $selection) {
            TodayView(path: $todayPath)
                .tabItem {
                    Label("首页", systemImage: "house.fill")
                }
                .tag(0)

            HomeView(path: $homePath)
                .tabItem {
                    Label("追踪", systemImage: "square.stack.fill")
                }
                .tag(1)
        }
        .tint(BrandColor.primary)
        .onChange(of: selection) { _ in
            todayPath = NavigationPath()
            homePath = NavigationPath()
        }
    }
}
