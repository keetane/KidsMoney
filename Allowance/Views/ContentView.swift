import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct ContentView: View {
    @EnvironmentObject private var store: AllowanceStore

    var body: some View {
        NavigationStack {
            if store.selectedChild == nil {
                ChildSelectionView()
            } else {
                MainTabsView()
            }
        }
    }
}

struct MainTabsView: View {
    @EnvironmentObject private var store: AllowanceStore
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tag(0)
                .tabItem {
                    Label("ホーム", systemImage: "house.fill")
                }

            ChoreManagementView()
                .tag(1)
                .tabItem {
                    Label("お手伝い", systemImage: "list.bullet.clipboard")
                }

            SpendView()
                .tag(2)
                .tabItem {
                    Label("つかう", systemImage: "cart.fill")
                }

            HistoryView()
                .tag(3)
                .tabItem {
                    Label("履歴", systemImage: "clock.arrow.circlepath")
                }
        }
        .onChange(of: selectedTab) { _ in
            dismissKeyboard()
        }
        .navigationTitle(store.selectedChild?.name ?? "おこづかい")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("こども切替") {
                    dismissKeyboard()
                    store.clearSelection()
                }
            }
        }
    }

    private func dismissKeyboard() {
#if canImport(UIKit)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
#endif
    }
}
