import Foundation

struct ChildProfile: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var balance: Int
    // Legacy field kept for migration from old local data.
    var chores: [ChoreTemplate]
    var history: [AllowanceEvent]

    init(id: UUID = UUID(), name: String, balance: Int = 0, chores: [ChoreTemplate] = [], history: [AllowanceEvent] = []) {
        self.id = id
        self.name = name
        self.balance = balance
        self.chores = chores
        self.history = history
    }
}

struct ChoreTemplate: Identifiable, Codable, Hashable {
    var id: UUID
    var title: String
    var reward: Int
    var isActive: Bool

    init(id: UUID = UUID(), title: String, reward: Int, isActive: Bool = true) {
        self.id = id
        self.title = title
        self.reward = reward
        self.isActive = isActive
    }
}

enum AllowanceEventType: String, Codable {
    case earn
    case spend
}

struct AllowanceEvent: Identifiable, Codable, Hashable {
    var id: UUID
    var date: Date
    var type: AllowanceEventType
    var title: String
    var amount: Int

    init(id: UUID = UUID(), date: Date = Date(), type: AllowanceEventType, title: String, amount: Int) {
        self.id = id
        self.date = date
        self.type = type
        self.title = title
        self.amount = amount
    }
}

struct StoredData: Codable {
    var children: [ChildProfile]
    var chores: [ChoreTemplate]?

    init(children: [ChildProfile], chores: [ChoreTemplate]?) {
        self.children = children
        self.chores = chores
    }

    private enum CodingKeys: String, CodingKey {
        case children
        case chores
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        children = try container.decodeIfPresent([ChildProfile].self, forKey: .children) ?? []
        chores = try container.decodeIfPresent([ChoreTemplate].self, forKey: .chores)
    }
}
