//
//  Gemeinde.swift
//  gemeinde-kompass-360
//
//  Created by Alex Polan on 15/11/2023.
//

import SwiftUI
import Foundation
import MapKit
import Alamofire
import WeatherKit
import CoreLocation

/*struct Item: Identifiable, Codable {
   // let bezirk: String
    //let bundesland: String
    let id: Int
   // let type: String
    let name: String
    let image: String
    let coat_of_arms: String
    //let beschreibung: String
    let code: String
    let postal_code: String
    let identifier: String
    let opening_hours: String?
    let mayor: String
    //let zuletzt_bearbeitet: String//Date
    let homepage: String
    let adress: String
    let phone: String
    let email: String
//    let art: String
    let area: Float
    let population: Int
    let federal_state: String
    let district: String
    let municipality_id: Int
}*/

struct Item: Identifiable, Codable {
    let id: Int
    let code: String
    let name: String
    let postalCode: String
    let identifier: String
    let coatOfArms: String
    let homepage: String
    let longitude: Double
    let latitude: Double
    let municipalityId: Int
    let mayor: String
    let population: Int
    let area: Double
    let district: String
    let federalState: String
    let email: String
    let phone: String
    let address: String
    let openingHours: String?
    let image: String

    enum CodingKeys: String, CodingKey {
        case id
        case code
        case name
        case postalCode = "postal_code"
        case identifier
        case coatOfArms = "coat_of_arms"
        case homepage
        case longitude
        case latitude
        case municipalityId = "municipality_id"
        case mayor
        case population
        case area
        case district
        case federalState = "federal_state"
        case email
        case phone
        case address
        case openingHours = "opening_hours"
        case image
    }
}


struct PlacesView: View {
    var places:  [PlaceCategory: [MKMapItem]]
    var categories: [PlaceCategory]
    
    var body: some View {
        List(categories, id: \.self) { category in
            if let categoryPlaces = places[category] {
                if(categoryPlaces.count > 0){
                    
               
                Section(header: Text(category.name).font(.title)) {
                        
                        ForEach(categoryPlaces, id: \.self) { place in
                    

                                
                                VStack(alignment: .leading) {
                                    Text(place.name ?? "Unbekannter Ort")
                                        .font(.headline)
                                    Text(place.placemark.title?.components(separatedBy: ",").first ?? "")
                                        .font(.subheadline)
                                }
                                .padding(5)
                            
                            
                            
                        }
                    }
                }
                }
            }
        }
    }

struct EventsView: View {
    var events: [Event] = []
    var gemeinde: Item

    var body: some View {
     //   NavigationView {
            
           List(events) { event in
                HStack {
                    ZStack {
                        Circle()
                            .foregroundColor(Color.white)
                            .shadow(radius: 3)
                            .frame(width: 50, height: 50)
                        //      .aspectRatio(1.0, contentMode: .fit)
                        Image(systemName: Gemeinde(gemeinde: gemeinde).getIconNameForCategory(event.category ?? ""))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 24)
                            .foregroundColor(.black)
                    }
                    .frame(alignment: .leading)
                    VStack(alignment: .leading) {
                        Text(event.eventName ?? "No name").font(.headline)
                        HStack {
                            HStack {
                                
                                Image(systemName: "calendar")
                                Text(Gemeinde(gemeinde: gemeinde).formattedDate2(event.eventDate ?? "")).font(.subheadline)
                            }
                            if let entities = event.entities, let firstEntity = entities.first {
                                HStack {
                                    
                                    
                                    Image(systemName: "mappin.and.ellipse")
                                    if let city = Gemeinde(gemeinde: gemeinde).extractCity(from: firstEntity.formattedAddress ?? "") {
                                        
                                        
                                        Text(city).font(.subheadline)
                                        
                                    } else {
                                        Text("Nicht bekannt").font(.subheadline)
                                        
                                    }
                                }
                            }
                        }
                    }.padding(5)
                    
                } /*.frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .clipShape(Capsule())
                    .shadow(radius: 3)
                    .padding(.leading, 15)
                    .padding(.trailing, 15)
                    .padding(.bottom, 8)*/
            }   }
    //}
}

