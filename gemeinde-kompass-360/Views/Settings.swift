import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage") ?? "en"
    @State private var refreshID = UUID() // Used to refresh the view
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(LocalizedStringKey("Preferences".localizeString(string: "en")))) {
                    Picker(LocalizedStringKey("Language"), selection: $selectedLanguage) {
                        Text(LocalizedStringKey("English")).tag("en")
                        Text(LocalizedStringKey("German")).tag("de")
                    }
                    .onChange(of: selectedLanguage) { newValue in
                        UserDefaults.standard.set(newValue, forKey: "selectedLanguage")
                        Bundle.setLanguage(newValue)
                        refreshID = UUID() // Trigger view refresh
                    }
                }
            }
            .id(refreshID) // Refresh the view when refreshID changes
            .navigationTitle(LocalizedStringKey("Settings"))
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
