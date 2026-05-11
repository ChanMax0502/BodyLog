import SwiftUI

struct TodayView: View {
    @EnvironmentObject private var trackerStore: TrackerStore
    @Environment(\.scenePhase) private var scenePhase
    @State private var currentDate: Date = Date()
    @State private var showAppSettings = false
    @State private var showCreate = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgPrimary.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: AppSpacing.l) {
                        header
                            .padding(.horizontal, AppSpacing.l)
                            .padding(.top, AppSpacing.s)

                        if let first = trackerStore.trackers.first {
                            TodayMonthGrid(tracker: first, referenceDate: currentDate)
                                .padding(.horizontal, 15)
                        } else {
                            EmptyTrackerCard {
                                showCreate = true
                            }
                            .padding(.horizontal, 15)
                        }
                    }
                    .padding(.bottom, AppSpacing.xxl)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: TodayMonthGrid.DayRef.self) { ref in
                DailyLogView(tracker: ref.tracker, date: ref.date)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showAppSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .tint(Color.textPrimary)
                }
            }
            .sheet(isPresented: $showAppSettings) {
                AppSettingsView()
            }
            .sheet(isPresented: $showCreate) {
                CreateTrackerView()
                    .environmentObject(trackerStore)
            }
        }
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                currentDate = Date()
            }
        }
    }

    private var header: some View {
        VStack(spacing: AppSpacing.xs) {
            Text("Today")
                .font(.bud.bold(size: 40))
                .foregroundStyle(Color.textPrimary)
            Text(Self.subtitleFormatter.string(from: currentDate))
                .font(AppFont.body)
                .foregroundStyle(Color.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    private static let subtitleFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.dateFormat = "EEE, MMM d, yyyy"
        return df
    }()
}

private struct EmptyTrackerCard: View {
    var onCreate: () -> Void

    var body: some View {
        VStack(spacing: AppSpacing.m) {
            Text("还没有追踪项目")
                .font(AppFont.cardTitle)
                .foregroundStyle(Color.textPrimary)
            Text("先创建一个追踪，开始记录每天的变化")
                .font(AppFont.footnote)
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
            Button(action: onCreate) {
                Text("创建追踪")
                    .font(AppFont.cardTitle)
                    .foregroundStyle(.white)
                    .padding(.horizontal, AppSpacing.xl)
                    .padding(.vertical, AppSpacing.m)
                    .background(Color.accentBlue)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.button))
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing.xl)
        .background(Color.bgSecondary)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card))
    }
}

#Preview("空态") {
    TodayView()
        .environmentObject(TrackerStore(context: PersistenceController(inMemory: true).container.viewContext))
}

#Preview("有数据") {
    TodayView()
        .environmentObject(TrackerStore(context: PersistenceController.preview.container.viewContext))
}
