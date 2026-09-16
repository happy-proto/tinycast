import Foundation

enum SettingsLocalization {
    static func string(_ key: String) -> String {
        String(localized: String.LocalizationValue(key))
    }
}

enum AppLanguage: String, CaseIterable, Identifiable {
    case system
    case english = "en"
    case simplifiedChinese = "zh-Hans"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: "Follow System"
        case .english: "English"
        case .simplifiedChinese: "简体中文"
        }
    }

    static func current(
        defaults: UserDefaults = .standard,
        bundleIdentifier: String? = Bundle.main.bundleIdentifier
    ) -> AppLanguage {
        guard let bundleIdentifier,
            let languages = defaults.persistentDomain(forName: bundleIdentifier)?["AppleLanguages"]
                as? [String],
            let language = languages.first
        else { return .system }
        if language.hasPrefix("zh") { return .simplifiedChinese }
        if language.hasPrefix("en") { return .english }
        return .system
    }

    func apply(
        defaults: UserDefaults = .standard,
        bundleIdentifier: String? = Bundle.main.bundleIdentifier
    ) {
        guard let bundleIdentifier else { return }
        var domain = defaults.persistentDomain(forName: bundleIdentifier) ?? [:]
        if self == .system {
            domain.removeValue(forKey: "AppleLanguages")
        } else {
            domain["AppleLanguages"] = [rawValue]
        }
        defaults.setPersistentDomain(domain, forName: bundleIdentifier)
    }
}
