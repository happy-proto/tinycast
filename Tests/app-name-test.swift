import Foundation

@main
struct AppNameTest {
    static func main() {
        let fm = FileManager.default
        let root = fm.temporaryDirectory
            .appendingPathComponent("tinycast-app-name-\(UUID().uuidString)")

        var failures = 0

        func check(_ description: String, _ condition: @autoclosure () -> Bool) {
            if condition() {
                print("PASS  \(description)")
            } else {
                print("FAIL  \(description)")
                failures += 1
            }
        }

        /// A real bundle on disk: `installedAppName` reads the plist the way the scan does.
        func makeApp(_ fileName: String, info: [String: Any]) -> Bundle? {
            let url = root.appendingPathComponent(fileName)
            let contents = url.appendingPathComponent("Contents")
            try? fm.createDirectory(at: contents, withIntermediateDirectories: true)
            let data = try? PropertyListSerialization.data(
                fromPropertyList: info, format: .xml, options: 0)
            try? data?.write(to: contents.appendingPathComponent("Info.plist"))
            return Bundle(url: url)
        }

        check(
            "a blank display name is not a name",
            AppDisplayName.named("") == nil && AppDisplayName.named("   ") == nil
                && AppDisplayName.named("\n\t") == nil)
        check("a missing value is not a name", AppDisplayName.named(nil) == nil)
        check("a non-string value is not a name", AppDisplayName.named(42) == nil)
        check("a name is trimmed", AppDisplayName.named("  Paw  ") == "Paw")

        check(
            "a blank display name falls back to CFBundleName",
            AppDisplayName.inInfo(["CFBundleDisplayName": "", "CFBundleName": "RapidAPI"])
                == "RapidAPI")
        check(
            "a present display name still wins",
            AppDisplayName.inInfo(["CFBundleDisplayName": "Shown", "CFBundleName": "Internal"])
                == "Shown")
        check(
            "an info dictionary naming nothing yields nil",
            AppDisplayName.inInfo(["CFBundleDisplayName": " ", "CFBundleName": ""]) == nil)
        // Image Playground's loctable ships both, and CFBundle reads the platform-suffixed one.
        check(
            "the macOS variant of a key wins over the bare key",
            AppDisplayName.inInfo([
                "CFBundleDisplayName-macos": "Image Playground",
                "CFBundleDisplayName": "Playground", "CFBundleName": "Image Playground"
            ]) == "Image Playground")
        check(
            "a blank macOS variant falls through to the bare key",
            AppDisplayName.inInfo([
                "CFBundleDisplayName-macos": "", "CFBundleDisplayName": "Playground"
            ]) == "Playground")
        check(
            "a macOS variant of CFBundleName still loses to a real display name",
            AppDisplayName.inInfo([
                "CFBundleDisplayName": "Shown", "CFBundleName-macos": "Internal"
            ]) == "Shown")

        // RapidAPI 4.5.5 ships exactly this: blank display name, real `CFBundleName`, Paw's old id.
        let rapidAPI = makeApp(
            "RapidAPI.app",
            info: [
                "CFBundleDisplayName": "", "CFBundleName": "RapidAPI",
                "CFBundleIdentifier": "com.luckymarmot.Paw"
            ])
        check(
            "a bundle with a blank display name is named by CFBundleName",
            rapidAPI?.installedAppName == "RapidAPI")

        let unnamed = makeApp("Mystery.app", info: ["CFBundleIdentifier": "com.example.mystery"])
        check(
            "a bundle naming itself nowhere falls back to its filename",
            unnamed?.installedAppName == "Mystery")

        let blankBoth = makeApp(
            "Ghost.app",
            info: [
                "CFBundleDisplayName": "  ", "CFBundleName": "",
                "CFBundleIdentifier": "com.example.ghost"
            ])
        check(
            "two blank keys still fall back to the filename",
            blankBoth?.installedAppName == "Ghost")

        /// The whole path: a bundle translated only in its loctable, read as the scan reads it.
        func makeLocalizedApp(_ fileName: String, table: [String: Any]) -> URL {
            let url = root.appendingPathComponent(fileName)
            let resources = url.appendingPathComponent("Contents/Resources")
            try? fm.createDirectory(at: resources, withIntermediateDirectories: true)
            let data = try? PropertyListSerialization.data(
                fromPropertyList: table, format: .xml, options: 0)
            try? data?.write(to: resources.appendingPathComponent("InfoPlist.loctable"))
            return url
        }

        /// The scan's own call: an app's untranslated name is the file name it sits under on disk.
        func names(_ url: URL, _ preferred: [String], region: String? = "en") -> [String] {
            BundleLocalization.names(
                for: url, base: url.deletingPathExtension().lastPathComponent,
                developmentRegion: region,
                languages: BundleLocalization.indexedLanguages(preferred))
        }

        let monitor = makeLocalizedApp(
            "Activity Monitor.app",
            table: [
                "zh_CN": ["CFBundleName": "活动监视器"],
                "zh_TW": ["CFBundleName": "活動監視器"],
                "en": ["CFBundleName": "Activity Monitor"]
            ])
        check(
            "a loctable app is found by its Chinese name, English still indexed",
            names(monitor, ["zh-Hans-CN"]) == ["活动监视器", "Activity Monitor"])
        check(
            "an English Mac indexes only the English name",
            names(monitor, ["en-US"]) == ["Activity Monitor"])
        check(
            "Traditional Chinese selects its own system localization",
            names(monitor, ["zh-Hant-TW"]) == ["活動監視器", "Activity Monitor"])

        let netease = root.appendingPathComponent("NeteaseMusic.app")
        let neteaseResources = netease.appendingPathComponent("Contents/Resources")
        for (code, name) in [("zh-Hans", "网易云音乐"), ("en", "NetEaseMusic")] {
            let directory = neteaseResources.appendingPathComponent("\(code).lproj")
            try? fm.createDirectory(at: directory, withIntermediateDirectories: true)
            let data = try? PropertyListSerialization.data(
                fromPropertyList: ["CFBundleDisplayName": name], format: .xml, options: 0)
            try? data?.write(to: directory.appendingPathComponent("InfoPlist.strings"))
        }
        check(
            "a Chinese Mac labels a third-party script-localized app in Chinese",
            names(netease, ["zh-Hans-CN"]) == ["网易云音乐", "NetEaseMusic"])

        let serbianNotes = root.appendingPathComponent("Notes.app")
        let serbianResources = serbianNotes.appendingPathComponent("Contents/Resources")
        for (code, name) in [("sr-Latn", "Beleške"), ("en", "Notes")] {
            let directory = serbianResources.appendingPathComponent("\(code).lproj")
            try? fm.createDirectory(at: directory, withIntermediateDirectories: true)
            let data = try? PropertyListSerialization.data(
                fromPropertyList: ["CFBundleDisplayName": name], format: .xml, options: 0)
            try? data?.write(to: directory.appendingPathComponent("InfoPlist.strings"))
        }
        check(
            "a regional preference selects a non-Chinese script-only localization",
            names(serbianNotes, ["sr-Latn-RS"]) == ["Beleške", "Notes"])

        let serbianDevelopment = makeLocalizedApp(
            "Beleške.app", table: ["en": ["CFBundleName": "Notes"]])
        check(
            "a script-bearing development language ranks the base name with that script",
            names(serbianDevelopment, ["sr-Latn-RS"], region: "sr-Latn")
                == ["Beleške", "Notes"])

        let bilingual = makeLocalizedApp(
            "Name.app",
            table: ["fr": ["CFBundleName": "Nom"], "en": ["CFBundleName": "Name"]])
        check(
            "an unsupported first preference does not outrank a supported second preference",
            names(bilingual, ["ja-JP", "fr-FR"]) == ["Nom", "Name"])

        let latinAmerican = makeLocalizedApp(
            "Name.app",
            table: [
                "es_419": ["CFBundleName": "Nombre"],
                "en": ["CFBundleName": "Name"],
            ])
        check(
            "a regional Spanish preference reaches the Latin American fallback",
            names(latinAmerican, ["es-MX"]) == ["Nombre", "Name"])

        // Tips.app ships every language but its own: `en` is the one key Apple's loctables omit.
        let tips = makeLocalizedApp(
            "Tips.app", table: ["ru": ["CFBundleName": "Советы"], "de": ["CFBundleName": "Tipps"]])
        check(
            "an untranslated name outranks a language the user reads less well",
            names(tips, ["en-US", "ru-RU"]) == ["Tips", "Советы"])
        check(
            "the language a Mac actually prefers still wins over the untranslated name",
            names(tips, ["ru-RU"]) == ["Советы", "Tips"])
        check(
            "a language nobody asked for is never indexed",
            !names(tips, ["en-US", "ru-RU"]).contains("Tipps"))

        // Safari's `CFBundleDevelopmentRegion` still reads "English", not "en".
        check(
            "a pre-BCP-47 development region names the same language",
            names(tips, ["en-US", "ru-RU"], region: "English") == ["Tips", "Советы"])
        check(
            "a bundle claiming no region leaves its name last, still searchable",
            names(tips, ["en-US", "ru-RU"], region: nil) == ["Советы", "Tips"])

        // Print Center ships `en_GB` but no `en`; the file name is the English name it already has.
        let printCenter = makeLocalizedApp(
            "Print Center.app", table: ["en_GB": ["CFBundleName": "Print Centre"]])
        check(
            "a regional spelling never relabels the app the file name already names",
            names(printCenter, ["en-US"]).first == "Print Center")

        // VoiceMemos.app names itself nowhere on disk, so `en` carries the name the user sees.
        let memos = makeLocalizedApp(
            "VoiceMemos.app",
            table: ["en": ["CFBundleName": "Voice Memos"], "ru": ["CFBundleName": "Диктофон"]])
        check(
            "a translated English name still beats the file name it was written for",
            names(memos, ["en-US", "ru-RU"]) == ["Voice Memos", "VoiceMemos", "Диктофон"])

        try? fm.removeItem(at: root)
        print(failures == 0 ? "\nALL PASSED" : "\n\(failures) FAILED")
        exit(failures == 0 ? 0 : 1)
    }
}
