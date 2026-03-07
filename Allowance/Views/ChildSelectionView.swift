import SwiftUI

struct ChildSelectionView: View {
    @EnvironmentObject private var store: AllowanceStore
    @State private var isShowingAddChildSheet = false

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
                if store.children.isEmpty {
                    Text("こどもがいません。上の新規追加から登録してください。")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Kids Money")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                EditButton()
            }
        }
        .sheet(isPresented: $isShowingAddChildSheet) {
            AddChildSheetView()
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
