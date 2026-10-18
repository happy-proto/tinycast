import Foundation

enum AppLanguage: String, CaseIterable, Identifiable, Sendable {
    case system
    case english = "en"
    case german = "de"
    case spanish = "es"
    case french = "fr"
    case japanese = "ja"
    case korean = "ko"
    case portuguese = "pt"
    case russian = "ru"
    case chineseSimplified = "zh-Hans"

    var id: String { rawValue }

    /// Each language names itself, so someone who picked the wrong one can still find their own.
    var title: String {
        switch self {
        case .system: String(localized: "Follow System")
        case .english: "English"
        case .german: "Deutsch"
        case .spanish: "Español"
        case .french: "Français"
        case .japanese: "日本語"
        case .korean: "한국어"
        case .portuguese: "Português"
        case .russian: "Русский"
        case .chineseSimplified: "简体中文"
        }
    }

    /// Reads a stored list, including a regional tag such as `de-DE` that System Settings writes.
    init(storedPreferences: [String]?) {
        guard let storedPreferences, !storedPreferences.isEmpty else {
            self = .system
            return
        }
        let match = Bundle.preferredLocalizations(
            from: Self.allCases.filter { $0 != .system }.map(\.rawValue),
            forPreferences: storedPreferences)
        self = match.first.flatMap(Self.init(rawValue:)) ?? .english
    }

    var storedPreferences: [String]? { self == .system ? nil : [rawValue] }

    func localization(systemLanguages: [String]) -> String {
        guard self == .system else { return rawValue }
        return Bundle.preferredLocalizations(
            from: Self.allCases.filter { $0 != .system }.map(\.rawValue),
            forPreferences: systemLanguages).first ?? AppLanguage.english.rawValue
    }
}
