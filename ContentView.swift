import SwiftUI
import CoreLocation
import Foundation

struct WeatherAlert: Codable, Identifiable {
    var id: String
    var headline: String
    var description: String?
    var instruction: String?
    var severity: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case headline
        case description
        case instruction
        case severity
    }
}

struct WeatherAlertResponse: Codable {
    let features: [Feature]
    
    struct Feature: Codable {
        let id: String
        let properties: WeatherAlert
    }
}

class WeatherService: ObservableObject {
    @Published var alerts: [WeatherAlert] = []
    
    func fetchWeatherAlerts(latitude: Double, longitude: Double) {
        let urlString = "https://api.weather.gov/alerts/active?point=\(latitude),\(longitude)"
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            if let data = data {
                do {
                    let decodedResponse = try JSONDecoder().decode(WeatherAlertResponse.self, from: data)
                    DispatchQueue.main.async {
                        self?.alerts = decodedResponse.features.map { $0.properties }
                    }
                } catch {
                    print("Error decoding data: \(error)")
                }
            }
        }
        
        task.resume()
    }
}

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var cityName: String = "Unknown"
    @State private var regionName: String = "Unknown"
    @State private var isLoading: Bool = true
    @StateObject private var weatherService = WeatherService()
    
    var body: some View {
        
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.purple, Color.orange]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)
                
                VStack {
                    MapViewPreview()
                        .padding(.bottom, 20)
                    
                    if isLoading {
                        ProgressView()
                            .scaleEffect(1.5) // Enlarged for visibility
                            .padding()
                    } else {
                        VStack(alignment: .center) {
                            // Background and padding for better readability
                            Text("Location: \(cityName), \(regionName)")
                                .foregroundColor(.white)
                                .font(.headline)
                                .padding()
                                .background(Color.black.opacity(0.4))
                                .cornerRadius(10)
                            
                            if weatherService.alerts.isEmpty {
                                Text("No alerts for \(cityName).")
                                    .bold()
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.black.opacity(0.4))
                                    .cornerRadius(10)
                            } else {
                                ScrollView {
                                    ForEach(weatherService.alerts) { alert in
                                        VStack(alignment: .leading) {
                                            Text(alert.headline)
                                                .bold()
                                                .font(.title2)
                                                .foregroundColor(.white)
                                                .padding(.bottom, 2)
                                            
                                            Text("Severity: \(alert.severity)")
                                                .foregroundColor(severityColor(for: alert.severity))
                                                .bold()
                                        }
                                        .padding()
                                        .background(Color.black.opacity(0.3))
                                        .cornerRadius(10)
                                        .shadow(radius: 5)
                                    }
                                }
                                .padding(.horizontal)
                            }
                            

                        }
                        .padding()
                    }
                }
                .padding() // To prevent text from touching the edges
            }
            .onReceive(locationManager.$location) { location in
                if let location = location {
                    reverseGeocode(location: location)
                }
            }
            .alert(isPresented: $locationManager.showAlert) {
                Alert(title: Text("Location Error"), message: Text(locationManager.errorMessage), dismissButton: .default(Text("OK")))
            }
        
    }
    
    private func severityColor(for severity: String) -> Color {
        switch severity {
        case "Extreme":
            return .red
        case "Severe":
            return .orange
        case "Moderate":
            return .yellow
        case "Minor":
            return .green
        default:
            return .gray
        }
    }
    
    func reverseGeocode(location: CLLocation) {
        isLoading = true
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            DispatchQueue.main.async {
                if let placemark = placemarks?.first {
                    cityName = placemark.locality ?? "Unknown"
                    regionName = placemark.administrativeArea ?? "Unknown"
                    
                    // Fetch alerts after reverse geocoding
                    weatherService.fetchWeatherAlerts(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                } else {
                    cityName = "Error"
                    regionName = "Error"
                    print("Error in reverse geocoding: \(error?.localizedDescription ?? "Unknown error")")
                }
                isLoading = false
            }
        }
    }
}


class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    @Published var location: CLLocation?
    @Published var showAlert = false
    @Published var errorMessage = ""
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.location = location
            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorMessage = error.localizedDescription
        showAlert = true
        print("Failed to get location: \(error.localizedDescription)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            errorMessage = "Location access is restricted or denied. Please enable it in Settings."
            showAlert = true
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        @unknown default:
            break
        }
    }
}

#Preview {
    ContentView()
}
