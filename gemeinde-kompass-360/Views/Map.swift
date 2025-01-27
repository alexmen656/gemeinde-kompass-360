import SwiftUI
import MapKit

struct FullScreenMapView: View {
    @Binding var region: MKCoordinateRegion
    var gemeinde: Item

    var body: some View {
        Map(coordinateRegion: $region, annotationItems: [gemeinde]) { item in
            MapMarker(coordinate: CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude), tint: .red)
        }
        .edgesIgnoringSafeArea(.all)
        .navigationBarTitle(Text(gemeinde.name), displayMode: .inline)
    }
}

import SwiftUI
import MapKit

class MapsViewModel: ObservableObject {
    @Published var overlays: [MKOverlay] = []
    
    init() {
        loadGeoJSON()
    }
    
    private func loadGeoJSON() {
        print("Lade federal_states.geojson...")
        guard let url = Bundle.main.url(forResource: "federal_states", withExtension: "geojson") else {
            print("federal_states.geojson nicht gefunden.")
            return
        }
        
        do {
            print("Lese GeoJSON-Daten...")
            let data = try Data(contentsOf: url)
            print("Entschlüssele GeoJSON...")
            let geoJSON = try MKGeoJSONDecoder().decode(data)
            
            print("Extrahiere MKGeoJSONFeatures...")
            let features = geoJSON.compactMap { $0 as? MKGeoJSONFeature }
            
            print("Erstelle MKPolygons...")
            let polygons = features.compactMap { feature in
                feature.geometry.compactMap { $0 as? MKPolygon }
            }.flatMap { $0 }
            
            print("Anzahl der Polygone: \(polygons.count)")
            overlays = polygons
            print("Fertig mit Laden des GeoJSONs.")
        } catch {
            print("Fehler beim Laden des GeoJSON: \(error)")
        }
    }
}
struct MapsRepresentable: UIViewRepresentable {
    @Binding var overlays: [MKOverlay]

    func makeUIView(context: Context) -> MKMapView {
        print("Erstelle MKMapView...")
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        print("Aktualisiere MKMapView mit Overlays. Anzahl: \(overlays.count)")
        uiView.removeOverlays(uiView.overlays)
        uiView.addOverlays(overlays)

        if let firstOverlay = overlays.first {
            print("Setze sichtbaren Bereich auf erstes Overlay...")
            uiView.setVisibleMapRect(firstOverlay.boundingMapRect, animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        print("Erstelle Coordinator...")
        return Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapsRepresentable

        init(_ parent: MapsRepresentable) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            print("Rendere Overlay...")
            if let polygon = overlay as? MKPolygon {
                let renderer = MKPolygonRenderer(polygon: polygon)
                renderer.fillColor = UIColor.blue.withAlphaComponent(0.3)
                renderer.strokeColor = .black
                renderer.lineWidth = 1
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}

struct MapsView: View {
    @StateObject private var viewModel = MapsViewModel()
    
    var body: some View {
        VStack {
            Text("Maps View")
                .font(.title)
                .padding()
            MapsRepresentable(overlays: $viewModel.overlays)
                .edgesIgnoringSafeArea(.all)
        }
        .navigationTitle("Maps")
    }
}