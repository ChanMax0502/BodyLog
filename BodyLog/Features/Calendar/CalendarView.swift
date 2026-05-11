import SwiftUI

struct CalendarView: View {
    let tracker: Tracker
    @StateObject private var store: EntryStore
    @State private var showSettings = false
    @State private var currentMonth: Date
    @State private var slideEdge: Edge = .bottom

    init(tracker: Tracker) {
        self.tracker = tracker
        _store = StateObject(
            wrappedValue: EntryStore(
                tracker: tracker,
                context: PersistenceController.shared.container.viewContext
            )
        )
        let cal = Calendar.current
        let start = cal.dateInterval(of: .month, for: Date())?.start ?? Date()
        _currentMonth = State(initialValue: start)
    }

    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()

            VStack(spacing: AppSpacing.s) {
                summaryBar(for: currentMonth)
                monthLabel(for: currentMonth)

                ZStack {
                    TodayMonthGrid(tracker: tracker, referenceDate: currentMonth)
                        .id(currentMonth)
                        .transition(.asymmetric(
                            insertion: .move(edge: slideEdge).combined(with: .opacity),
                            removal: .move(edge: oppositeEdge(slideEdge)).combined(with: .opacity)
                        ))
                }

                Spacer()
            }
            .padding(.horizontal, AppSpacing.l)
            .contentShape(Rectangle())
            .gesture(verticalDragGesture)
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

    private func summaryBar(for month: Date) -> some View {
        let cal = Calendar.current
        let punched = store.punchedDaysInMonth(month)
        let total = cal.range(of: .day, in: .month, for: month)?.count ?? 30
        return Text("已打卡 \(punched) / \(total) 天")
            .font(AppFont.footnote)
            .foregroundStyle(Color.textSecondary)
            .padding(.vertical, AppSpacing.s)
            .frame(maxWidth: .infinity)
    }

    private func monthLabel(for month: Date) -> some View {
        let df = DateFormatter()
        df.locale = Locale(identifier: "zh_CN")
        df.dateFormat = "yyyy 年 M 月"
        return Text(df.string(from: month))
            .font(AppFont.title)
            .foregroundStyle(Color.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var verticalDragGesture: some Gesture {
        DragGesture(minimumDistance: 20)
            .onEnded { value in
                let dy = value.translation.height
                guard abs(dy) > 50 else { return }
                if dy < 0 {
                    goToNextMonth()
                } else {
                    goToPreviousMonth()
                }
            }
    }

    private func goToNextMonth() {
        let cal = Calendar.current
        guard
            let next = cal.date(byAdding: .month, value: 1, to: currentMonth),
            let upperBound = cal.dateInterval(of: .month, for: Date())?.start,
            next <= upperBound
        else { return }
        slideEdge = .bottom
        withAnimation(.easeInOut(duration: 0.25)) {
            currentMonth = next
        }
    }

    private func goToPreviousMonth() {
        let cal = Calendar.current
        guard
            let prev = cal.date(byAdding: .month, value: -1, to: currentMonth),
            let lowerBound = cal.dateInterval(of: .month, for: tracker.createdAt)?.start,
            prev >= lowerBound
        else { return }
        slideEdge = .top
        withAnimation(.easeInOut(duration: 0.25)) {
            currentMonth = prev
        }
    }

    private func oppositeEdge(_ edge: Edge) -> Edge {
        switch edge {
        case .top: return .bottom
        case .bottom: return .top
        case .leading: return .trailing
        case .trailing: return .leading
        }
    }
}
