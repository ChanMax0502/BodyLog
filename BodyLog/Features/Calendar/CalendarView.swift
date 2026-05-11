import SwiftUI

struct CalendarView: View {
    let tracker: Tracker
    @StateObject private var store: EntryStore
    @State private var showSettings = false

    init(tracker: Tracker) {
        self.tracker = tracker
        _store = StateObject(
            wrappedValue: EntryStore(
                tracker: tracker,
                context: PersistenceController.shared.container.viewContext
            )
        )
    }

    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: AppSpacing.xl, pinnedViews: [.sectionHeaders]) {
                        ForEach(months(), id: \.self) { monthStart in
                            Section {
                                MonthSection(month: monthStart, tracker: tracker, store: store)
                            } header: {
                                MonthHeader(month: monthStart)
                            }
                            .id(monthStart)
                        }
                    }
                    .padding(.horizontal, AppSpacing.l)
                    .padding(.bottom, AppSpacing.xxl)
                }
                .onAppear {
                    let cal = Calendar.current
                    if let cur = cal.dateInterval(of: .month, for: Date())?.start {
                        proxy.scrollTo(cur, anchor: .top)
                    }
                }
            }

            VStack(spacing: 0) {
                summaryBar
                    .background(Color.bgPrimary.opacity(0.95))
                Spacer()
            }
        }
        .navigationTitle(tracker.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "ellipsis")
                }
                .tint(Color.textPrimary)
            }
        }
        .sheet(isPresented: $showSettings) {
            TrackerSettingsView(tracker: tracker)
        }
    }

    private var summaryBar: some View {
        let cal = Calendar.current
        let punched = store.punchedDaysInMonth()
        let total = cal.range(of: .day, in: .month, for: Date())?.count ?? 30
        return Text("本月已打卡 \(punched) / \(total) 天")
            .font(AppFont.footnote)
            .foregroundStyle(Color.textSecondary)
            .padding(.vertical, AppSpacing.s)
            .frame(maxWidth: .infinity)
    }

    /// 从 Tracker.createdAt 所在月一直到当前月，按时间倒序展示（最新月在最上面）。
    private func months() -> [Date] {
        let cal = Calendar.current
        guard
            let start = cal.dateInterval(of: .month, for: tracker.createdAt)?.start,
            let end = cal.dateInterval(of: .month, for: Date())?.start
        else { return [] }
        var months: [Date] = []
        var cursor = end
        while cursor >= start {
            months.append(cursor)
            guard let prev = cal.date(byAdding: .month, value: -1, to: cursor) else { break }
            cursor = prev
        }
        return months
    }
}

private struct MonthHeader: View {
    let month: Date
    var body: some View {
        let df = DateFormatter()
        df.locale = Locale(identifier: "zh_CN")
        df.dateFormat = "yyyy 年 M 月"
        return Text(df.string(from: month))
            .font(AppFont.title)
            .foregroundStyle(Color.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, AppSpacing.s)
            .background(Color.bgPrimary)
    }
}
