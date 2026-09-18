import SwiftUI

struct ClipboardFilterButton: View {
    let filter: ClipboardFilter
    let isOpen: Bool
    let action: () -> Void

    var body: some View {
        HeaderMenuButton(
            title: SettingsLocalization.string(filter.title),
            systemImage: filter.systemImage,
            isOpen: isOpen,
            help: SettingsLocalization.string("Filter by type  ⌘P"),
            action: action)
    }
}
