import Foundation

enum DateUtils {
    static func millis(from date: Date) -> Int64 {
        Int64(date.timeIntervalSince1970 * 1000.0)
    }

    static func date(fromMillis millis: Int64) -> Date {
        Date(timeIntervalSince1970: TimeInterval(millis) / 1000.0)
    }

    static func shortString(fromMillis millis: Int64) -> String {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none
        return df.string(from: date(fromMillis: millis))
    }
}
