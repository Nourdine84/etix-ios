import Foundation

struct DateRangeHelper {

    static func currentRange(
        for range: TimeRange,
        reference: Date = Date()
    ) -> (start: Date, end: Date) {

        let calendar = Calendar.current

        switch range {

        case .day:
            let start = calendar.startOfDay(for: reference)
            let end = calendar.date(byAdding: .day, value: 1, to: start)!
            return (start, end)

        case .week:
            let start = calendar.dateInterval(of: .weekOfYear, for: reference)!.start
            let end = calendar.date(byAdding: .day, value: 7, to: start)!
            return (start, end)

        case .month:
            let start = calendar.dateInterval(of: .month, for: reference)!.start
            let end = calendar.date(byAdding: .month, value: 1, to: start)!
            return (start, end)
        }
    }

    static func previousRange(
        for range: TimeRange,
        reference: Date = Date()
    ) -> (start: Date, end: Date) {

        let calendar = Calendar.current

        switch range {

        case .day:
            let startToday = calendar.startOfDay(for: reference)
            let start = calendar.date(byAdding: .day, value: -1, to: startToday)!
            return (start, startToday)

        case .week:
            let startThisWeek = calendar.dateInterval(of: .weekOfYear, for: reference)!.start
            let start = calendar.date(byAdding: .day, value: -7, to: startThisWeek)!
            return (start, startThisWeek)

        case .month:
            let startThisMonth = calendar.dateInterval(of: .month, for: reference)!.start
            let start = calendar.date(byAdding: .month, value: -1, to: startThisMonth)!
            return (start, startThisMonth)
        }
    }

    static func millis(_ date: Date) -> Int64 {
        Int64(date.timeIntervalSince1970 * 1000)
    }
}
