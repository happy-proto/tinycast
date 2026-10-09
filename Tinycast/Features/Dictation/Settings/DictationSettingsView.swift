import AppKit
import AVFoundation
import SwiftUI

struct DictationSettingsView: View {
    @Environment(DictationCoordinator.self) private var coordinator
    @Environment(AppSettings.self) private var settings
    @State private var microphones: [AVCaptureDevice] = []
    @State private var modelSize: Int64?
    @State private var microphoneAccess = Permissions.microphoneAccess()
    var body: some View {
        @Bindable var settings = settings
        return Form {
            Section {
                Toggle(isOn: enabledBinding) {
                    SettingsFeatureToggleLabel(
                        anchor: .dictationDictation, title: "Enable Dictation",
                        subtitle: "Transcribe speech on your Mac with a local model.")
                }
                if microphoneAccess != .authorized {
                    HStack(alignment: .center, spacing: Theme.Spacing.lg) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                            .frame(width: SettingsListMetrics.iconSize)
                        VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                            Text("Microphone access required")
                                .foregroundStyle(.orange)
                            Text("Needed to record your dictation.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer(minLength: Theme.Spacing.lg)
                        Button(
                            microphoneAccess == .notDetermined
                                ? SettingsLocalization.string("Grant Access…")
                                : SettingsLocalization.string("Open System Settings")
                        ) {
                            if microphoneAccess == .notDetermined {
                                Task {
                                    _ = await Permissions.requestMicrophoneAccess()
                                    microphoneAccess = Permissions.microphoneAccess()
                                }
                            } else {
                                Permissions.openMicrophoneSettings()
                            }
                        }
                    }
                }
            }
            .settingsAnchor(.dictationDictation)

            if settings.dictationEnabled {
                Section {
                    Picker(selection: $settings.dictationMode) {
                        ForEach(DictationMode.allCases) { mode in
                            Text(SettingsLocalization.string(mode.title)).tag(mode)
                        }
                    } label: {
                        SettingsRowTitle(.dictationCommands, "Shortcut behavior")
                    }
                    HStack {
                        SettingsRowTitle(.dictationCommands, "Shortcut")
                        Spacer()
                        ShortcutRecorder(action: .dictation)
                    }
                    if settings.dictationMode == .pushToTalk {
                        let issue = coordinator.holdShortcutIssue
                        Text(
                            issue ?? SettingsLocalization.string(
                                "Hold a key combination or a single modifier; release it to transcribe. "
                                    + "Double taps work in toggle mode.")
                        )
                        .font(.caption)
                        .foregroundStyle(issue == nil ? Color.secondary : Color.orange)
                    }
                } header: {
                    SettingsSectionHeader(.dictationCommands)
                }

                Section {
                    Picker(selection: familyBinding) {
                        ForEach(DictationModel.Family.allCases) { family in
                            Text(family.rawValue).tag(family)
                        }
                    } label: {
                        SettingsRowTitle(.dictationModel, "Engine")
                        Text(
                            SettingsLocalization.string(settings.dictationModel.family.summary)
                                + " · " + SettingsLocalization.string(settings.dictationModel.coverage))
                    }
                    Picker(selection: $settings.dictationModel) {
                        ForEach(
                            DictationModel.allCases.filter { $0.family == settings.dictationModel.family }
                        ) { model in
                            Text(model.variantTitle).tag(model)
                        }
                    } label: {
                        SettingsRowTitle(.dictationModel, "Model")
                        Text(SettingsLocalization.string(settings.dictationModel.summary))
                    }

                    let installed = coordinator.models.isInstalled(settings.dictationModel)
                    let downloading = coordinator.models.downloading == settings.dictationModel
                    LabeledContent {
                        if downloading {
                            Button("Cancel") { coordinator.models.cancelDownload() }
                        } else if installed {
                            Button("Remove") { removeModel(settings.dictationModel) }
                                .disabled(
                                    coordinator.models.transcribing || coordinator.models.removing != nil)
                        } else {
                            Button("Download") { downloadModel(settings.dictationModel) }
                                .disabled(
                                    coordinator.models.downloading != nil
                                        || coordinator.models.removing == settings.dictationModel)
                        }
                    } label: {
                        Text(
                            downloading
                                ? SettingsLocalization.string("Downloading…")
                                : SettingsLocalization.string(installed ? "Installed" : "Not installed"))
                        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                            Text(modelDescription)
                            if downloading {
                                if let progress = coordinator.models.downloadProgress, progress.total > 0 {
                                    ProgressView(
                                        value: Double(progress.received), total: Double(progress.total)
                                    )
                                    .accessibilityLabel("Download progress")
                                    Text(
                                        SettingsLocalization.format(
                                            "%lld of %lld MB", progress.received / 1_000_000, progress.total / 1_000_000)
                                    )
                                    .monospacedDigit()
                                } else {
                                    ProgressView()
                                        .controlSize(.small)
                                }
                            }
                        }
                    }
                    if settings.dictationModel.isQwen, installed {
                        Picker(selection: languageBinding) {
                            Text("Auto").tag("")
                            Divider()
                            ForEach(DictationLanguage.allCases) { language in
                                Text(SettingsLocalization.string(language.rawValue)).tag(language.rawValue)
                            }
                        } label: {
                            SettingsRowTitle(.dictationModel, "Language")
                        }
                    }
                } header: {
                    SettingsSectionHeader(.dictationModel)
                }

                Section {
                    Picker(selection: $settings.dictationIdleRelease) {
                        ForEach(DictationIdleRelease.allCases) { option in
                            Text(idleReleaseTitle(option)).tag(option)
                        }
                    } label: {
                        SettingsRowTitle(.dictationMemory, "Release model from memory")
                    }
                } header: {
                    SettingsSectionHeader(.dictationMemory)
                } footer: {
                    Text("Releasing it when idle frees memory. The next dictation takes a moment longer.")
                }

                Section {
                    Picker(selection: microphoneBinding) {
                        Text(SettingsLocalization.string(microphones.isEmpty ? "No microphone available" : "System default"))
                            .tag("")
                        if !microphones.isEmpty { Divider() }
                        ForEach(microphones, id: \.uniqueID) { microphone in
                            Text(microphone.localizedName).tag(microphone.uniqueID)
                        }
                    } label: {
                        SettingsRowTitle(.dictationOutput, "Microphone")
                    }
                    Picker(selection: $settings.dictationDestination) {
                        ForEach(DictationDestination.allCases) { destination in
                            Text(SettingsLocalization.string(destination.title)).tag(destination)
                        }
                    } label: {
                        SettingsRowTitle(.dictationOutput, "When finished")
                    }
                    Toggle(isOn: $settings.dictationAdaptsCapitalization) {
                        SettingsRowTitle(.dictationOutput, "Adapt capitalization")
                        Text("Match the first letter to the text before the cursor.")
                    }
                } header: {
                    SettingsSectionHeader(.dictationOutput)
                } footer: {
                    Text(
                        "Press Return to finish dictating or Escape to cancel. Protected fields may refuse insertion."
                    )
                }

            }
        }
        .formStyle(.grouped)
        .settingsScrollTarget(.dictation)
        .onAppear {
            microphoneAccess = Permissions.microphoneAccess()
            if settings.dictationEnabled { microphones = DictationCapture.microphones }
        }
        .onChange(of: settings.dictationEnabled) { _, enabled in
            if enabled { microphones = DictationCapture.microphones }
        }
        .task {
            for await _ in NotificationCenter.default.notifications(
                named: NSApplication.didBecomeActiveNotification)
            {
                microphoneAccess = Permissions.microphoneAccess()
                if settings.dictationEnabled { microphones = DictationCapture.microphones }
            }
        }
        .task(id: settings.dictationEnabled ? settings.dictationModel : nil) {
            modelSize = nil
            guard settings.dictationEnabled else { return }
            coordinator.models.refreshInstalledModels()
            await refreshModelSize(settings.dictationModel)
        }
    }

    private var enabledBinding: Binding<Bool> {
        Binding(
            get: { settings.dictationEnabled },
            set: { coordinator.setEnabled($0) })
    }

    private var microphoneBinding: Binding<String> {
        Binding(
            get: { settings.dictationMicrophone ?? "" },
            set: { settings.dictationMicrophone = $0.isEmpty ? nil : $0 })
    }

    private var familyBinding: Binding<DictationModel.Family> {
        Binding(
            get: { settings.dictationModel.family },
            set: {
                settings.dictationModel = $0 == .parakeet ? .redux : .qwenSmall
            })
    }

    private var languageBinding: Binding<String> {
        Binding(
            get: { settings.dictationLanguage ?? "" },
            set: {
                settings.dictationLanguage = $0.isEmpty ? nil : $0
            })
    }

    private func idleReleaseTitle(_ option: DictationIdleRelease) -> String {
        switch option {
        case .never: SettingsLocalization.string("Never")
        case .oneMinute: SettingsLocalization.string("1 minute")
        case .oneHour: SettingsLocalization.string("1 hour")
        default: SettingsLocalization.format("%lld minutes", option.rawValue)
        }
    }

    private var modelDescription: String {
        modelSize.map {
            SettingsLocalization.format("%@ on disk", ByteCountFormatter.string(fromByteCount: $0, countStyle: .file))
        } ?? SettingsLocalization.format(
            "about %lld MB installed", settings.dictationModel.approximateInstalledMegabytes)
    }

    private func refreshModelSize(_ model: DictationModel) async {
        let size = await coordinator.models.installedSize(model)
        if !Task.isCancelled, settings.dictationModel == model { modelSize = size }
    }

    private func downloadModel(_ model: DictationModel) {
        Task {
            await coordinator.downloadModel(model)
            await refreshModelSize(model)
        }
    }

    private func removeModel(_ model: DictationModel) {
        Task {
            await coordinator.removeModel(model)
            await refreshModelSize(model)
        }
    }
}
