import SwiftUI

struct TrackerSettingsView: View {
    let tracker: Tracker
    @EnvironmentObject private var trackerStore: TrackerStore
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteConfirm = false
    @State private var nameDraft: String = ""
    @FocusState private var nameFocused: Bool
    @State private var reminderEnabled = false
    @State private var reminderTime: Date = {
        var comp = DateComponents()
        comp.hour = 20
        comp.minute = 0
        return Calendar.current.date(from: comp) ?? Date()
    }()

    var body: some View {
        NavigationStack {
            ZStack {
                BrandColor.surfaceCreamStrong.ignoresSafeArea()

                Form {
                    Section {
                        HStack {
                            Text("名称").foregroundColor(BrandColor.ink)
                            Spacer()
                            TextField("名称", text: $nameDraft)
                                .focused($nameFocused)
                                .multilineTextAlignment(.trailing)
                                .foregroundColor(BrandColor.muted)
                                .tint(BrandColor.primary)
                                .submitLabel(.done)
                                .onSubmit { commitName() }
                        }
                        .listRowBackground(BrandColor.surfaceSoft)

                        if let goal = tracker.goalDescription, !goal.isEmpty {
                            HStack(alignment: .top) {
                                Text("目标").foregroundColor(BrandColor.ink)
                                Spacer()
                                Text(goal)
                                    .foregroundColor(BrandColor.muted)
                                    .multilineTextAlignment(.trailing)
                            }
                            .listRowBackground(BrandColor.surfaceSoft)
                        }
                    } header: {
                        brandSectionHeader("基本信息")
                    }

                    Section {
                        Toggle("开启提醒", isOn: $reminderEnabled)
                            .tint(BrandColor.primary)
                            .foregroundColor(BrandColor.ink)
                            .listRowBackground(BrandColor.surfaceSoft)
                        if reminderEnabled {
                            DatePicker("时间", selection: $reminderTime, displayedComponents: .hourAndMinute)
                                .tint(BrandColor.primary)
                                .foregroundColor(BrandColor.ink)
                                .listRowBackground(BrandColor.surfaceSoft)
                        }
                    } header: {
                        brandSectionHeader("每日提醒")
                    }

                    Section {
                        Button(role: .destructive) {
                            showDeleteConfirm = true
                        } label: {
                            Text("删除追踪")
                                .foregroundColor(BrandColor.error)
                                .frame(maxWidth: .infinity)
                        }
                        .listRowBackground(BrandColor.surfaceSoft)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("追踪设置")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { nameDraft = tracker.name }
            .onChange(of: nameFocused) { focused in
                if !focused { commitName() }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") {
                        if nameFocused { nameFocused = false }
                        commitName()
                        dismiss()
                    }
                    .tint(BrandColor.primary)
                }
            }
            .confirmationDialog(
                "将同时删除全部照片记录，此操作不可恢复。",
                isPresented: $showDeleteConfirm,
                titleVisibility: .visible
            ) {
                Button("删除", role: .destructive) {
                    trackerStore.delete(tracker)
                    dismiss()
                }
                Button("取消", role: .cancel) {}
            }
        }
    }

    private func commitName() {
        trackerStore.rename(tracker, to: nameDraft)
        nameDraft = tracker.name
    }

    private func brandSectionHeader(_ title: String) -> some View {
        Text(title)
            .font(BrandFont.captionUppercase)
            .tracking(BrandTracking.captionUppercase)
            .textCase(.uppercase)
            .foregroundColor(BrandColor.muted)
    }
}
