import Foundation

/// A bundle's names in the languages this Mac reads; `CFBundle` alone misses every loctable app.
enum BundleLocalization {
    /// Preferred languages first, English last: a user who reads Thai still types "Calendar".
    nonisolated static func indexedLanguages(_ preferred: [String]) -> [String] {
        preferred + ["en"]
    }

    /// Every name the bundle carries, most preferred language first. `base` — an app's file name, a
    /// pane's `Info.plist` — ranks with the language it is written in, unless that one renames it.
    nonisolated static func names(
        for bundleURL: URL, base: String, developmentRegion: String?, languages: [String]
    ) -> [String] {
        let resources = bundleURL.appendingPathComponent("Contents/Resources", isDirectory: true)
        let table = plist(at: resources.appendingPathComponent("InfoPlist.loctable"))
        let development = developmentRegion.flatMap { localizationIdentifier(of: $0) }
        var result: [String] = []
        var seen = Set<String>()
        var isBaseRenamed = false

        func append(_ name: String) {
            guard seen.insert(FuzzyMatch.normalized(name)).inserted else { return }
            result.append(name)
        }

        let folders =
            (try? FileManager.default.contentsOfDirectory(
                at: resources, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]))?
            .filter { $0.pathExtension == "lproj" }
            .map { $0.deletingPathExtension().lastPathComponent } ?? []
        let tableCodes = table.map { Array($0.keys) } ?? []
        var available = Set(tableCodes + folders)
        if let development { available.insert(development) }
        let codes = localizedCodes(available: available.sorted(), preferences: languages)

        for code in codes {
            let strings = plist(
                at: resources.appendingPathComponent("\(code).lproj/InfoPlist.strings"))
            let translated = [table?[code] as? [String: Any], strings]
                .compactMap { $0.flatMap(AppDisplayName.inInfo) }
            translated.forEach(append)
            if let development, code.caseInsensitiveCompare(development) == .orderedSame {
                if translated.isEmpty { append(base) } else { isBaseRenamed = true }
            }
        }
        // A development region this Mac doesn't read still leaves the name searchable.
        if !isBaseRenamed { append(base) }
        return result
    }

    /// An unsupported preference must not trigger Foundation's English backstop.
    private static func localizedCodes(available: [String], preferences: [String]) -> [String] {
        var result: [String] = []
        var seen = Set<String>()
        for preference in preferences {
            let language = Locale.Language(identifier: preference)
            let candidates = available.filter {
                let candidate = Locale.Language(identifier: $0)
                return candidate.languageCode == language.languageCode
                    && candidate.script == language.script
            }
            guard !candidates.isEmpty else { continue }
            for code in Bundle.preferredLocalizations(
                from: candidates, forPreferences: [preference])
            where seen.insert(code).inserted {
                result.append(code)
            }
        }
        return result
    }

    /// `CFBundleDevelopmentRegion` still ships its pre-BCP-47 spelling: Safari's reads "English".
    private static func localizationIdentifier(of region: String) -> String? {
        let identifier = Locale.canonicalLanguageIdentifier(from: region)
        guard Locale.Language(identifier: identifier).languageCode != nil else { return nil }
        return identifier
    }

    private static func plist(at url: URL) -> [String: Any]? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        return (try? PropertyListSerialization.propertyList(from: data, format: nil))
            as? [String: Any]
    }
}
