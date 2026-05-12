import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: TrackerStore
    @State private var showCreate = false
    @State private var showAppSettings = false

    private let columns = [
        GridItem(.flexible(), spacing: BrandSpacing.md),
        GridItem(.flexible(), spacing: BrandSpacing.md),
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                BrandColor.surfaceCreamStrong.ignoresSafeArea()

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
                                NavigationLink(value: tracker) {
                                    TrackerCardView(tracker: tracker)
                                }
                                .buttonStyle(.plain)
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
    HomeView()
        .environmentObject(TrackerStore(context: PersistenceController(inMemory: true).container.viewContext))
}

#Preview("有数据") {
    HomeView()
        .environmentObject(TrackerStore(context: PersistenceController.preview.container.viewContext))
}
