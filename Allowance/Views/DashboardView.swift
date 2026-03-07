import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var store: AllowanceStore

    var body: some View {
        VStack(spacing: 16) {
            if let child = store.selectedChild {
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
            }

            Spacer()
        }
        .padding()
    }
}
