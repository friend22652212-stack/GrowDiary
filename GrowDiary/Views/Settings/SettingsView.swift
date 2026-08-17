import CoreSpotlight
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @Query(sort: \Profile.name) private var profiles: [Profile]
    @Binding var selectedTab: AppTab

    @State private var exportURL: URL?
    @State private var showingExportSheet = false
    @State private var iCloudEnabled = AppSettings.isCloudSyncEnabled
    @State private var widgetEnabled = WidgetSettings.isEnabled
    @State private var appLockEnabled = AppSettings.isAppLockEnabled
    @State private var diaryReminderEnabled = AppSettings.isDiaryReminderEnabled
    @State private var diaryReminderTime = AppSettings.diaryReminderDate
    @State private var growthReminderEnabled = AppSettings.isGrowthReminderEnabled
    @State private var growthReminderTime = AppSettings.growthReminderDate
    @State private var growthReminderWeekday = AppSettings.growthReminderWeekday
    @State private var spotlightEnabled = AppSettings.isSpotlightEnabled
    @State private var showingRestartAlert = false
    @State private var showingWidgetGuideAlert = false
    @State private var showingBackupImporter = false
    @State private var pendingImportURL: URL?
    @State private var showingImportModeDialog = false
    @State private var isExportingBackup = false
    @State private var isImportingBackup = false
    @State private var backupAlertTitle = ""
    @State private var backupAlertMessage = ""
    @State private var showingBackupAlert = false
    @State private var notificationDenied = false

    private let backupType = UTType(filenameExtension: "growdiary", conformingTo: .zip) ?? .zip

    var body: some View {
        NavigationStack {
            ZStack {
                ScreenBackground()

                List {
                premiumSection

                Section {
                    Picker(L10n.string("settings.section.language"), selection: Binding(
                        get: { languageManager.current },
                        set: { languageManager.setLanguage($0) }
                    )) {
                        ForEach(AppLanguage.allCases) { lang in
                            Text(lang.displayName).tag(lang)
                        }
                    }
                } header: {
                    Text(L10n.string("settings.section.language"))
                } footer: {
                    Text(L10n.string("settings.language.footer"))
                }

                Section {
                    Toggle(L10n.string("settings.applock.toggle"), isOn: $appLockEnabled)
                        .disabled(!AppLockManager.shared.isAvailable)

                    if !AppLockManager.shared.isAvailable {
                        Text(L10n.string("settings.applock.unavailable"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Text(appLockDescription)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text(L10n.string("settings.section.security"))
                } footer: {
                    Text(L10n.string("settings.applock.footer"))
                }

                Section {
                    Toggle(L10n.string("settings.notification.diary.toggle"), isOn: $diaryReminderEnabled)

                    if diaryReminderEnabled {
                        DatePicker(
                            L10n.string("settings.notification.diary.time"),
                            selection: $diaryReminderTime,
                            displayedComponents: .hourAndMinute
                        )
                    }

                    Toggle(L10n.string("settings.notification.growth.toggle"), isOn: $growthReminderEnabled)

                    if growthReminderEnabled {
                        Picker(L10n.string("settings.notification.growth.weekday"), selection: $growthReminderWeekday) {
                            ForEach(1...7, id: \.self) { weekday in
                                Text(weekdayName(weekday)).tag(weekday)
                            }
                        }

                        DatePicker(
                            L10n.string("settings.notification.growth.time"),
                            selection: $growthReminderTime,
                            displayedComponents: .hourAndMinute
                        )
                    }

                    if notificationDenied {
                        Text(L10n.string("settings.notification.denied"))
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                } header: {
                    Text(L10n.string("settings.section.notification"))
                } footer: {
                    Text(L10n.string("settings.notification.footer"))
                }

                Section {
                    Button {
                        exportBackup()
                    } label: {
                        Label(L10n.string("settings.backup.export"), systemImage: "arrow.up.doc")
                    }
                    .disabled(isExportingBackup || isImportingBackup)

                    Button {
                        guard subscriptionManager.requirePremium() else { return }
                        showingBackupImporter = true
                    } label: {
                        Label(L10n.string("settings.backup.import"), systemImage: "arrow.down.doc")
                    }
                    .disabled(isExportingBackup || isImportingBackup)
                } header: {
                    Text(L10n.string("settings.section.backup"))
                } footer: {
                    Text(L10n.string("settings.backup.footer"))
                }

                Section {
                    Toggle(L10n.string("settings.spotlight.toggle"), isOn: $spotlightEnabled)
                } header: {
                    Text(L10n.string("settings.section.spotlight"))
                } footer: {
                    Text(L10n.string("settings.spotlight.footer"))
                }

                Section {
                    Toggle(L10n.string("settings.widget.toggle"), isOn: $widgetEnabled)

                    Text(L10n.string(widgetEnabled ? "settings.widget.status.enabled" : "settings.widget.status.disabled"))
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if widgetEnabled {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(L10n.string("settings.widget.addSteps.title"))
                                .font(.caption.weight(.semibold))
                            Text(L10n.string("settings.widget.addSteps.body"))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.top, 4)
                    }
                } header: {
                    Text(L10n.string("settings.section.widget"))
                } footer: {
                    Text(L10n.string("settings.widget.footer"))
                }

                Section {
                    if profiles.isEmpty {
                        Text(L10n.string("settings.export.noProfiles"))
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(profiles) { profile in
                            Button {
                                exportProfile(profile)
                            } label: {
                                Label(L10n.format("settings.export.profilePDF", profile.name), systemImage: "doc.richtext")
                            }
                        }
                    }
                } header: {
                    Text(L10n.string("settings.section.export"))
                }

                Section {
                    if !iCloudAccountService.isSignedIn {
                        Label(L10n.string("settings.sync.notSignedIn"), systemImage: "exclamationmark.icloud")
                            .foregroundStyle(.orange)
                    }

                    Toggle(L10n.string("settings.sync.toggle"), isOn: $iCloudEnabled)
                        .disabled(!iCloudAccountService.isSignedIn)

                    Text(iCloudAccountService.syncStatusDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } header: {
                    Text(L10n.string("settings.section.sync"))
                } footer: {
                    Text(L10n.string("settings.sync.footer"))
                }

                Section {
                    LabeledContent(L10n.string("settings.about.version"), value: L10n.string("settings.about.versionValue"))
                    LabeledContent(L10n.string("settings.about.stage"), value: L10n.string("settings.about.stageValue"))
                } header: {
                    Text(L10n.string("settings.section.about"))
                }

                Section {
                    Button {
                        selectedTab = .profiles
                    } label: {
                        Label(L10n.string("settings.feature.diary"), systemImage: "book.fill")
                    }

                    NavigationLink {
                        ProfileFeatureSelectView(
                            title: L10n.string("settings.feature.growth"),
                            emptyMessage: L10n.string("settings.feature.growth.emptyMessage"),
                            destinationTab: .growth
                        )
                    } label: {
                        Label(L10n.string("settings.feature.growth.link"), systemImage: "chart.line.uptrend.xyaxis")
                    }

                    NavigationLink {
                        ProfileFeatureSelectView(
                            title: L10n.string("settings.feature.milestones"),
                            emptyMessage: L10n.string("settings.feature.milestones.emptyMessage"),
                            destinationTab: .milestones
                        )
                    } label: {
                        Label(L10n.string("settings.feature.milestones"), systemImage: "flag.fill")
                    }

                    Button {
                        selectedTab = .search
                    } label: {
                        Label(L10n.string("settings.feature.search"), systemImage: "tag")
                    }

                    NavigationLink {
                        ProfileExportSelectView()
                    } label: {
                        Label(L10n.string("settings.feature.exportPDF"), systemImage: "square.and.arrow.up")
                    }
                } header: {
                    Text(L10n.string("settings.section.features"))
                } footer: {
                    Text(L10n.string("settings.features.footer"))
                }

                Section {
                    Text(privacyDescription)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } header: {
                    Text(L10n.string("settings.section.privacy"))
                }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(L10n.string("settings.navigationTitle"))
            .sheet(isPresented: $showingExportSheet) {
                if let exportURL {
                    ShareSheet(items: [exportURL])
                }
            }
            .fileImporter(
                isPresented: $showingBackupImporter,
                allowedContentTypes: [backupType, .zip, .data],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    pendingImportURL = urls.first
                    showingImportModeDialog = true
                case .failure:
                    showBackupAlert(
                        title: L10n.string("common.error.title"),
                        message: L10n.string("backup.error.importFailed")
                    )
                }
            }
            .confirmationDialog(
                L10n.string("backup.import.mode.title"),
                isPresented: $showingImportModeDialog,
                titleVisibility: .visible
            ) {
                Button(L10n.string("backup.import.mode.merge")) {
                    importBackup(mode: .merge)
                }
                Button(L10n.string("backup.import.mode.replace"), role: .destructive) {
                    importBackup(mode: .replace)
                }
                Button(L10n.string("common.cancel"), role: .cancel) {
                    pendingImportURL = nil
                }
            } message: {
                Text(L10n.string("backup.import.mode.message"))
            }
            .onAppear {
                Task { await subscriptionManager.refreshEntitlements() }
                syncSettingsFromStorage()
                AppLockManager.shared.refreshBiometryType()
            }
            .onChange(of: widgetEnabled) { oldValue, newValue in
                guard newValue != WidgetSettings.isEnabled else { return }
                WidgetSettings.isEnabled = newValue
                WidgetSnapshotService.refreshSnapshots(for: profiles)
                if newValue, !oldValue {
                    showingWidgetGuideAlert = true
                }
            }
            .onChange(of: iCloudEnabled) { _, newValue in
                if newValue, !subscriptionManager.isPremium {
                    iCloudEnabled = false
                    subscriptionManager.showingPaywall = true
                    return
                }
                guard newValue != AppSettings.isCloudSyncEnabled else { return }

                AppSettings.isCloudSyncEnabled = newValue
                if newValue {
                    AppSettings.hasMigratedPhotosToCloud = false
                }
                showingRestartAlert = true
            }
            .onChange(of: spotlightEnabled) { _, newValue in
                if newValue, !subscriptionManager.isPremium {
                    spotlightEnabled = false
                    subscriptionManager.showingPaywall = true
                    return
                }
                AppSettings.isSpotlightEnabled = newValue
                if newValue {
                    let entries = (try? modelContext.fetch(FetchDescriptor<DiaryEntry>())) ?? []
                    SpotlightIndexingService.indexAll(profiles: profiles, entries: entries)
                } else {
                    CSSearchableIndex.default().deleteSearchableItems(withDomainIdentifiers: [SpotlightIndexingService.domainIdentifier])
                }
            }
            .onChange(of: appLockEnabled) { _, newValue in
                if newValue, !subscriptionManager.isPremium {
                    appLockEnabled = false
                    subscriptionManager.showingPaywall = true
                    return
                }
                guard newValue != AppSettings.isAppLockEnabled else { return }
                AppSettings.isAppLockEnabled = newValue
                if newValue {
                    AppLockManager.shared.lockIfNeeded()
                    Task { await AppLockManager.shared.authenticate() }
                } else {
                    AppLockManager.shared.unlockIfDisabled()
                }
            }
            .onChange(of: diaryReminderEnabled) { _, newValue in
                AppSettings.isDiaryReminderEnabled = newValue
                Task { await updateNotifications() }
            }
            .onChange(of: diaryReminderTime) { _, newValue in
                AppSettings.diaryReminderDate = newValue
                if AppSettings.isDiaryReminderEnabled {
                    Task { await updateNotifications() }
                }
            }
            .onChange(of: growthReminderEnabled) { _, newValue in
                AppSettings.isGrowthReminderEnabled = newValue
                Task { await updateNotifications() }
            }
            .onChange(of: growthReminderTime) { _, newValue in
                AppSettings.growthReminderDate = newValue
                if AppSettings.isGrowthReminderEnabled {
                    Task { await updateNotifications() }
                }
            }
            .onChange(of: growthReminderWeekday) { _, newValue in
                AppSettings.growthReminderWeekday = newValue
                if AppSettings.isGrowthReminderEnabled {
                    Task { await updateNotifications() }
                }
            }
            .alert(L10n.string("settings.widget.guideAlert.title"), isPresented: $showingWidgetGuideAlert) {
                Button(L10n.string("common.ok")) {}
            } message: {
                Text(L10n.string("settings.widget.guideAlert.message"))
            }
            .alert(L10n.string("settings.restartAlert.title"), isPresented: $showingRestartAlert) {
                Button(L10n.string("common.ok")) {}
            } message: {
                Text(L10n.string("settings.restartAlert.message"))
            }
            .alert(backupAlertTitle, isPresented: $showingBackupAlert) {
                Button(L10n.string("common.ok")) {}
            } message: {
                Text(backupAlertMessage)
            }
        }
    }

    private var premiumSection: some View {
        Section {
            if subscriptionManager.isPremium {
                Label(L10n.string("premium.status.active"), systemImage: "crown.fill")
                    .foregroundStyle(AppTheme.babyPrimary)
            } else {
                Button {
                    subscriptionManager.showingPaywall = true
                } label: {
                    Label(L10n.string("premium.upgrade"), systemImage: "crown.fill")
                }
            }

            if !subscriptionManager.isPremium {
                Text(L10n.string("premium.settings.footer"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text(L10n.string("premium.section.title"))
        }
    }

    private var privacyDescription: String {
        if AppSettings.isCloudSyncEnabled, iCloudAccountService.isSignedIn {
            return L10n.string("settings.privacy.icloudEnabled")
        }
        return L10n.string("settings.privacy.icloudDisabled")
    }

    private var appLockDescription: String {
        switch AppLockManager.shared.biometryType {
        case .faceID: L10n.string("settings.applock.faceID")
        case .touchID: L10n.string("settings.applock.touchID")
        default: L10n.string("settings.applock.passcode")
        }
    }

    private func syncSettingsFromStorage() {
        iCloudEnabled = AppSettings.isCloudSyncEnabled
        widgetEnabled = WidgetSettings.isEnabled
        appLockEnabled = AppSettings.isAppLockEnabled
        diaryReminderEnabled = AppSettings.isDiaryReminderEnabled
        diaryReminderTime = AppSettings.diaryReminderDate
        growthReminderEnabled = AppSettings.isGrowthReminderEnabled
        growthReminderTime = AppSettings.growthReminderDate
        growthReminderWeekday = AppSettings.growthReminderWeekday
        spotlightEnabled = AppSettings.isSpotlightEnabled
    }

    private func weekdayName(_ weekday: Int) -> String {
        let symbols = Calendar.current.weekdaySymbols
        guard weekday >= 1, weekday <= symbols.count else { return "" }
        return symbols[weekday - 1]
    }

    private func exportProfile(_ profile: Profile) {
        guard subscriptionManager.requirePremium() else { return }
        if let url = ExportService.exportProfileDiaryPDF(profile: profile) {
            exportURL = url
            showingExportSheet = true
        }
    }

    private func exportBackup() {
        guard subscriptionManager.requirePremium() else { return }
        isExportingBackup = true
        defer { isExportingBackup = false }

        do {
            let url = try BackupService.exportBackup(modelContext: modelContext)
            exportURL = url
            showingExportSheet = true
        } catch {
            showBackupAlert(
                title: L10n.string("common.error.title"),
                message: error.localizedDescription
            )
        }
    }

    private func importBackup(mode: BackupImportMode) {
        guard subscriptionManager.isPremium else {
            subscriptionManager.showingPaywall = true
            return
        }
        guard let url = pendingImportURL else { return }
        pendingImportURL = nil
        isImportingBackup = true

        Task { @MainActor in
            defer { isImportingBackup = false }

            do {
                let summary = try BackupService.importBackup(from: url, modelContext: modelContext, mode: mode)
                if summary.isEmpty {
                    showBackupAlert(
                        title: L10n.string("backup.import.result.title"),
                        message: L10n.string("backup.import.result.empty")
                    )
                } else {
                    showBackupAlert(
                        title: L10n.string("backup.import.result.title"),
                        message: L10n.format(
                            "backup.import.result.success",
                            summary.profiles,
                            summary.entries,
                            summary.photos
                        )
                    )
                }
                WidgetSnapshotService.refreshSnapshots(for: profiles)
                let entries = (try? modelContext.fetch(FetchDescriptor<DiaryEntry>())) ?? []
                SpotlightIndexingService.indexAll(profiles: profiles, entries: entries)
            } catch {
                showBackupAlert(
                    title: L10n.string("common.error.title"),
                    message: error.localizedDescription
                )
            }
        }
    }

    private func updateNotifications() async {
        let authorized = await NotificationService.requestAuthorizationIfNeeded()
        notificationDenied = !authorized
        if authorized {
            await NotificationService.rescheduleAll()
        }
    }

    private func showBackupAlert(title: String, message: String) {
        backupAlertTitle = title
        backupAlertMessage = message
        showingBackupAlert = true
    }
}

#Preview {
    SettingsView(selectedTab: .constant(.settings))
        .modelContainer(for: [Profile.self, DiaryEntry.self], inMemory: true)
        .environmentObject(LanguageManager.shared)
        .environmentObject(SubscriptionManager.shared)
}
