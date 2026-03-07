# Allowance (iOS)

子どものおこづかい管理アプリです。

## 機能

- 起動時に子どもを選択
- 現在のおこづかい残高を表示
- お手伝いを実行しておこづかいを加算
- お手伝い内容の追加・編集・削除
- おこづかいを使った記録を追加
- おこづかいの増減履歴を一覧表示

## プロジェクト

- Xcode Project: `Allowance.xcodeproj`
- Deployment Target: iOS 16.0
- UI: SwiftUI

## 使い方

1. `Allowance.xcodeproj` をXcodeで開く
2. Signingの `Team` を設定
3. iPhoneシミュレータまたは実機で実行

## データ保存

アプリ内データは `Application Support/Allowance/allowance-data.json` に保存されます。
