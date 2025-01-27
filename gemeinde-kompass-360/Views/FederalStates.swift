import Foundation
import SwiftUI
import Combine
import MapKit

struct FederalState: Identifiable, Codable {
    let id: Int
    let name: String
    let abbreviation: String
    let description: String
}

struct FederalStatesResponse: Codable {
    let federal_states: [FederalState]
}

@MainActor
class FederalStatesViewModel: ObservableObject {
    @Published var federalStates: [FederalState] = []
    @Published var overlays: [MKOverlay] = []
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        Task {
            await fetchFederalStates()
            await loadGeoJSON()
        }
    }
    
    func fetchFederalStates() async {
        guard let url = URL(string: "https://www.gk360.at/api/federal-states/?action=all") else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(FederalStatesResponse.self, from: data)
            self.federalStates = response.federal_states
        } catch {
            print("Error fetching federal states: \(error)")
        }
    }
    
    func loadGeoJSON() async {
        guard let url = Bundle.main.url(forResource: "federal_states", withExtension: "geojson") else { return }
        
        do {
            let data = try Data(contentsOf: url)
            let geoJSON = try MKGeoJSONDecoder().decode(data)
            let features = geoJSON.compactMap { $0 as? MKGeoJSONFeature }
            let polygons = features.compactMap { feature in
                feature.geometry.compactMap { $0 as? MKPolygon }
            }.flatMap { $0 }
            self.overlays = polygons
        } catch {
            print("Error loading GeoJSON: \(error)")
        }
    }
}

struct FederalStatesMapView: UIViewRepresentable {
    @Binding var overlays: [MKOverlay]
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.addOverlays(overlays)
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.addOverlays(overlays)

    // Kartenausschnitt so setzen, dass das erste Overlay sichtbar ist
    if let firstOverlay = overlays.first {
        uiView.setVisibleMapRect(firstOverlay.boundingMapRect, animated: true)
    }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: FederalStatesMapView
        
        init(_ parent: FederalStatesMapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polygon = overlay as? MKPolygon {
                let renderer = MKPolygonRenderer(polygon: polygon)
                renderer.fillColor = UIColor.random().withAlphaComponent(0.5)
                renderer.strokeColor = .black
                renderer.lineWidth = 1
                return renderer
            }
            print(overlay)
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}

extension UIColor {
    static func random() -> UIColor {
        return UIColor(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1),
            alpha: 1.0
        )
    }
}

struct FederalStatesView: View {
    @StateObject private var viewModel = FederalStatesViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                FederalStatesMapView(overlays: $viewModel.overlays)
                    .frame(height: 300)
                    .cornerRadius(10)
                    .padding()
                
                List(viewModel.federalStates) { state in
                    VStack(alignment: .leading) {
                        Text(state.name)
                            .font(.headline)
                        Text(state.description)
                            .font(.subheadline)
                    }
                    .padding(.vertical, 8)
                }
                .navigationTitle("Federal States")
            }
        }
    }
}
