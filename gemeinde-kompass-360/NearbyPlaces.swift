//
//  NearbyPlaces.swift
//  gemeinde-kompass-360
//
//  Created by Alex Polan on 11/12/2023.
//

//
//  ContentView.swift
//  StoreFinder
//
//  Created by Alex Polan on 12/12/2023.
//

import SwiftUI
import MapKit



struct NearbyPlacesView: View {
    var body: some View {
        Text("hello")
    }
  /*  let categories: [PlaceCategory] = [
        PlaceCategory(name: "Restaurants", query: "restaurants"),
        PlaceCategory(name: "Hotels", query: "hotels"),
        PlaceCategory(name: "Shops", query: "shops"),
        PlaceCategory(name: "Coffees", query: "caffe"),
        PlaceCategory(name: "Brauerei", query: "brauerei"),
        // Füge weitere Kategorien nach Bedarf hinzu
    ]

    var placeName: String
    var postalCode: String
    @State private var places: [PlaceCategory: [MKMapItem]] = [:]



    var body: some View {
        Text("Hello")
  List {
                    ForEach(categories, id: \.self) { category in
                        Section(header: Text(category.name)) {
                            if let categoryPlaces = places[category] {
                                ForEach(categoryPlaces, id: \.self) { place in
                                    VStack(alignment: .leading) {
                                        Text(place.name ?? "Unbekannter Ort")
                                            .font(.headline)
                                        Text(place.placemark.title ?? "")
                                            .font(.subheadline)
                                    }
                                }
                            }
                        }
                    }
  }
                .listStyle(InsetGroupedListStyle())
                .padding()
                .onAppear {
                    searchForPlaces(pc: self.postalCode, pn: self.placeName)

                }
               
    }

    func searchForPlaces(pc: String, pn: String) {
        var allPlaces: [PlaceCategory: [MKMapItem]] = [:]

        for category in categories {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = "\(category.query) \(placeName) \(postalCode)"

            let search = MKLocalSearch(request: request)
            search.start { response, error in
                DispatchQueue.main.async {
                    
                    if let items = response?.mapItems {
                        let filteredPlaces = items.filter { item in
                            let locationPostalCode = item.placemark.postalCode?.lowercased() ?? ""
                            let expectedPostalCode = postalCode.lowercased()
                            return locationPostalCode.contains(expectedPostalCode)
                        }
                        allPlaces[category] = filteredPlaces
                        self.places = allPlaces
                    } else {
                        print("Fehler bei der Suche nach \(category.name): \(error?.localizedDescription ?? "Unbekannter Fehler")")
                    }
                }
            }
        }
    }*/
}



#Preview {
    NearbyPlacesView()//placeName: "Deutsch Jahrndorf", postalCode: "2423"
}
