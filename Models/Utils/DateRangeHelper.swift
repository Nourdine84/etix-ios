import Foundation

struct DateRangeHelper {

    static func currentRange(for range: TimeRange) -> (start: Date, end: Date) {

        let calendar = Calendar.current
        let now = Date()

        switch range {

        case .today:
            let start = calendar.startOfDay(for: now)
            let end = calendar.date(byAdding: .day, value: 1, to: start)!
            return (start, end)

        case .month:
            let start = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
            let end = calendar.date(byAdding: .month, value: 1, to: start)!
            return (start, end)

        case .year:
            let start = calendar.date(from: calendar.dateComponents([.year], from: now))!
            let end = calendar.date(byAdding: .year, value: 1, to: start)!
            return (start, end)
        }
    }

    static func previousRange(for range: TimeRange) -> (start: Date, end: Date) {

        let calendar = Calendar.current
        let current = currentRange(for: range)

        switch range {

        case .today:
            let start = calendar.date(byAdding: .day, value: -1, to: current.start)!
            return (start, current.start)

        case .month:
            let start = calendar.date(byAdding: .month, value: -1, to: current.start)!
            return (start, current.start)

        case .year:
            let start = calendar.date(byAdding: .year, value: -1, to: current.start)!
            return (start, current.start)
        }
    }

    static func millis(_ date: Date) -> Int64 {
        Int64(date.timeIntervalSince1970 * 1000)
    }
}
