import SwiftUI
import UIKit

struct MainTabView: View {
    @EnvironmentObject private var trackerStore: TrackerStore
    @State private var showPhotoPicker = false
    @State private var pickedImages: PickedImages?

    var body: some View {
        TabView {
            TodayView()
                .tabItem {
                    Label("首页", systemImage: "house.fill")
                }

            HomeView()
                .tabItem {
                    Label("追踪", systemImage: "square.stack.fill")
                }
        }
        .tint(Color.accentBlue)
        .overlay(alignment: .bottomTrailing) {
            if trackerStore.trackers.first != nil {
                Button {
                    showPhotoPicker = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(Color.accentBlue)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(.plain)
                .padding(.trailing, 16)
                .padding(.bottom, 4)
            }
        }
        .sheet(isPresented: $showPhotoPicker) {
            PhotoPicker(
                onPicked: { images in
                    showPhotoPicker = false
                    handlePicked(images)
                },
                onCancel: {
                    showPhotoPicker = false
                }
            )
        }
        .sheet(item: $pickedImages) { wrapper in
            if let tracker = trackerStore.trackers.first, let single = wrapper.images.first {
                CaptureConfirmView(
                    image: single,
                    tracker: tracker,
                    onSaved: { pickedImages = nil }
                )
            }
        }
    }

    private func handlePicked(_ images: [UIImage]) {
        guard let tracker = trackerStore.trackers.first, !images.isEmpty else { return }
        if images.count == 1 {
            pickedImages = PickedImages(images: images)
        } else {
            let store = EntryStore(tracker: tracker, context: PersistenceController.shared.container.viewContext)
            try? store.addBatch(images: images)
        }
    }

    private struct PickedImages: Identifiable {
        let id = UUID()
        let images: [UIImage]
    }
}
