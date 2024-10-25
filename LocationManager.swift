import Foundation
import CoreLocation

class locationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    let manager = CLLocationManager()
    
    @Published var latitude: Double?
    @Published var longitude: Double?
    @Published var isLoading = false
    
    override init() {
        super.init()
        manager.delegate = self
        manager.requestWhenInUseAuthorization() // Request permission to use location services
    }
    
    func requestLocation() {
        isLoading = true
        manager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let firstLocation = locations.first {
            latitude = firstLocation.coordinate.latitude
            longitude = firstLocation.coordinate.longitude
        }
        isLoading = false
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        isLoading = false
        print("Failed to find user's location: \(error.localizedDescription)")
    }
}