struct Event: Decodable, Identifiable {
    let id: String
    var eventName: String?
    let eventDate: String?
    let locationName: String?
    let entities: [EventEntity]?
    let category: String?
    enum CodingKeys: String, CodingKey {
        case id
        case eventName = "title"
        case eventDate = "start"
        case locationName
        case entities
        case category
    }
}

struct EventEntity: Decodable {
    let formattedAddress: String?

    enum CodingKeys: String, CodingKey {
        case formattedAddress = "formatted_address"
    }
}
 
struct PlaceCategory: Hashable {
    var name: String
    var query: String
    var icon: String
}
 
extension CLLocationCoordinate2D {
    static let gemeinde_amt = CLLocationCoordinate2D(latitude: 48.048611, longitude: 16.941389)
}

import SwiftUI
import Foundation
import MapKit
import Alamofire

struct Gemeinde: View {
    let categories: [PlaceCategory] = [
        PlaceCategory(name: "Restaurants", query: "restaurants", icon: "fork.knife"),
        PlaceCategory(name: "Hotels", query: "hotels", icon: "bed.double"),
        PlaceCategory(name: "Geschäfte", query: "shops", icon: "cart"),
        PlaceCategory(name: "Cafés", query: "caffe", icon: "cup.and.saucer"),
        PlaceCategory(name: "Brauereien", query: "brauerei", icon: "wineglass"),
    ]
    
    @State private var places: [PlaceCategory: [MKMapItem]] = [:]
    @State private var events: [Event] = []
    @State private var isMore = false
    @State private var showPlaces = false
    @State private var region: MKCoordinateRegion
    @State private var showFullScreenMap = false
    @State private var currentWeather: Weather?


    var gemeinde: Item
    
