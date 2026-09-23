enum SettingsTab: CaseIterable, Identifiable {
    case general, applications, systemSettings, systemActions, commands, quicklinks, appleShortcuts,
        fallbacks, clipboard, snippets, fileSearch, windowManagement, navigation, notes, calendar, emoji,
        ai, quickActions, extensions, permissions, backup, about
    /// The case, never an index: a selectable `List` flattens section and row IDs together.
    var id: Self { self }

    var title: String {
        let key = switch self {
        case .general: "General"
        case .applications: "Applications"
        case .systemSettings: "System Settings"
        case .systemActions: "System Actions"
        case .commands: "Commands"
        case .quicklinks: "Quicklinks"
        case .appleShortcuts: "Apple Shortcuts"
        case .fallbacks: "Fallbacks"
        case .ai: "AI"
        case .quickActions: "Quick Actions"
        case .fileSearch: "File Search"
        case .notes: "Notes"
        case .snippets: "Snippets"
        case .navigation: "Navigation"
        case .windowManagement: "Window Management"
        case .clipboard: "Clipboard"
        case .emoji: "Emoji & Symbols"
        case .calendar: "Calendar"
        case .extensions: "Extensions"
        case .permissions: "Permissions"
        case .backup: "Backup"
        case .about: "About"
        }
        return SettingsLocalization.string(key)
    }

    var systemImage: String {
        switch self {
        case .general: return "switch.2"
        case .applications: return "square.grid.2x2"
        case .systemSettings: return "gearshape"
        case .systemActions: return "bolt"
        case .commands: return "terminal"
        case .quicklinks: return "link"
        case .appleShortcuts: return "square.2.layers.3d"
        case .fallbacks: return "arrow.turn.down.right"
        case .ai: return "sparkles"
        case .quickActions: return "wand.and.sparkles"
        case .fileSearch: return "doc.text.magnifyingglass"
        case .notes: return "text.page"
        case .snippets: return "curlybraces"
        case .navigation: return "arrow.left.arrow.right"
        case .windowManagement: return "macwindow"
        case .clipboard: return "doc.on.clipboard"
        case .emoji: return "face.smiling"
        case .calendar: return "calendar"
        case .extensions: return "puzzlepiece.extension"
        case .permissions: return "lock.shield"
        case .backup: return "arrow.up.arrow.down.circle"
        case .about: return "info.circle"
        }
    }
}

/// Declaration order is display order; not `.Section`, which would shadow SwiftUI's `Section`.
enum SettingsSection: CaseIterable, Identifiable {
    case general, launcher, features, advanced
    /// See `SettingsTab.id`: distinct types keep the two namespaces from colliding.
    var id: Self { self }

    var title: String {
        let key = switch self {
        case .general: "General"
        case .launcher: "Launcher"
        case .features: "Features"
        case .advanced: "Advanced"
        }
        return SettingsLocalization.string(key)
    }

    var tabs: [SettingsTab] {
        switch self {
        case .general: return [.general, .permissions]
        case .launcher:
            return [
                .applications, .systemSettings, .systemActions, .commands, .quicklinks,
                .appleShortcuts, .fallbacks
            ]
        case .features:
            // Everyday tools first; AI and extensions are opt-in extras.
            return [
                .clipboard, .snippets, .fileSearch, .windowManagement, .navigation, .notes,
                .calendar, .emoji, .ai, .quickActions, .extensions
            ]
        case .advanced: return [.backup, .about]
        }
    }
}
