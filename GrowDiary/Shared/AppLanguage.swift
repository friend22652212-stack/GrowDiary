import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {
    case traditionalChinese = "zh-Hant"
    case english = "en"
    case korean = "ko"

    private static let storageKey = "growdiary.app.language"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .traditionalChinese: "繁體中文"
        case .english: "English"
        case .korean: "한국어"
        }
    }

    var locale: Locale {
        Locale(identifier: rawValue)
    }

    static var current: AppLanguage {
        if let saved = UserDefaults.standard.string(forKey: storageKey),
           let language = AppLanguage(rawValue: saved) {
            return language
        }

        if let saved = UserDefaults(suiteName: AppGroupConstants.identifier)?
            .string(forKey: AppGroupConstants.languageKey),
           let language = AppLanguage(rawValue: saved) {
            return language
        }

        let preferred = Locale.preferredLanguages.first ?? AppLanguage.traditionalChinese.rawValue
        if preferred.hasPrefix("ko") { return .korean }
        if preferred.hasPrefix("en") { return .english }
        return .traditionalChinese
    }

    static func save(_ language: AppLanguage) {
        UserDefaults.standard.set(language.rawValue, forKey: storageKey)
        UserDefaults(suiteName: AppGroupConstants.identifier)?
            .set(language.rawValue, forKey: AppGroupConstants.languageKey)
    }
}
