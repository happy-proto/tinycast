import Foundation

enum SettingsLocalization {
    static func string(_ key: String) -> String {
        String(localized: String.LocalizationValue(key))
    }
}
