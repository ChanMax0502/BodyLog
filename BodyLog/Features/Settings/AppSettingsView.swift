import SwiftUI

struct AppSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("AppLockEnabled") private var appLockEnabled = false

    var body: some View {
        NavigationStack {
            Form {
                Section("隐私") {
                    Toggle(isOn: bindingForAppLock) {
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            Text(appLockTitle)
                            Text("冷启动时需要验证身份才能进入。")
                                .font(AppFont.caption)
                                .foregroundStyle(Color.textSecondary)
                        }
                    }
                }

                Section("关于") {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text(appVersion).foregroundStyle(Color.textSecondary)
                    }
                    NavigationLink("隐私政策") {
                        PrivacyView()
                    }
                }

                Section {
                    Text("所有数据仅存储在你的设备上，从不上传任何服务器。")
                        .font(AppFont.footnote)
                        .foregroundStyle(Color.textSecondary)
                }
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") { dismiss() }
                        .tint(Color.accentBlue)
                }
            }
        }
    }

    private var appLockTitle: String {
        switch BiometricAuth.shared.availability() {
        case .faceID:  return "启用 Face ID 应用锁"
        case .touchID: return "启用 Touch ID 应用锁"
        case .none:    return "应用锁（当前设备未启用生物识别）"
        }
    }

    private var bindingForAppLock: Binding<Bool> {
        Binding(
            get: { appLockEnabled },
            set: { newValue in
                if newValue {
                    Task {
                        let result = await BiometricAuth.shared.authenticate(reason: "启用应用锁需要验证身份")
                        await MainActor.run {
                            if case .success = result { appLockEnabled = true }
                            else { appLockEnabled = false }
                        }
                    }
                } else {
                    appLockEnabled = false
                }
            }
        )
    }

    private var appVersion: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
        let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0"
        return "\(v) (\(b))"
    }
}

private struct PrivacyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.l) {
                Text("隐私政策")
                    .font(AppFont.title)
                Text("BodyLog 不收集任何个人数据。所有图片、备注、设置均仅存储在你的设备上，App 从不上传任何信息到任何服务器。")
                    .font(AppFont.body)
                    .foregroundStyle(Color.textPrimary)
                Spacer()
            }
            .padding(AppSpacing.l)
        }
        .background(Color.bgPrimary)
        .navigationBarTitleDisplayMode(.inline)
    }
}
