import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var store: AllowanceStore
    @AppStorage("dashboardChoreLayoutIsCompact") private var isCompactChoreUI = false
    @State private var isShowingBonusSheet = false
    @State private var bonusAmountText = ""

    var body: some View {
        VStack(spacing: 16) {
            if let child = store.selectedChild {
                HStack {
                    Text(child.name)
                        .font(.title.bold())
                    Spacer()
                    Button {
                        isCompactChoreUI.toggle()
                    } label: {
                        Text("UI")
                            .font(.caption.bold())
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.thinMaterial, in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

                VStack(spacing: 8) {
                    Text("現在のおこづかい")
                        .font(.headline)
                    Text("\(child.balance)円")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundStyle(.green)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(.green.opacity(0.12), in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                VStack(alignment: .leading, spacing: 8) {
                    Text("お手伝いでためる")
                        .font(.headline)
                    if store.activeChores.isEmpty {
                        Text("お手伝いがありません。『お手伝い』タブで追加してください。")
                            .foregroundStyle(.secondary)
                    } else {
                        ScrollView {
                            VStack(spacing: 12) {
                                if isCompactChoreUI {
                                    compactBonusButton
                                    LazyVGrid(columns: compactColumns, spacing: 8) {
                                        ForEach(store.activeChores) { chore in
                                            Button {
                                                store.completeChore(chore)
                                            } label: {
                                                VStack(spacing: 6) {
                                                    Text(choreIcon(for: chore.title))
                                                        .font(.title2)
                                                    Text("+\(chore.reward)円")
                                                        .font(.caption.bold())
                                                        .foregroundStyle(.green)
                                                }
                                                .frame(maxWidth: .infinity, minHeight: 64)
                                            }
                                            .buttonStyle(.bordered)
                                        }
                                    }
                                } else {
                                    bonusButton
                                    ForEach(store.activeChores) { chore in
                                        Button {
                                            store.completeChore(chore)
                                        } label: {
                                            HStack {
                                                Text(chore.title)
                                                Spacer()
                                                Text("+\(chore.reward)円")
                                                    .bold()
                                                    .foregroundStyle(.green)
                                            }
                                            .padding(.vertical, 6)
                                        }
                                        .buttonStyle(.bordered)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 4)
                        }
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 30)
                                .onEnded { value in
                                    let horizontal = value.translation.width
                                    let vertical = value.translation.height
                                    guard abs(horizontal) > abs(vertical) else { return }
                                    if horizontal < 0 {
                                        store.selectNextChild()
                                    } else {
                                        store.selectPreviousChild()
                                    }
                                }
                        )
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .sheet(isPresented: $isShowingBonusSheet) {
            NavigationStack {
                Form {
                    TextField("ボーナス金額", text: $bonusAmountText)
                        .keyboardType(.numberPad)
                }
                .navigationTitle("ボーナス")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("キャンセル") {
                            isShowingBonusSheet = false
                            bonusAmountText = ""
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("追加") {
                            let amount = parsedAmount(from: bonusAmountText)
                            store.addBonus(amount: amount)
                            isShowingBonusSheet = false
                            bonusAmountText = ""
                        }
                    }
                }
            }
        }
    }

    private var bonusButton: some View {
        Button {
            isShowingBonusSheet = true
        } label: {
            HStack {
                Text("🎁 ボーナス")
                Spacer()
                Text("金額を入力")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 6)
        }
        .buttonStyle(.borderedProminent)
    }

    private var compactBonusButton: some View {
        Button {
            isShowingBonusSheet = true
        } label: {
            VStack(spacing: 6) {
                Text("🎁")
                    .font(.title2)
                Text("ボーナス")
                    .font(.caption.bold())
                Text("入力")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, minHeight: 64)
        }
        .buttonStyle(.borderedProminent)
    }

    private var compactColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 8), count: 3)
    }

    private func choreIcon(for title: String) -> String {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let parts = trimmed.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)
        if let first = parts.first, first.count <= 2 {
            return String(first)
        }
        return "🔹"
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