    init(gemeinde: Item) {
        self.gemeinde = gemeinde
        _region = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: gemeinde.latitude, longitude: gemeinde.longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))
    }

    private var info: [InfoItem] {
        [
            InfoItem(id: 1, icon: "shippingbox", name: "Postleitzahl", data: gemeinde.postalCode),
            InfoItem(id: 2, icon: "link", name: "Homepage", data: gemeinde.homepage),
            InfoItem(id: 3, icon: "person.text.rectangle", name: "Bürgermeister", data: gemeinde.mayor),
            InfoItem(id: 4, icon: "mappin.and.ellipse", name: "Fläche", data: "\(gemeinde.area)km²"),
            InfoItem(id: 5, icon: "person.3", name: "Einwohner", data: "\(gemeinde.population)"),
        ]
    }
    
    let columns = [
        GridItem(.flexible(minimum: 150, maximum: .infinity), alignment: .center),
        GridItem(.flexible(minimum: 150, maximum: .infinity), alignment: .center),
    ]
    
    let columns2 = [
        GridItem(.flexible(minimum: 150, maximum: .infinity)),
    ]
    
    @State private var nearbyPlaces: [MKMapItem] = []
    @State public var isLiked = false
    
    var body: some View {
        ScrollView {
            VStack {
                ZStack {
                    VStack {
                        AsyncImage(url: URL(string: gemeinde.image)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                            case .failure:
                                Image("CardImage")
                                    .resizable()
                                    .scaledToFill()
                            @unknown default:
                                Image("CardImage")
                                    .resizable()
                                    .scaledToFill()
                            }
                        }
                        
                        Rectangle().fill(Color.yellow).frame(height: 100).padding(0)
                    }
                    
                    VStack {
                        Spacer()
                        VStack {
                            AsyncImage(url: URL(string: gemeinde.coatOfArms)) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100, height: 120).padding(.top, 8)
                                case .failure:
                                    Text("Wappen konnte nicht geladen werden")
                                @unknown default:
                                    Text("Wappen konnte nicht geladen werden")
                                }
                            }
                        }.frame(width: 180, height: 180).background(Color.white)
                            .clipShape(Circle()).overlay {
                                Circle().stroke(.white, lineWidth: 4)
                            }
                            .shadow(radius: 4).padding(.bottom, 15)
                    }
                }
                .padding(0)
                .ignoresSafeArea()
                
                VStack {
                    Text(gemeinde.name).font(.title)
                }.padding(.trailing, 15).padding(.leading, 15)
                
                Button(action: {
                    if self.isLiked {
                        self.unlike(item: gemeinde)
                    } else {
                        self.like(item: gemeinde)
                    }
                }) {
                    HStack {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 16)
                            .foregroundColor(isLiked ? .red : .black)
                        
                        Text(isLiked ? "Favorisiert" : "Favorisieren")
                            .foregroundColor(isLiked ? .red : .black)
                            .imageScale(.large)
                            .padding()
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12.0))
                    .shadow(radius: 3)
                    .padding(.top, 5)
                    .padding(.leading, 15)
                    .padding(.trailing, 15)
                }
                
                HStack {
                    Spacer()
                    LazyVGrid(columns: columns, spacing: 0) {
                        ForEach(info) { item in
                            VStack(alignment: .center, spacing: 10) {
                                Spacer()
                                Image(systemName: item.icon)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 32)
                                Text("\(item.name)\n\(item.data)").multilineTextAlignment(.center)
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 20.0))
                            .shadow(radius: 5)
                            .padding(.top, 10)
                            .padding(.bottom, 10)
                            .padding(.leading, 5)
                            .padding(.trailing, 5)
                        }
                    }
                    Spacer()
                }
                
                LazyVGrid(columns: columns2, spacing: 20) {
                    VStack {
                        VStack {
                            Text("Adresse des Gemeindeamtes")
                            Text(gemeinde.address.replacingOccurrences(of: "<br>", with: "\n"))
                        }.padding(20)
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20.0))
                    .shadow(radius: 8)
                    .padding(.leading, 15)
                    .padding(.trailing, 15)
                    
                    if let wetter = currentWeather {
                VStack {
                    Text("Aktuelles Wetter")
                        .font(.headline)
                    Text("\(wetter.currentWeather.temperature.value, specifier: "%.1f")°C")
                        .font(.subheadline)
                        .padding()
                }
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 20.0))
                .shadow(radius: 8)
                .padding(.leading, 15)
                .padding(.trailing, 15)
            } else {
                VStack {
                    Text("Aktuelles Wetter")
                        .font(.headline)
                    Text("12°C Sonnig")
                        .font(.subheadline)
                        .padding()
                }
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 20.0))
                .shadow(radius: 8)
                .padding(.leading, 15)
                .padding(.trailing, 15)
                .onAppear {
                    Task {
                        await loadWeather()
                    }
                }
            }

                    VStack {
                        VStack {
                            Text("Kontakt")
                            Text("Email:  \(gemeinde.email)\nTelefon: \(gemeinde.phone)")
                        }.padding(20)
                    }.frame(maxWidth: .infinity)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20.0))
                        .shadow(radius: 8)
                        .padding(.leading, 15)
                        .padding(.trailing, 15)
                }
                
                // Add the map view here
                Map(coordinateRegion: $region, annotationItems: [gemeinde]) { item in
                    MapMarker(coordinate: CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude), tint: .red)
                }
                .frame(height: 300)
                .cornerRadius(20)
                .padding(.leading, 15)
                .padding(.trailing, 15)
                
                if events.count > 0 {
                    VStack {
                        Section(header: Text("Veranstaltungen").font(.title)) {
                            ForEach(events.prefix(3)) { event in
                                HStack {
                                    ZStack {
                                        Circle()
                                            .foregroundColor(Color.white)
                                            .shadow(radius: 3)
                                            .frame(width: 50, height: 50)
                                        Image(systemName: getIconNameForCategory(event.category ?? ""))
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(height: 24)
                                            .foregroundColor(.black)
                                    }
                                    .frame(alignment: .leading)
                                    VStack(alignment: .leading) {
                                        Text(event.eventName ?? "No name").font(.headline)
                                        HStack {
                                            HStack {
                                                Image(systemName: "calendar")
                                                Text(formattedDate2(event.eventDate ?? "")).font(.subheadline)
                                            }
                                            if let entities = event.entities, let firstEntity = entities.first {
                                                HStack {
                                                    Image(systemName: "mappin.and.ellipse")
                                                    if let city = extractCity(from: firstEntity.formattedAddress ?? "") {
                                                        Text(city).font(.subheadline)
                                                    } else {
                                                        Text("Nicht bekannt").font(.subheadline)
                                                    }
                                                }
                                            }
                                        }
                                    }.padding(5)
                                }.frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.white)
                                    .clipShape(Capsule())
                                    .shadow(radius: 3)
                                    .padding(.leading, 15)
                                    .padding(.trailing, 15)
                                    .padding(.bottom, 8)
                            }
                            if(events.count > 3) {
                                NavigationLink(destination: EventsView(events: events, gemeinde: gemeinde)) {
                                    Text("Alle Ansehen")
                                }
                            }
                        }
                    }.padding(.top, 30)
                }
                
                if (showPlaces) {
                    VStack {
                        Section(header: Text("In der Nähe").font(.title)) {
                            ForEach(categories, id: \.self) { category in
                                if let categoryPlaces = places[category] {
                                    ForEach(categoryPlaces.prefix(2), id: \.self) { place in
                                        HStack {
                                            ZStack {
                                                Circle()
                                                    .foregroundColor(Color.white)
                                                    .shadow(radius: 3)
                                                    .frame(width: 50, height: 50)
                                                Image(systemName: category.icon)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(height: 24)
                                                    .foregroundColor(.black)
                                            }
                                            .frame(alignment: .leading)
                                            
                                            VStack(alignment: .leading) {
                                                Text(place.name ?? "Unbekannter Ort")
                                                    .font(.headline)
                                                Text(place.placemark.title?.components(separatedBy: ",").first ?? "")
                                                    .font(.subheadline)
                                            }
                                            .padding(5)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color.white)
                                        .clipShape(Capsule())
                                        .shadow(radius: 3)
                                        .padding(.leading, 15)
                                        .padding(.trailing, 15)
                                        .padding(.bottom, 8)
                                    }.onAppear {
                                        if(categoryPlaces.count > 2) {
                                            isMore = true
                                        }
                                    }
                                }
                            }
                            if(isMore) {
                                NavigationLink(destination: PlacesView(places: places, categories: categories)) {
                                    Text("Alle Ansehen")
                                }
                            }
                        }
                    }.padding(.top, 30)
                }

                Map(coordinateRegion: $region, annotationItems: [gemeinde]) { item in
                    MapMarker(coordinate: CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude), tint: .red)
                }
                .frame(height: 300)
                .cornerRadius(20)
                .padding(.leading, 15)
                .padding(.trailing, 15)
                .onTapGesture {
                    showFullScreenMap.toggle()
                }
                .sheet(isPresented: $showFullScreenMap) {
                    FullScreenMapView(region: $region, gemeinde: gemeinde)
                }
            }
            .padding(.bottom, 100)
        }
        .ignoresSafeArea()
        .onAppear {
            self.isLiked = self.isItemLiked(item: gemeinde)
            self.searchForEvents(pc: gemeinde.postalCode, pn: gemeinde.name)
            searchForPlaces(pc: gemeinde.postalCode, pn: gemeinde.name)
        }
    }
    
    func loadWeather() async {
        do {
            let service = WeatherService.shared
            let location = CLLocation(latitude: gemeinde.latitude, longitude: gemeinde.longitude)
            currentWeather = try await service.weather(for: location)
        } catch {
            print("Fehler beim Abrufen des Wetters: \(error)")
        }
    }

    func findCoordinates(forLocation locationName: String, andPostalCode postalCode: String, completion: @escaping (CLLocationCoordinate2D?, Error?) -> Void) {
        let geocoder = CLGeocoder()
        let addressString = "\(locationName) \(postalCode)"
        geocoder.geocodeAddressString(addressString) { (placemarks, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            if let firstPlacemark = placemarks?.first {
                let coordinates = firstPlacemark.location?.coordinate
                completion(coordinates, nil)
            } else {
                let noCoordinatesError = NSError(domain: "LocationErrorDomain", code: 0, userInfo: [NSLocalizedDescriptionKey: "Keine Koordinaten gefunden"])
                completion(nil, noCoordinatesError)
            }
        }
    }
    
    func searchForPlaces(pc: String, pn: String) {
        var allPlaces: [PlaceCategory: [MKMapItem]] = [:]
        for category in categories {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = "\(category.query) \(pn) \(pc)"
            let search = MKLocalSearch(request: request)
            search.start { response, error in
                DispatchQueue.main.async {
                    if let items = response?.mapItems {
                        let filteredPlaces = items.filter { item in
                            let locationPostalCode = item.placemark.postalCode?.lowercased() ?? ""
                            let expectedPostalCode = pc.lowercased()
                            return locationPostalCode.contains(expectedPostalCode)
                        }
                        allPlaces[category] = filteredPlaces
                        if(filteredPlaces.count > 0) {
                            self.showPlaces = true
                        }
                        self.places = allPlaces
                    } else {
                        print("Fehler bei der Suche nach \(category.name): \(error?.localizedDescription ?? "Unbekannter Fehler")")
                    }
                }
            }
        }
    }
    
    func searchForEvents(pc: String, pn: String) {
        findCoordinates(forLocation: pn, andPostalCode: pc) { (coordinates, error) in
            if let coordinates = coordinates {
                let accessToken = "JnwnhjustItMpswsF_1B6jQe1WhQEIyCMyKHPGYN"
                let apiUrl = "https://api.predicthq.com/v1/events/"
                let queryParameters: [String: Any] = ["q": "", "country": "AT", "location_around.origin": "\(coordinates.latitude),\(coordinates.longitude)", "location_around.offset": "40km"]
                let headers: HTTPHeaders = [
                    "Authorization": "Bearer \(accessToken)",
                    "Accept": "application/json"
                ]
                AF.request(apiUrl, method: .get, parameters: queryParameters, headers: headers)
                    .validate()
                    .responseJSON { response in
                        switch response.result {
                        case .success(let data):
                            if let jsonData = try? JSONSerialization.data(withJSONObject: data) {
                                let jsonString = String(data: jsonData, encoding: .utf8)
                                print("Decoded JSON String: \(jsonString ?? "Failed to convert to string")")
                                do {
                                    guard let jsonObject = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
                                          let results = jsonObject["results"] as? [[String: Any]] else {
                                        print("Invalid JSON format")
                                        return
                                    }
                                    let jsonData = try JSONSerialization.data(withJSONObject: results)
                                    let decodedEvents = try JSONDecoder().decode([Event].self, from: jsonData)
                                    print("Decoded Events: \(decodedEvents)")
                                    self.events = decodedEvents
                                } catch {
                                    print("Decoding Error: \(error)")
                                }
                            }
                        case .failure(let error):
                            print("Fehler bei der API-Anfrage: \(error.localizedDescription)")
                        }
                    }
            } else if let error = error {
                print("Fehler: \(error.localizedDescription)")
            }
        }
    }
}

/*#Preview {
    Gemeinde(gemeinde: Item(
        id: 1,
        type: "gemeinde",
        name: "Deutsch Jahrndorf",
        bild: "dornbirn.jpg",
        wappen: "andau_wappen.jpg",
        beschreibung: "Eine Beispielgemeinde mit vielen Merkmalen.",
        code: "123",
        plz: "2423",
        kennziffer: "12344",
        oeffnungszeiten: "9:00 - 17:00 Uhr",
        buergermeister: "Max Mustermann",
        zuletzt_bearbeitet: "2023-11-16",
        homepage: "deutsch-jahrndorf.at",
        adresse: "Biergasse 94\n4567 Kackendorf",
        telefon: "+43 35555444",
        email: "penis@penisshop.de",
        art: "Großstadt",
        flaeche: 300.87,
        einwohner: 556
    ))
}*/

/*  Map{
 Annotation("Gemeindeamt", coordinate: .gemeinde_amt) {
 ZStack {
 Image(systemName: "home")
 }
 }
 }.frame(height: 500)*/
/*   Text("Letzte Aktualisierung: \(formattedDate(gemeinde.zuletzt_bearbeitet))").padding(.bottom, 50).padding(.top, 30)
 */
