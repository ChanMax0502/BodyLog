import SwiftUI
import UIKit

struct CaptureConfirmView: View {
    let image: UIImage
    let tracker: Tracker
    var onSaved: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var note = ""
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgPrimary.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppSpacing.l) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: AppRadius.thumb))

                        VStack(alignment: .leading, spacing: AppSpacing.s) {
                            Text("备注（可选，最多 200 字）")
                                .font(AppFont.footnote)
                                .foregroundStyle(Color.textSecondary)
                            TextField("写点儿什么…", text: $note, axis: .vertical)
                                .lineLimit(3...6)
                                .padding(AppSpacing.m)
                                .background(Color.bgSecondary)
                                .clipShape(RoundedRectangle(cornerRadius: AppRadius.button))
                                .onChange(of: note) { newValue in
                                    if newValue.count > 200 {
                                        note = String(newValue.prefix(200))
                                    }
                                }
                        }
                    }
                    .padding(AppSpacing.l)
                }
            }
            .navigationTitle("确认记录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("取消") { dismiss() }
                        .tint(Color.textPrimary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await save() }
                    } label: {
                        if isSaving {
                            ProgressView()
                        } else {
                            Text("保存")
                        }
                    }
                    .disabled(isSaving)
                    .tint(Color.accentBlue)
                }
            }
        }
    }

    @MainActor
    private func save() async {
        isSaving = true
        defer { isSaving = false }
        let store = EntryStore(tracker: tracker, context: PersistenceController.shared.container.viewContext)
        do {
            _ = try store.add(image: image, note: note.isEmpty ? nil : note)
            onSaved()
            dismiss()
        } catch {
            assertionFailure("保存失败: \(error)")
        }
    }
}
