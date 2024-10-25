import SwiftUI
import CoreLocation

struct WeatherDescriptionView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var cityName: String = "Unknown"
    @State private var isLoading: Bool = true
    @StateObject private var weatherService = WeatherService()
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
            } else {
                if let firstAlert = weatherService.alerts.first {
                    if let description = firstAlert.description {
                        Text(description)
                            .font(.body)
                            .padding()
                    } else {
                        Text("No description available for \(cityName).")
                            .font(.body)
                            .padding()
                    }
                } else {
                    Text("No alerts for \(cityName).")
                        .bold()
                        .shadow(radius: 90)
                }
            }
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
    
    func reverseGeocode(location: CLLocation) {
        isLoading = true
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            DispatchQueue.main.async {
                if let placemark = placemarks?.first {
                    cityName = placemark.locality ?? "Unknown"
                    
                    // Fetch alerts after reverse geocoding
                    weatherService.fetchWeatherAlerts(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                } else {
                    cityName = "Error"
                    print("Error in reverse geocoding: \(error?.localizedDescription ?? "Unknown error")")
                }
                isLoading = false
            }
        }
    }
}

#Preview {
    WeatherDescriptionView()
}
