//
//  extensions.swift
//  gemeinde-kompass-360
//
//  Created by Alex Polan on 11/12/2023.
//

import Foundation

struct InfoItem: Identifiable, Codable {
    let id: Int
    let icon: String
    let name: String
    let data: String
}

extension Gemeinde {
    enum Category: String {
        case sports
        case expos
        case concerts
        case performing_arts
        case school_holidays
       // case music
        // Weitere Kategorien können hinzugefügt werden
        
        init?(rawValue: String) {
            switch rawValue {
            case "sports":
                self = .sports
            case "expos":
                self = .expos
            case "concerts":
                self = .concerts
            case "performing-arts":
                self = .performing_arts
            case "school-holidays":
                self = .school_holidays
                
            // Weitere Fälle für andere Kategorien können hinzugefügt werden
            default:
                return nil
            }
        }
    }

    func getIconNameForCategory(_ categoryString: String) -> String {
        let defaultIconName = "person.3.fill"//"questionmark" // Ein Standard-Icon, falls die Kategorie nicht erkannt wird

        guard let category = Category(rawValue: categoryString) else {
            return defaultIconName
        }

        switch category {
        case .sports:
            return "figure.soccer"
        case .expos:
            return "eye"
        case .concerts:
            return "music.note"
        case .performing_arts:
            return "theatermasks"
        case .school_holidays:
            return "backpack"
        default:
            return defaultIconName
        // Weitere Fälle für andere Kategorien können hinzugefügt werden
        }
    }
    
    func extractCity(from address: String) -> String? {
        // Aufteilen der Adresse in Zeilen
        let lines = address.components(separatedBy: "\n")

        // Überprüfen, ob genügend Zeilen vorhanden sind
        guard lines.count >= 2 else {
            // Rückgabe für den Fall, dass nicht genügend Zeilen vorhanden sind
            return nil
        }

        // Die zweite Zeile (Index 1) extrahieren
        var cityWithPostalCode = lines[1]

        // Trennen von Stadt und Postleitzahl
        let components = cityWithPostalCode.components(separatedBy: " ")
        
        // Überprüfen, ob genügend Komponenten vorhanden sind
        guard components.count >= 2 else {
            // Rückgabe für den Fall, dass nicht genügend Komponenten vorhanden sind
            print(address)
            return nil
        }

        // Nur die erste Komponente (Stadt) zurückgeben
        let city = components[1]
        return city
    }

    // Beispielaufruf


    
    func formattedDate2(_ date: String) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ" // Das aktuelle Format des Datums
        
        if let date = dateFormatter.date(from: date) {
            dateFormatter.dateFormat = "dd.MM.yyyy" // Das gewünschte Format HH:mm
            let formattedDate = dateFormatter.string(from: date)
            print("Umgewandeltes Datum: \(formattedDate)")
            return formattedDate
        } else {
            print("Fehler beim Umwandeln des Datums")
            return "Ungültiges Datum und/oder Zeit"

        }
    }
        
    func formattedDate(_ date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" // Das Format sollte an deine Datenstruktur angepasst werden
        if let date = dateFormatter.date(from: date) {
            let formattedDateFormatter = DateFormatter()
            formattedDateFormatter.dateFormat = "dd.MM.yyyy" // Das gewünschte Ausgabeformat
            return formattedDateFormatter.string(from: date)
        } else {
            return "Ungültiges Datum"
        }
    }
    
    func like(item: Item) {
           var favoriteItems = getFavoriteItems()

           if !favoriteItems.contains(where: { $0.id == item.id }) {
               favoriteItems.append(item)
               saveFavoriteItems(items: favoriteItems)
               isLiked = true
               print("\(item.name) wurde zu den Favoriten hinzugefügt.")
           } else {
               print("\(item.name) ist bereits in den Favoriten.")
           }
       }

       func unlike(item: Item) {
           var favoriteItems = getFavoriteItems()

           if let index = favoriteItems.firstIndex(where: { $0.id == item.id }) {
               favoriteItems.remove(at: index)
               saveFavoriteItems(items: favoriteItems)
               isLiked = false
               print("\(item.name) wurde aus den Favoriten entfernt.")
           } else {
               print("\(item.name) ist nicht in den Favoriten.")
           }
       }

       func isItemLiked(item: Item) -> Bool {
           let favoriteItems = getFavoriteItems()
           return favoriteItems.contains(where: { $0.id == item.id })
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

       private func saveFavoriteItems(items: [Item]) {
           if let encodedData = try? JSONEncoder().encode(items) {
               UserDefaults.standard.set(encodedData, forKey: "favoriteItems")
           } else {
               print("Fehler beim Codieren der Favoriten.")
           }
       }
    
    func getAllFavorites() -> [Item] {
        return getFavoriteItems()
    }
}
