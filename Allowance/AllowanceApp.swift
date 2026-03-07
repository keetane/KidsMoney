import SwiftUI

@main
struct AllowanceApp: App {
    @StateObject private var store = AllowanceStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
