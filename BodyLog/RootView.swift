import SwiftUI

struct RootView: View {
    @AppStorage("AppLockEnabled") private var appLockEnabled = false
    @State private var isUnlocked = false

    var body: some View {
        ZStack {
            HomeView()
                .opacity(showHome ? 1 : 0)

            if appLockEnabled && !isUnlocked {
                LockView(isUnlocked: $isUnlocked)
                    .transition(.opacity)
            }
        }
        .onAppear {
            // 未开启应用锁时直接放行；开启则等待 LockView 解锁。
            if !appLockEnabled {
                isUnlocked = true
            }
        }
    }

    private var showHome: Bool {
        !appLockEnabled || isUnlocked
    }
}
