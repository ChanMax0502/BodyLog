import SwiftUI
import UIKit

struct DailyLogView: View {
    let tracker: Tracker
    let date: Date
    @StateObject private var store: EntryStore
    @State private var currentIndex: Int = 0
    @State private var showPicker = false

    init(tracker: Tracker, date: Date) {
        self.tracker = tracker
        self.date = date
        _store = StateObject(
            wrappedValue: EntryStore(
                tracker: tracker,
                context: PersistenceController.shared.container.viewContext
            )
        )
    }

    private var entriesOfDay: [Entry] {
        store.entries(on: date)
    }

    var body: some View {
        let entries = entriesOfDay
        return ZStack {
            Color.bgPrimary.ignoresSafeArea()

            if entries.isEmpty {
                Text("当天暂无记录")
                    .font(AppFont.body)
                    .foregroundStyle(Color.textSecondary)
            } else {
                VStack(spacing: AppSpacing.l) {
                    TabView(selection: $currentIndex) {
                        ForEach(Array(entries.enumerated()), id: \.element.id) { idx, entry in
                            FullImageView(entry: entry)
                                .tag(idx)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(maxHeight: .infinity)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: AppSpacing.s) {
                            ForEach(Array(entries.enumerated()), id: \.element.id) { idx, entry in
                                ThumbnailButton(entry: entry, isSelected: idx == currentIndex) {
                                    currentIndex = idx
                                }
                            }
                        }
                        .padding(.horizontal, AppSpacing.l)
                    }
                    .frame(height: 72)

                    if entries.indices.contains(currentIndex),
                       let note = entries[currentIndex].note, !note.isEmpty {
                        Text(note)
                            .font(AppFont.footnote)
                            .foregroundStyle(Color.textSecondary)
                            .padding(.horizontal, AppSpacing.l)
                            .padding(.bottom, AppSpacing.s)
                    }
                }
            }
        }
        .navigationTitle(titleString)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showPicker = true
                } label: {
                    Image(systemName: "plus")
                }
                .tint(Color.textPrimary)
            }
        }
        .sheet(isPresented: $showPicker) {
            PhotoPicker(
                onPicked: { images in
                    showPicker = false
                    try? store.addBatch(images: images, on: date)
                },
                onCancel: {
                    showPicker = false
                }
            )
        }
    }

    private var titleString: String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "zh_CN")
        df.dateFormat = "yyyy 年 M 月 d 日"
        return df.string(from: date)
    }
}

private struct FullImageView: View {
    let entry: Entry

    var body: some View {
        Group {
            if let img = ImageStorage.shared.load(relativePath: entry.photoLocalPath) {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
            } else {
                ProgressView()
            }
        }
    }
}

private struct ThumbnailButton: View {
    let entry: Entry
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Group {
                if let img = ImageStorage.shared.load(relativePath: entry.photoLocalPath) {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                } else {
                    Color.bgSecondary
                }
            }
            .frame(width: 56, height: 56)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.thumb))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.thumb)
                    .strokeBorder(isSelected ? Color.accentBlue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}
