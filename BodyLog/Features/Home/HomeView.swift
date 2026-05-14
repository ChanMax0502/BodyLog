import SwiftUI

struct HomeView: View {
    @Binding var path: NavigationPath
    @EnvironmentObject private var store: TrackerStore
    @State private var showCreate = false
    @State private var showAppSettings = false
    @State private var isEditing = false
    @State private var showPinToast = false

    private let columns = [
        GridItem(.flexible(), spacing: BrandSpacing.md),
        GridItem(.flexible(), spacing: BrandSpacing.md),
    ]

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                BrandColor.surfaceCreamStrong.ignoresSafeArea()

                if showPinToast {
                    VStack {
                        Spacer()
                        Text("已修改选中的追踪")
                            .font(AppFont.footnote)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Capsule().fill(Color.black.opacity(0.75)))
                            .padding(.bottom, 32)
                    }
                    .zIndex(1)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.3), value: showPinToast)
                }

                ScrollView {
                    VStack(alignment: .leading, spacing: BrandSpacing.lg) {
                        Text("追踪")
                            .font(BrandFont.displayMD)
                            .tracking(BrandTracking.displayMD)
                            .foregroundColor(BrandColor.ink)
                            .padding(.horizontal, BrandSpacing.md)
                            .padding(.top, BrandSpacing.xs)

                        LazyVGrid(columns: columns, spacing: BrandSpacing.md) {
                            AddTrackerCard {
                                showCreate = true
                            }

                            ForEach(store.trackers) { tracker in
                                if isEditing {
                                    TrackerCardView(
                                        tracker: tracker,
                                        isEditing: true,
                                        isPrimary: store.primaryTracker?.id == tracker.id
                                    )
                                    .onTapGesture {
                                        store.setPrimary(tracker)
                                        withAnimation { isEditing = false; showPinToast = true }
                                        Task {
                                            try? await Task.sleep(for: .seconds(2))
                                            withAnimation { showPinToast = false }
                                        }
                                    }
                                } else {
                                    NavigationLink(value: tracker) {
                                        TrackerCardView(
                                            tracker: tracker,
                                            isPrimary: store.primaryTracker?.id == tracker.id
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(.horizontal, BrandSpacing.md)

                        if store.trackers.isEmpty {
                            Text("点击 + 创建你的第一个追踪")
                                .font(BrandFont.bodySM)
                                .foregroundColor(BrandColor.muted)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, BrandSpacing.xs)
                        }
                    }
                    .padding(.bottom, BrandSpacing.xl)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showAppSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .tint(BrandColor.ink)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if !store.trackers.isEmpty {
                        Button {
                            withAnimation { isEditing.toggle() }
                        } label: {
                            Image(systemName: isEditing ? "pin.fill" : "pin")
                        }
                        .tint(isEditing ? BrandColor.primary : BrandColor.ink)
                    }
                }
            }
            .sheet(isPresented: $showCreate) {
                CreateTrackerView()
                    .environmentObject(store)
            }
            .sheet(isPresented: $showAppSettings) {
                AppSettingsView()
            }
            .navigationDestination(for: Tracker.self) { tracker in
                CalendarView(tracker: tracker)
            }
        }
    }
}

private struct AddTrackerCard: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: BrandRadius.lg)
                    .fill(BrandColor.surfaceSoft)
                    .overlay(
                        RoundedRectangle(cornerRadius: BrandRadius.lg)
                            .strokeBorder(
                                BrandColor.hairline,
                                style: StrokeStyle(lineWidth: 1.5, dash: [6, 4])
                            )
                    )

                Image(systemName: "plus")
                    .font(.system(size: 36, weight: .regular))
                    .foregroundColor(BrandColor.primary)
            }
            .aspectRatio(1, contentMode: .fit)
        }
        .buttonStyle(.plain)
    }
}

#Preview("空态") {
    HomeView(path: .constant(NavigationPath()))
        .environmentObject(TrackerStore(context: PersistenceController(inMemory: true).container.viewContext))
}

#Preview("有数据") {
    HomeView(path: .constant(NavigationPath()))
        .environmentObject(TrackerStore(context: PersistenceController.preview.container.viewContext))
}
