import SwiftUI
import MapKit

struct EvacuationMapView: View {
    @StateObject private var viewModel = LocationSearchViewModel()
    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var annotations: [HotelAnnotation] = []
    @State private var mapRegion: MKCoordinateRegion = .init(
        center: .init(latitude: 0, longitude: 0),
        span: .init(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    var body: some View {
        let manager = CLLocationManager()
        
        Map(position: $cameraPosition) {
            UserAnnotation()
            
            ForEach(annotations) { annotation in
                Marker(annotation.title, coordinate: annotation.coordinate)
                    .tint(.red)
            }
        }
        .mapControls {
            MapUserLocationButton()
        }
        .onAppear {
            manager.requestWhenInUseAuthorization()
            searchForHotels()
        }
    }
    
    private func searchForHotels() {
        viewModel.queryFragment = "Hotels"
        // Wait for results to be updated
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            var tempAnnotations: [HotelAnnotation] = []
            let group = DispatchGroup()
            
            for result in viewModel.results {
                group.enter()
                viewModel.getLocation(for: result) { mapItem in
                    if let mapItem = mapItem {
                        let annotation = HotelAnnotation(
                            id: UUID(),
                            title: result.title,
                            coordinate: mapItem.placemark.coordinate
                        )
                        tempAnnotations.append(annotation)
                    }
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                annotations = tempAnnotations
                zoomToFitAnnotations()
            }
        }
    }
    
    private func zoomToFitAnnotations() {
        guard !annotations.isEmpty else { return }
        
        var minLat = annotations[0].coordinate.latitude
        var maxLat = annotations[0].coordinate.latitude
        var minLon = annotations[0].coordinate.longitude
        var maxLon = annotations[0].coordinate.longitude
        
        for annotation in annotations {
            minLat = min(minLat, annotation.coordinate.latitude)
            maxLat = max(maxLat, annotation.coordinate.latitude)
            minLon = min(minLon, annotation.coordinate.longitude)
            maxLon = max(maxLon, annotation.coordinate.longitude)
        }
        
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        
        let span = MKCoordinateSpan(
            latitudeDelta: (maxLat - minLat) * 1.5, // 1.5 adds some padding
            longitudeDelta: (maxLon - minLon) * 1.5
        )
        
        // Update the camera position to show all annotations
        cameraPosition = .region(MKCoordinateRegion(
            center: center,
            span: span
        ))
    }
}

struct HotelAnnotation: Identifiable {
    let id: UUID
    let title: String
    let coordinate: CLLocationCoordinate2D
}

#Preview {
    EvacuationMapView()
}
