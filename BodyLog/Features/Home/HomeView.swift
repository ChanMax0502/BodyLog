import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: TrackerStore
    @State private var showCreate = false
    @State private var showAppSettings = false

    private let columns = [
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15),
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgPrimary.ignoresSafeArea()

                ScrollView {
                    LazyVGrid(columns: columns, spacing: 15) {
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
                    .padding(.horizontal, 15)
                    .padding(.top, AppSpacing.l)

                    if store.trackers.isEmpty {
                        Text("点击 + 创建你的第一个追踪")
                            .font(AppFont.footnote)
                            .foregroundStyle(Color.textSecondary)
                            .padding(.top, AppSpacing.m)
                    }
                }
            }
            .navigationTitle("追踪")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAppSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .tint(Color.textPrimary)
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
                RoundedRectangle(cornerRadius: AppRadius.card)
                    .strokeBorder(
                        Color.appSeparator,
                        style: StrokeStyle(lineWidth: 1.5, dash: [6, 4])
                    )
                    .background(
                        RoundedRectangle(cornerRadius: AppRadius.card)
                            .fill(Color.bgSecondary.opacity(0.4))
                    )

                Image(systemName: "plus")
                    .font(.system(size: 44, weight: .regular))
                    .foregroundStyle(Color.textSecondary)
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
