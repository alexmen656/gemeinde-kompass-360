import SwiftUI
import MapKit

struct FederalStatesView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 47.6964, longitude: 13.3458),
        span: MKCoordinateSpan(latitudeDelta: 4.8, longitudeDelta: 4.0)
    )
    
    let federalStates = [
        ("Burgenland", "Known for its wine production and Lake Neusiedl."),
        ("Carinthia", "Famous for its mountains and lakes."),
        ("Lower Austria", "The largest state by area, surrounding Vienna."),
        ("Upper Austria", "Home to the city of Linz and the Danube River."),
        ("Salzburg", "Famous for its baroque architecture and music festivals."),
        ("Styria", "Known for its vineyards and the city of Graz."),
        ("Tyrol", "Renowned for its alpine skiing resorts."),
        ("Vorarlberg", "The westernmost state, known for its mountains."),
        ("Vienna", "The capital city of Austria, known for its cultural heritage.")
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    FederalStatesMapView(region: $region)
                        .frame(height: 300)
                        .padding()
                    
                    // Liste der Bundesländer mit Beschreibungen
                    ForEach(federalStates, id: \.0) { state, description in
                        VStack(alignment: .leading) {
                            Text(state)
                                .font(.headline)
                                .padding(.bottom, 2)
                            Text(description)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Federal States")
        }
    }
}

struct FederalStatesMapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.setRegion(region, animated: true)
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.setRegion(region, animated: true)
    }
}

struct FederalStatesView_Previews: PreviewProvider {
    static var previews: some View {
        FederalStatesView()
    }
}