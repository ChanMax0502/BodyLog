import SwiftUI

struct LockView: View {
    @Binding var isUnlocked: Bool

    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()
            VStack(spacing: AppSpacing.xl) {
                Image(systemName: iconName)
                    .font(.system(size: 56, weight: .regular))
                    .foregroundStyle(Color.textPrimary)
                Text("BodyLog 已锁定")
                    .font(AppFont.title)
                    .foregroundStyle(Color.textPrimary)
                Button {
                    Task { await tryAuthenticate() }
                } label: {
                    Text("解锁")
                        .padding(.horizontal, AppSpacing.xl)
                        .padding(.vertical, AppSpacing.m)
                        .background(Color.accentBlue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.button))
                }
            }
        }
        .task {
            await tryAuthenticate()
        }
    }

    private var iconName: String {
        switch BiometricAuth.shared.availability() {
        case .faceID:  return "faceid"
        case .touchID: return "touchid"
        case .none:    return "lock.fill"
        }
    }

    @MainActor
    private func tryAuthenticate() async {
        let result = await BiometricAuth.shared.authenticate(reason: "解锁 BodyLog")
        if case .success = result {
            withAnimation(.easeInOut(duration: AppDuration.short)) {
                isUnlocked = true
            }
        }
    }
}
