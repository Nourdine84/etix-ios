import Foundation

struct AppSettings: Codable {

    var appearance: AppAppearance
    var defaultRange: TimeRange
    var appVersion: String
    var buildNumber: String

    // MARK: - Default Init (IMPORTANT)

    init(
        appearance: AppAppearance = .system,
        defaultRange: TimeRange = .month,
        appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0",
        buildNumber: String = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    ) {
        self.appearance = appearance
        self.defaultRange = defaultRange
        self.appVersion = appVersion
        self.buildNumber = buildNumber
    }
}
