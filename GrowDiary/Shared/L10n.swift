import Foundation
import WidgetKit

enum L10n {
    static func string(_ key: String) -> String {
        NSLocalizedString(key, bundle: Bundle.localized, comment: "")
    }

    static func format(_ key: String, _ arguments: CVarArg...) -> String {
        let format = string(key)
        return String(format: format, locale: AppLanguage.current.locale, arguments: arguments)
    }
}

extension Bundle {
    private static var localizedBundle: Bundle = .main

    static var localized: Bundle {
        localizedBundle
    }

    static func setLanguage(_ language: AppLanguage) {
        if let path = Bundle.main.path(forResource: language.rawValue, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            localizedBundle = bundle
            return
        }

        if let path = Bundle.main.path(
            forResource: language.rawValue,
            ofType: "lproj",
            inDirectory: "Localization"
        ), let bundle = Bundle(path: path) {
            localizedBundle = bundle
            return
        }

        localizedBundle = .main
    }
}

@MainActor
final class LanguageManager: ObservableObject {
    static let shared = LanguageManager()

    @Published private(set) var current: AppLanguage

    private init() {
        current = AppLanguage.current
        Bundle.setLanguage(current)
        syncToAppGroup()
    }

    func setLanguage(_ language: AppLanguage) {
        guard language != current else { return }
        current = language
        AppLanguage.save(language)
        Bundle.setLanguage(language)
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func syncToAppGroup() {
        AppLanguage.save(current)
    }
}

extension LanguageManager {
    nonisolated static func configureBundleForWidget() {
        let code = UserDefaults(suiteName: AppGroupConstants.identifier)?
            .string(forKey: AppGroupConstants.languageKey)
            ?? AppLanguage.current.rawValue
        let language = AppLanguage(rawValue: code) ?? .traditionalChinese
        Bundle.setLanguage(language)
    }
}
