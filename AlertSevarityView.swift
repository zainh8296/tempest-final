import SwiftUI
import CoreLocation

struct AlertSeverityView: View {
    @StateObject private var weatherService = WeatherService()
    @State private var locationName: String = "Unknown"
    @State private var isLoading: Bool = true
    @StateObject private var locationManager = LocationManager()

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Fetching weather alerts...")
            } else {
                if weatherService.alerts.isEmpty {
                    Text("No weather alerts for \(locationName).")
                        .foregroundColor(.gray)
                } else {
                    ForEach(weatherService.alerts) { alert in
                        VStack(alignment: .leading) {
                            
                            Text("\(alert.severity)")
                                .font(.subheadline)
                                .foregroundColor(severityColor(for: alert.severity))
                                .bold()
                        }
                        .padding()
                    }
                }
            }
        }
        .onAppear {
            // Fetch location and weather alerts when the view appears
            if let location = locationManager.location {
                reverseGeocode(location: location)
            }
        }
        .onReceive(locationManager.$location) { location in
            if let location = location {
                reverseGeocode(location: location)
            }
        }
        .alert(isPresented: $locationManager.showAlert) {
            Alert(
                title: Text("Location Error"),
                message: Text(locationManager.errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private func reverseGeocode(location: CLLocation) {
        isLoading = true
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            DispatchQueue.main.async {
                if let placemark = placemarks?.first {
                    locationName = placemark.locality ?? "Unknown"
                    
                    // Fetch weather alerts for the reverse-geocoded location
                    weatherService.fetchWeatherAlerts(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                } else {
                    locationName = "Error"
                    print("Reverse geocode failed: \(error?.localizedDescription ?? "Unknown error")")
                }
                isLoading = false
            }
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
            return .gray // Fallback color
        }
    }
}

#Preview {
    AlertSeverityView()
}

import SwiftUI
import CoreLocation

struct AlertSeverity: View {
    @StateObject private var weatherService = WeatherService()
    @State private var locationName: String = "Unknown"
    @State private var isLoading: Bool = true
    @StateObject private var locationManager = LocationManager()

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Fetching weather alerts...")
            } else {
                if weatherService.alerts.isEmpty {
                    Text("No weather alerts for \(locationName).")
                        .foregroundColor(.gray)
                } else {
                    ForEach(weatherService.alerts) { alert in
                        VStack(alignment: .leading) {
                            Text("Weather Event: \(alert.headline)")
                                .font(.headline)
                                .foregroundColor(.blue)
                            
                            // Using SeverityTextView to show just the severity
                            SeverityTextView(severity: alert.severity)
                        }
                        .padding()
                    }
                }
            }
        }
        .onAppear {
            // Fetch location and weather alerts when the view appears
            if let location = locationManager.location {
                reverseGeocode(location: location)
            }
        }
        .onReceive(locationManager.$location) { location in
            if let location = location {
                reverseGeocode(location: location)
            }
        }
        .alert(isPresented: $locationManager.showAlert) {
            Alert(
                title: Text("Location Error"),
                message: Text(locationManager.errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private func reverseGeocode(location: CLLocation) {
        isLoading = true
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            DispatchQueue.main.async {
                if let placemark = placemarks?.first {
                    locationName = placemark.locality ?? "Unknown"
                    
                    // Fetch weather alerts for the reverse-geocoded location
                    weatherService.fetchWeatherAlerts(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                } else {
                    locationName = "Error"
                    print("Reverse geocode failed: \(error?.localizedDescription ?? "Unknown error")")
                }
                isLoading = false
            }
        }
    }
}

struct SeverityTextView: View {
    var severity: String

    var body: some View {
        Text("Severity: \(severity)")
            .font(.subheadline)
            .foregroundColor(severityColor(for: severity))
            .bold()
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
            return .gray // Fallback color
        }
    }
}

#Preview {
    AlertSeverityView()
}


