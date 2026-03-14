import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var store: AllowanceStore
    @State private var isShowingBonusSheet = false
    @State private var bonusAmountText = ""

    var body: some View {
        VStack(spacing: 16) {
            if let child = store.selectedChild {
                Text(child.name)
                    .font(.title.bold())
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
                            VStack(spacing: 8) {
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
