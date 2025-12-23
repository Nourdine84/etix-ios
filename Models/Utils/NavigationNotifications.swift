import Foundation

extension Notification.Name {

    // MARK: - Navigation Tabs
    static let goToHome = Notification.Name("goToHome")
    static let goToAddTicket = Notification.Name("goToAddTicket")
    static let goToHistory = Notification.Name("goToHistory")
    static let goToCategories = Notification.Name("goToCategories")
    static let goToSettings = Notification.Name("goToSettings")

    // MARK: - History Filters
    static let goToHistoryToday = Notification.Name("goToHistoryToday")
    static let goToHistoryMonth = Notification.Name("goToHistoryMonth")
}
