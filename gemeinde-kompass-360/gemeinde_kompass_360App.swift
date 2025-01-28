import SwiftUI
import SwiftData

@main
struct gemeinde_kompass_360App: App {
   /* init() {
        let selectedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage") ?? "en"
        Bundle.setLanguage(selectedLanguage)
    }*/

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.locale, .init(identifier: "de"))

        }
    }
}

extension String {
  func localizeString(string: String) -> String {
    
      let path = Bundle.main.path(forResource: string, ofType: "lproj")
      let bundle = Bundle(path: path!)
      return NSLocalizedString(self, tableName: nil, bundle: bundle!,
      value: "", comment: "")
  }

}
