import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var store: AllowanceStore
    @State private var selectedDate = Date()
    @State private var displayedMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date())) ?? Date()

    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }()

    private let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }()

    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }()

    private let calendar = Calendar.current

    private var monthlyEvents: [AllowanceEvent] {
        store.sortedHistoryForSelectedChild.filter { event in
            calendar.isDate(event.date, equalTo: displayedMonth, toGranularity: .month)
        }
    }

    private var selectedDayEvents: [AllowanceEvent] {
        monthlyEvents.filter { event in
            calendar.isDate(event.date, inSameDayAs: selectedDate)
        }
    }

    private var earnedTotal: Int {
        monthlyEvents
            .filter { $0.type == .earn }
            .map(\.amount)
            .reduce(0, +)
    }

    private var spentTotal: Int {
        monthlyEvents
            .filter { $0.type == .spend }
            .map(\.amount)
            .reduce(0, +)
    }

    private var netTotal: Int {
        earnedTotal - spentTotal
    }

    private var spentEventDaySet: Set<Date> {
        Set(
            monthlyEvents
                .filter { $0.type == .spend }
                .map { calendar.startOfDay(for: $0.date) }
        )
    }

    private var earnedEventDaySet: Set<Date> {
        Set(
            monthlyEvents
                .filter { $0.type == .earn }
                .map { calendar.startOfDay(for: $0.date) }
        )
    }

    private var calendarDays: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth),
              let firstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let lastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end.addingTimeInterval(-1))
        else {
            return []
        }

        var days: [Date?] = []
        var day = firstWeek.start
        while day < lastWeek.end {
            if monthInterval.contains(day) {
                days.append(day)
            } else {
                days.append(nil)
            }
            guard let next = calendar.date(byAdding: .day, value: 1, to: day) else { break }
            day = next
        }
        return days
    }

    var body: some View {
        List {
            Section("カレンダー") {
                monthHeader
                weekHeader
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                    ForEach(Array(calendarDays.enumerated()), id: \.offset) { entry in
                        let date = entry.element
                        if let date {
                            dayCell(for: date)
                        } else {
                            Color.clear
                                .frame(height: 32)
                        }
                    }
                }
            }

            Section("\(monthFormatter.string(from: displayedMonth)) の合計") {
                HStack {
                    Text("ためた金額")
                    Spacer()
                    Text("+\(earnedTotal)円")
                        .foregroundStyle(.green)
                }
                HStack {
                    Text("つかった金額")
                    Spacer()
                    Text("-\(spentTotal)円")
                        .foregroundStyle(.red)
                }
                HStack {
                    Text("差し引き")
                    Spacer()
                    Text("\(netTotal >= 0 ? "+" : "")\(netTotal)円")
                        .bold()
                        .foregroundStyle(netTotal >= 0 ? .green : .red)
                }
            }

            Section("\(dayFormatter.string(from: selectedDate)) の履歴") {
                if selectedDayEvents.isEmpty {
                    Text("この日の履歴はありません")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(selectedDayEvents) { event in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(event.title)
                                Text(formatter.string(from: event.date))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(amountLabel(for: event))
                                .bold()
                                .foregroundStyle(event.type == .earn ? .green : .red)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
    }

    private var monthHeader: some View {
        HStack {
            Button {
                if let previous = calendar.date(byAdding: .month, value: -1, to: displayedMonth) {
                    displayedMonth = previous
                    selectedDate = previous
                }
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundStyle(Color.accentColor)
            }
            Spacer()
            Text(monthFormatter.string(from: displayedMonth))
                .font(.headline)
            Spacer()
            Button {
                if let next = calendar.date(byAdding: .month, value: 1, to: displayedMonth) {
                    displayedMonth = next
                    selectedDate = next
                }
            } label: {
                Image(systemName: "chevron.right")
                    .foregroundStyle(Color.accentColor)
            }
        }
    }

    private var weekHeader: some View {
        let symbols = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
        return HStack {
            ForEach(symbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private func dayCell(for date: Date) -> some View {
        let dayNumber = calendar.component(.day, from: date)
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let startOfDay = calendar.startOfDay(for: date)
        let hasSpentMark = spentEventDaySet.contains(calendar.startOfDay(for: date))
        let hasEarnedMark = earnedEventDaySet.contains(startOfDay)

        return Button {
            selectedDate = date
        } label: {
            VStack(spacing: 2) {
                Text("\(dayNumber)")
                    .font(.body.weight(isSelected ? .bold : .regular))
                    .foregroundStyle(isSelected ? .white : .primary)
                    .frame(width: 32, height: 32)
                    .background(isSelected ? Color.accentColor : Color.clear)
                    .clipShape(Circle())
                HStack(spacing: 4) {
                    Circle()
                        .fill(hasEarnedMark ? Color.green : Color.clear)
                        .frame(width: 6, height: 6)
                    Circle()
                        .fill(hasSpentMark ? Color.red : Color.clear)
                        .frame(width: 6, height: 6)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private func amountLabel(for event: AllowanceEvent) -> String {
        switch event.type {
        case .earn:
            return "+\(event.amount)円"
        case .spend:
            return "-\(event.amount)円"
        }
    }
}
