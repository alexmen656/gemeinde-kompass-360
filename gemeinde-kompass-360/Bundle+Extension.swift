import Foundation

private var bundleKey: UInt8 = 0

final class BundleEx: Bundle, @unchecked Sendable {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        guard let bundle = objc_getAssociatedObject(self, &bundleKey) as? Bundle else {
            print("Fallback to super for key: \(key)")
            return super.localizedString(forKey: key, value: value, table: tableName)
        }
        let localizedString = bundle.localizedString(forKey: key, value: value, table: tableName)
        print("Using custom bundle for key: \(key), localized: \(localizedString)")
        return localizedString
    }
}

extension Bundle {
    static func setLanguage(_ language: String) {
        defer {
            object_setClass(Bundle.main, BundleEx.self)
        }
       guard let path = Bundle.main.path(forResource: "de", ofType: "lproj"),
      let bundle = Bundle(path: path) else {
    return
}
        let localizedAccount = bundle.localizedString(forKey: "Account", value: nil, table: nil)
        print("Manually loaded 'Account' in German: \(localizedAccount)")
print("Language: \(language), Path: \(path ?? "not found")")

        objc_setAssociatedObject(Bundle.main, &bundleKey, bundle, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}
