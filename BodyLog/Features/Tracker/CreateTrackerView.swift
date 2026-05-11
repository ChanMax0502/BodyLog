import SwiftUI

struct CreateTrackerView: View {
    @EnvironmentObject private var store: TrackerStore
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var goal = ""
    @FocusState private var focusedField: Field?

    private enum Field { case name, goal }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgPrimary.ignoresSafeArea()

                VStack(alignment: .leading, spacing: AppSpacing.xl) {
                    VStack(alignment: .leading, spacing: AppSpacing.s) {
                        Text("名称")
                            .font(AppFont.footnote)
                            .foregroundStyle(Color.textSecondary)
                        TextField("如「左臂围度」（可不填）", text: $name)
                            .focused($focusedField, equals: .name)
                            .textInputAutocapitalization(.never)
                            .padding(AppSpacing.m)
                            .background(Color.bgSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: AppRadius.button))
                    }

                    VStack(alignment: .leading, spacing: AppSpacing.s) {
                        Text("目标描述（可选，最多 100 字）")
                            .font(AppFont.footnote)
                            .foregroundStyle(Color.textSecondary)
                        TextField("例如「使用米诺地尔，每周拍 3 次」", text: $goal, axis: .vertical)
                            .focused($focusedField, equals: .goal)
                            .lineLimit(3...5)
                            .padding(AppSpacing.m)
                            .background(Color.bgSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: AppRadius.button))
                            .onChange(of: goal) { newValue in
                                if newValue.count > 100 {
                                    goal = String(newValue.prefix(100))
                                }
                            }
                    }

                    Spacer()
                }
                .padding(AppSpacing.l)
            }
            .navigationTitle("新建追踪")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("取消") { dismiss() }
                        .tint(Color.textPrimary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("创建") {
                        store.create(name: name, goal: goal)
                        dismiss()
                    }
                    .tint(Color.accentBlue)
                }
            }
            .onAppear {
                focusedField = .name
            }
        }
    }
}

#Preview {
    CreateTrackerView()
        .environmentObject(TrackerStore(context: PersistenceController(inMemory: true).container.viewContext))
}
