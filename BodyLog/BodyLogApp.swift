import SwiftUI

@main
struct BodyLogApp: App {
    @StateObject private var trackerStore: TrackerStore

    init() {
        let ctx = PersistenceController.shared.container.viewContext
        _trackerStore = StateObject(wrappedValue: TrackerStore(context: ctx))
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(trackerStore)
                .tint(Color.accentBlue)
                .preferredColorScheme(nil)
        }
    }
}
