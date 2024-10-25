

import SwiftUI
import MapKit

struct MapView: View {
    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    
    var body: some View {
        let manager = CLLocationManager()

        Map(position: $cameraPosition) {
            UserAnnotation()
        }
        
        .mapControls{
            MapUserLocationButton()
        }
        .onAppear {
            manager.requestWhenInUseAuthorization()
        }
    }
}

#Preview {
    MapView()
}
