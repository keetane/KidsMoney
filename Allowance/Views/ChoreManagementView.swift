import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct ChoreManagementView: View {
    @EnvironmentObject private var store: AllowanceStore
    @State private var newTitle = ""
    @State private var newReward = "50"
    @State private var editingChore: ChoreTemplate?

    var body: some View {
        List {
            Section("お手伝いを追加") {
                TextField("内容", text: $newTitle)
                TextField("金額", text: $newReward)
                    .keyboardType(.numberPad)
                Button("追加") {
                    dismissKeyboard()
                    let reward = parsedAmount(from: newReward)
                    store.addChore(title: newTitle, reward: reward)
                    newTitle = ""
                    newReward = "50"
                }
            }

            Section("登録済み（全員共通）") {
                ForEach(store.choreTemplates) { chore in
                    Button {
                        editingChore = chore
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(chore.title)
                                Text("\(chore.reward)円")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if !chore.isActive {
                                Text("停止中")
                                    .font(.caption)
                                    .foregroundStyle(.orange)
                            }
                        }
                    }
                }
                .onDelete(perform: store.deleteChore)
                if store.choreTemplates.isEmpty {
                    Text("お手伝いが未登録です")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .sheet(item: $editingChore) { chore in
            ChoreEditView(chore: chore)
        }
        .scrollDismissesKeyboard(.interactively)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("閉じる") {
                    dismissKeyboard()
                }
            }
        }
        .onDisappear {
            dismissKeyboard()
        }
    }

    private func dismissKeyboard() {
#if canImport(UIKit)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
#endif
    }

    private func parsedAmount(from text: String) -> Int {
        var value = 0
        for char in text {
            if let digit = char.wholeNumberValue {
                value = value * 10 + digit
            }
        }
        return value
    }
}

struct ChoreEditView: View {
    @EnvironmentObject private var store: AllowanceStore
    @Environment(\.dismiss) private var dismiss

    let chore: ChoreTemplate
    @State private var title: String
    @State private var rewardText: String
    @State private var isActive: Bool

    init(chore: ChoreTemplate) {
        self.chore = chore
        _title = State(initialValue: chore.title)
        _rewardText = State(initialValue: String(chore.reward))
        _isActive = State(initialValue: chore.isActive)
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("内容", text: $title)
                TextField("金額", text: $rewardText)
                    .keyboardType(.numberPad)
                Toggle("有効", isOn: $isActive)
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("お手伝い編集")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("キャンセル") {
                        dismissKeyboard()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("保存") {
                        dismissKeyboard()
                        let reward = parsedAmount(from: rewardText)
                        store.updateChore(chore, title: title, reward: reward, isActive: isActive)
                        dismiss()
                    }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("閉じる") {
                        dismissKeyboard()
                    }
                }
            }
        }
    }

    private func dismissKeyboard() {
#if canImport(UIKit)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
#endif
    }

    private func parsedAmount(from text: String) -> Int {
        var value = 0
        for char in text {
            if let digit = char.wholeNumberValue {
                value = value * 10 + digit
            }
        }
        return value
    }
}
