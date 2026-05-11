import SwiftUI

struct TrackerSettingsView: View {
    let tracker: Tracker
    @EnvironmentObject private var trackerStore: TrackerStore
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteConfirm = false
    @State private var reminderEnabled = false
    @State private var reminderTime: Date = {
        var comp = DateComponents()
        comp.hour = 20
        comp.minute = 0
        return Calendar.current.date(from: comp) ?? Date()
    }()

    var body: some View {
        NavigationStack {
            Form {
                Section("基本信息") {
                    HStack {
                        Text("名称")
                        Spacer()
                        Text(tracker.name).foregroundStyle(Color.textSecondary)
                    }
                    if let goal = tracker.goalDescription, !goal.isEmpty {
                        HStack(alignment: .top) {
                            Text("目标")
                            Spacer()
                            Text(goal).foregroundStyle(Color.textSecondary).multilineTextAlignment(.trailing)
                        }
                    }
                }

                Section("每日提醒") {
                    Toggle("开启提醒", isOn: $reminderEnabled)
                    if reminderEnabled {
                        DatePicker("时间", selection: $reminderTime, displayedComponents: .hourAndMinute)
                    }
                }

                Section {
                    Button(role: .destructive) {
                        showDeleteConfirm = true
                    } label: {
                        Text("删除追踪")
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationTitle("追踪设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") { dismiss() }
                        .tint(Color.accentBlue)
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
}
