import SwiftUI

struct ChildSelectionView: View {
    @EnvironmentObject private var store: AllowanceStore
    @State private var isShowingAddChildSheet = false
    @State private var isShowingAddChoreSheet = false
    @State private var editingChore: ChoreTemplate?
    let showsTitle: Bool

    init(showsTitle: Bool = true) {
        self.showsTitle = showsTitle
    }

    var body: some View {
        List {
            Section("こどもをえらぶ") {
                Button {
                    isShowingAddChildSheet = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle")
                        Text("新規追加")
                    }
                    .foregroundStyle(Color.accentColor)
                }

                ForEach(store.children) { child in
                    Button {
                        store.selectChild(child)
                    } label: {
                        HStack {
                            Text(child.name)
                            Spacer()
                            Text("\(child.balance)円")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete(perform: store.deleteChildren)
                .onMove(perform: store.moveChildren)
                if store.children.isEmpty {
                    Text("こどもがいません。上の新規追加から登録してください。")
                        .foregroundStyle(.secondary)
                }
            }

            Section("お手伝い（全員共通）") {
                Button {
                    isShowingAddChoreSheet = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle")
                        Text("お手伝いを追加")
                    }
                    .foregroundStyle(Color.accentColor)
                }

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
                .onMove(perform: store.moveChores)
                if store.choreTemplates.isEmpty {
                    Text("お手伝いが未登録です")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .applyNavigationTitle(if: showsTitle, title: "Kids Money")
        .sheet(isPresented: $isShowingAddChildSheet) {
            AddChildSheetView()
        }
        .sheet(isPresented: $isShowingAddChoreSheet) {
            AddChoreSheetView()
        }
        .sheet(item: $editingChore) { chore in
            EditChoreSheetView(chore: chore)
        }
    }

}

private extension View {
    @ViewBuilder
    func applyNavigationTitle(if condition: Bool, title: String) -> some View {
        if condition {
            self.navigationTitle(title)
        } else {
            self
        }
    }
}

struct AddChildSheetView: View {
    @EnvironmentObject private var store: AllowanceStore
    @Environment(\.dismiss) private var dismiss
    @State private var newChildName = ""
    @State private var initialBalanceText = "0"

    var body: some View {
        NavigationStack {
            Form {
                TextField("なまえ", text: $newChildName)
                TextField("初期のおこづかい", text: $initialBalanceText)
                    .keyboardType(.numberPad)
            }
            .navigationTitle("こどもを追加")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("追加") {
                        let initialBalance = Int(initialBalanceText) ?? 0
                        store.addChild(name: newChildName, initialBalance: initialBalance)
                        dismiss()
                    }
                }
            }
        }
    }
}

struct AddChoreSheetView: View {
    @EnvironmentObject private var store: AllowanceStore
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var rewardText = "10"

    var body: some View {
        NavigationStack {
            Form {
                TextField("内容", text: $title)
                TextField("金額", text: $rewardText)
                    .keyboardType(.numberPad)
            }
            .navigationTitle("お手伝いを追加")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("追加") {
                        let reward = parsedAmount(from: rewardText)
                        store.addChore(title: title, reward: reward)
                        dismiss()
                    }
                }
            }
        }
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

struct EditChoreSheetView: View {
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
            .navigationTitle("お手伝い編集")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("保存") {
                        let reward = parsedAmount(from: rewardText)
                        store.updateChore(chore, title: title, reward: reward, isActive: isActive)
                        dismiss()
                    }
                }
            }
        }
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
