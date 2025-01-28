import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            Home().tabItem(){
                Label("Home", systemImage: "house")
            }
            FederalStatesView().tabItem {
                Label("Federal States", systemImage: "map")
            }
            Favourites().tabItem(){
                Label("Favorites", systemImage: "heart")
            }
            SettingsView().tabItem {
                Label("Settings", systemImage: "gearshape")
            }
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    ContentView()
}
