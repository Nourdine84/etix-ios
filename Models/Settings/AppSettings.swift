import Foundation

struct AppSettings {

    var appearance: AppAppearance
    var defaultRange: TimeRange
    var appVersion: String
    var buildNumber: String

    static func load() -> AppSettings {

        let defaults = UserDefaults.standard

        let appearanceRaw = defaults.string(forKey: "appearance") ?? AppAppearance.system.rawValue
        let rangeRaw = defaults.string(forKey: "defaultRange") ?? TimeRange.month.rawValue

        return AppSettings(
            appearance: AppAppearance(rawValue: appearanceRaw) ?? .system,
            defaultRange: TimeRange(rawValue: rangeRaw) ?? .month,
            appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0",
            buildNumber: Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        )
    }

    static func save(appearance: AppAppearance, defaultRange: TimeRange) {

        let defaults = UserDefaults.standard
        defaults.set(appearance.rawValue, forKey: "appearance")
        defaults.set(defaultRange.rawValue, forKey: "defaultRange")
    }
}
