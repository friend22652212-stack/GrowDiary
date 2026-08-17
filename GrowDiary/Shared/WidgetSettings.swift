import Foundation

enum WidgetSettings {
    static var isEnabled: Bool {
        get { readEnabled() }
        set { writeEnabled(newValue) }
    }

    private static func readEnabled() -> Bool {
        if let group = UserDefaults(suiteName: AppGroupConstants.identifier),
           group.object(forKey: AppGroupConstants.widgetEnabledKey) != nil {
            return group.bool(forKey: AppGroupConstants.widgetEnabledKey)
        }

        if UserDefaults.standard.object(forKey: AppGroupConstants.widgetEnabledKey) != nil {
            return UserDefaults.standard.bool(forKey: AppGroupConstants.widgetEnabledKey)
        }

        return true
    }

    private static func writeEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: AppGroupConstants.widgetEnabledKey)
        UserDefaults(suiteName: AppGroupConstants.identifier)?
            .set(enabled, forKey: AppGroupConstants.widgetEnabledKey)
    }
}
