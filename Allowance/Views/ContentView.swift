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
        CustomTabView(
            selectedIndex: $selectedTab,
            items: [
                TabItem(title: "ホーム", systemImage: "house.fill", view: AnyView(DashboardView())),
                TabItem(title: "つかう", systemImage: "cart.fill", view: AnyView(SpendView())),
                TabItem(title: "履歴", systemImage: "clock.arrow.circlepath", view: AnyView(HistoryView())),
                TabItem(title: "設定", systemImage: "gearshape.fill", view: AnyView(SettingsView()))
            ],
            onReselect: { _ in }
        )
        .onAppear {
            selectedTab = 0
        }
        .onChange(of: selectedTab) { _ in
            dismissKeyboard()
        }
        .navigationTitle(store.selectedChild?.name ?? "おこづかい")
    }

    private func dismissKeyboard() {
#if canImport(UIKit)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
#endif
    }
}

struct TabItem {
    let title: String
    let systemImage: String
    let view: AnyView
}

struct CustomTabView: UIViewControllerRepresentable {
    @Binding var selectedIndex: Int
    let items: [TabItem]
    let onReselect: (Int) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(selectedIndex: $selectedIndex, onReselect: onReselect)
    }

    func makeUIViewController(context: Context) -> UITabBarController {
        let controller = UITabBarController()
        controller.delegate = context.coordinator
        controller.viewControllers = items.enumerated().map { index, item in
            let hosting = UIHostingController(rootView: item.view)
            hosting.tabBarItem = UITabBarItem(title: item.title, image: UIImage(systemName: item.systemImage), tag: index)
            return hosting
        }
        controller.selectedIndex = selectedIndex
        return controller
    }

    func updateUIViewController(_ uiViewController: UITabBarController, context: Context) {
        if uiViewController.selectedIndex != selectedIndex {
            uiViewController.selectedIndex = selectedIndex
        }
        for (index, item) in items.enumerated() {
            if let hosting = uiViewController.viewControllers?[index] as? UIHostingController<AnyView> {
                hosting.rootView = item.view
            }
        }
    }

    final class Coordinator: NSObject, UITabBarControllerDelegate {
        @Binding var selectedIndex: Int
        let onReselect: (Int) -> Void
        private var lastSelectedIndex: Int?

        init(selectedIndex: Binding<Int>, onReselect: @escaping (Int) -> Void) {
            _selectedIndex = selectedIndex
            self.onReselect = onReselect
        }

        func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
            let newIndex = tabBarController.selectedIndex
            if lastSelectedIndex == newIndex {
                onReselect(newIndex)
            }
            lastSelectedIndex = newIndex
            selectedIndex = newIndex
        }
    }
}
