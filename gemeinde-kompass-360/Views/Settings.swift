import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage") ?? "en"
    @State private var refreshID = UUID() // Used to refresh the view
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(LocalizedStringKey("Account"))) {
                    Text(LocalizedStringKey("Profile"))
                    Text(LocalizedStringKey("Security"))
                }
                
                Section(header: Text(LocalizedStringKey("Preferences"))) {
                    Picker(LocalizedStringKey("Language"), selection: $selectedLanguage) {
                        Text(LocalizedStringKey("English")).tag("en")
                        Text(LocalizedStringKey("German")).tag("de")
                        Text(LocalizedStringKey("French")).tag("fr")
                        Text(LocalizedStringKey("Spanish")).tag("es")
                    }
                    .onChange(of: selectedLanguage) { newValue in
                        UserDefaults.standard.set(newValue, forKey: "selectedLanguage")
                        Bundle.setLanguage(newValue)
                        refreshID = UUID() // Trigger view refresh
                    }
                }
                
                Section {
                    Button(LocalizedStringKey("Sign Out")) {
                        // Handle sign out
                    }
                    .foregroundColor(.red)
                }
            }
            .id(refreshID) // Refresh the view when refreshID changes
            .navigationTitle(LocalizedStringKey("Settings"))
            .navigationBarItems(trailing: Button(LocalizedStringKey("Done")) {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
