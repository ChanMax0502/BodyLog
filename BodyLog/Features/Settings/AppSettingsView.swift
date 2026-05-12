import SwiftUI

struct AppSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("AppLockEnabled") private var appLockEnabled = false

    var body: some View {
        NavigationStack {
            ZStack {
                BrandColor.surfaceCreamStrong.ignoresSafeArea()

                Form {
                    Section {
                        Toggle(isOn: bindingForAppLock) {
                            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                                Text(appLockTitle)
                                    .foregroundColor(BrandColor.ink)
                                Text("冷启动时需要验证身份才能进入。")
                                    .font(BrandFont.caption)
                                    .foregroundColor(BrandColor.muted)
                            }
                        }
                        .tint(BrandColor.primary)
                        .listRowBackground(BrandColor.surfaceSoft)
                    } header: {
                        brandSectionHeader("隐私")
                    }

                    Section {
                        HStack {
                            Text("版本").foregroundColor(BrandColor.ink)
                            Spacer()
                            Text(appVersion).foregroundColor(BrandColor.muted)
                        }
                        .listRowBackground(BrandColor.surfaceSoft)

                        NavigationLink {
                            PrivacyView()
                        } label: {
                            Text("隐私政策").foregroundColor(BrandColor.ink)
                        }
                        .listRowBackground(BrandColor.surfaceSoft)
                    } header: {
                        brandSectionHeader("关于")
                    }

                    Section {
                        Text("所有数据仅存储在你的设备上，从不上传任何服务器。")
                            .font(BrandFont.bodySM)
                            .foregroundColor(BrandColor.muted)
                            .listRowBackground(Color.clear)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") { dismiss() }
                        .tint(BrandColor.primary)
                }
            }
        }
    }

    private func brandSectionHeader(_ title: String) -> some View {
        Text(title)
            .font(BrandFont.captionUppercase)
            .tracking(BrandTracking.captionUppercase)
            .textCase(.uppercase)
            .foregroundColor(BrandColor.muted)
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
            VStack(alignment: .leading, spacing: BrandSpacing.lg) {
                Text("隐私政策")
                    .font(BrandFont.displayMD)
                    .tracking(BrandTracking.displayMD)
                    .foregroundColor(BrandColor.ink)
                Text("BodyLog 不收集任何个人数据。所有图片、备注、设置均仅存储在你的设备上，App 从不上传任何信息到任何服务器。")
                    .font(BrandFont.bodyMD)
                    .foregroundColor(BrandColor.body)
                Spacer()
            }
            .padding(BrandSpacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(BrandColor.surfaceCreamStrong.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }
}
