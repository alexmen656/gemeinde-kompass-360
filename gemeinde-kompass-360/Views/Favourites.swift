//
//  Favourites.swift
//  gemeinde-kompass-360
//
//  Created by Alex Polan on 06/11/2023.
//

import SwiftUI

struct Favourites: View {
    @State private var favoriteItems: [Item] = []

       var body: some View {
           NavigationView {
               List(favoriteItems, id: \.id) { item in
                   NavigationLink(destination: Gemeinde(gemeinde: item)) {
                                     Text(item.name)
                                 }
               }
               .navigationTitle("Favoriten")///FavoritenFavourites
               .onAppear {
                   // Laden der Favoriten beim Anzeigen der Ansicht
                   self.favoriteItems = getAllFavorites()
               }
           }
       }
    
    private func getFavoriteItems() -> [Item] {
        if let data = UserDefaults.standard.data(forKey: "favoriteItems") {
            do {
                return try JSONDecoder().decode([Item].self, from: data)
            } catch {
                print("Fehler beim Dekodieren der Favoriten: \(error)")
            }
        }
        return []
    }

 func getAllFavorites() -> [Item] {
     return getFavoriteItems()
 }
}

#Preview {
    Favourites()
}
