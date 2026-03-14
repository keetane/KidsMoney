import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct SpendView: View {
    @EnvironmentObject private var store: AllowanceStore

    @State private var title = ""
    @State private var amountText = ""
    @State private var message = ""

    var body: some View {
        Form {
            if let child = store.selectedChild {
                Section("現在残高") {
                    Text("\(child.balance)円")
                        .font(.title2.bold())
                }
            }

            Section("おこづかいをつかう") {
                TextField("何に使った？", text: $title)
                TextField("金額", text: $amountText)
                    .keyboardType(.numberPad)

                Button("記録") {
                    dismissKeyboard()
                    let amount = parsedAmount(from: amountText)
                    let success = store.spend(title: title, amount: amount)
                    if success {
                        message = "記録しました"
                        title = ""
                        amountText = ""
                    } else {
                        message = "入力内容か残高を確認してください"
                    }
                }
            }

            if !message.isEmpty {
                Section {
                    Text(message)
                        .foregroundStyle(message == "記録しました" ? .green : .red)
                }
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .contentShape(Rectangle())
        .gesture(
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
        .onDisappear {
            dismissKeyboard()
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("閉じる") {
                    dismissKeyboard()
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
