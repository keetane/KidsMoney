import Foundation

@MainActor
final class AllowanceStore: ObservableObject {
    @Published private(set) var children: [ChildProfile] = []
    @Published private(set) var choreTemplates: [ChoreTemplate] = []
    @Published var selectedChildID: UUID?

    private let fileManager = FileManager.default
    private let storageFileName = "allowance-data.json"

    init() {
        load()
    }

    var selectedChild: ChildProfile? {
        guard let selectedChildID else { return nil }
        return children.first(where: { $0.id == selectedChildID })
    }

    var sortedHistoryForSelectedChild: [AllowanceEvent] {
        selectedChild?.history.sorted(by: { $0.date > $1.date }) ?? []
    }

    var activeChores: [ChoreTemplate] {
        choreTemplates.filter(\.isActive)
    }

    func selectChild(_ child: ChildProfile) {
        selectedChildID = child.id
    }

    func clearSelection() {
        selectedChildID = nil
    }

    func addChild(name: String, initialBalance: Int) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        guard initialBalance >= 0 else { return }

        children.append(ChildProfile(name: trimmed, balance: initialBalance))
        save()
    }

    func deleteChildren(at offsets: IndexSet) {
        let idsToDelete = offsets.compactMap { idx in
            children.indices.contains(idx) ? children[idx].id : nil
        }
        children.remove(atOffsets: offsets)
        if let selectedChildID, idsToDelete.contains(selectedChildID) {
            self.selectedChildID = nil
        }
        save()
    }

    func addChore(title: String, reward: Int) {
        guard reward > 0 else { return }
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        choreTemplates.append(ChoreTemplate(title: trimmed, reward: reward))
        save()
    }

    func updateChore(_ chore: ChoreTemplate, title: String, reward: Int, isActive: Bool) {
        guard reward > 0 else { return }
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        guard let choreIndex = choreTemplates.firstIndex(where: { $0.id == chore.id }) else { return }

        choreTemplates[choreIndex].title = trimmed
        choreTemplates[choreIndex].reward = reward
        choreTemplates[choreIndex].isActive = isActive
        save()
    }

    func deleteChore(at offsets: IndexSet) {
        choreTemplates.remove(atOffsets: offsets)
        save()
    }

    func completeChore(_ chore: ChoreTemplate) {
        guard chore.isActive else { return }
        guard let index = selectedChildIndex else { return }

        children[index].balance += chore.reward
        children[index].history.append(AllowanceEvent(type: .earn, title: chore.title, amount: chore.reward))
        save()
    }

    @discardableResult
    func spend(title: String, amount: Int) -> Bool {
        guard amount > 0 else { return false }
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        guard let index = selectedChildIndex else { return false }
        guard children[index].balance >= amount else { return false }

        children[index].balance -= amount
        children[index].history.append(AllowanceEvent(type: .spend, title: trimmed, amount: amount))
        save()
        return true
    }

    private var selectedChildIndex: Int? {
        guard let selectedChildID else { return nil }
        return children.firstIndex(where: { $0.id == selectedChildID })
    }

    private var storageURL: URL? {
        guard let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
        }

        let folder = appSupport.appendingPathComponent("Allowance", isDirectory: true)
        if !fileManager.fileExists(atPath: folder.path) {
            try? fileManager.createDirectory(at: folder, withIntermediateDirectories: true)
        }
        return folder.appendingPathComponent(storageFileName)
    }

    private func load() {
        guard let storageURL else {
            children = Self.defaultChildren
            choreTemplates = Self.defaultChores
            return
        }

        guard fileManager.fileExists(atPath: storageURL.path) else {
            children = Self.defaultChildren
            choreTemplates = Self.defaultChores
            save()
            return
        }

        do {
            let data = try Data(contentsOf: storageURL)
            let stored = try JSONDecoder().decode(StoredData.self, from: data)
            children = stored.children
            if let storedChores = stored.chores {
                choreTemplates = storedChores
            } else {
                let migratedChores = Self.migrateSharedChores(from: children)
                choreTemplates = migratedChores.isEmpty ? Self.defaultChores : migratedChores
            }
        } catch {
            children = Self.defaultChildren
            choreTemplates = Self.defaultChores
        }

        selectedChildID = nil
    }

    private func save() {
        guard let storageURL else { return }
        do {
            let payload = StoredData(children: children, chores: choreTemplates)
            let data = try JSONEncoder().encode(payload)
            try data.write(to: storageURL, options: .atomic)
        } catch {
            print("Failed to save data: \(error)")
        }
    }

    private static var defaultChildren: [ChildProfile] {
        [
            ChildProfile(name: "たろう"),
            ChildProfile(name: "はな")
        ]
    }

    private static var defaultChores: [ChoreTemplate] {
        [
            ChoreTemplate(title: "ゴミ出し", reward: 10),
            ChoreTemplate(title: "風呂掃除", reward: 10),
            ChoreTemplate(title: "洗濯物畳み", reward: 10),
            ChoreTemplate(title: "おつかい", reward: 10),
            ChoreTemplate(title: "お皿洗い", reward: 10),
            ChoreTemplate(title: "掃除機 1部屋", reward: 10),
            ChoreTemplate(title: "ご飯作り", reward: 10)
        ]
    }

    private static func migrateSharedChores(from children: [ChildProfile]) -> [ChoreTemplate] {
        var keys = Set<String>()
        var migrated: [ChoreTemplate] = []
        for chore in children.flatMap(\.chores) {
            let key = "\(chore.title)|\(chore.reward)|\(chore.isActive)"
            guard keys.insert(key).inserted else { continue }
            migrated.append(ChoreTemplate(title: chore.title, reward: chore.reward, isActive: chore.isActive))
        }
        return migrated
    }
}
