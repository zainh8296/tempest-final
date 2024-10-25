import Foundation
import Combine

struct WeatherEvent {
    var severity: String
    var headline: String
    var description: String
    var instruction: String
    var temperature: Double
    var condition: String
    var windSpeed: Double
    var windDirection: String
}

class WeatherManager: ObservableObject {
    @Published var weatherEvent: WeatherEvent?
    @Published var errorMessage: String?
    
    func fetchWeather(latitude: Double, longitude: Double) {
        let urlString = "https://api.weather.gov/alerts/active?point=\(latitude),\(longitude)"
        
        guard let url = URL(string: urlString) else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "No data received"
                }
                return
            }
            
            do {
                let weatherData = try JSONDecoder().decode(WeatherAPIResponse.self, from: data)
                
                // Assuming we fetch alert details from the 'alerts' array
                if let alert = weatherData.alerts.first {
                    DispatchQueue.main.async {
                        self.weatherEvent = WeatherEvent(
                            severity: alert.severity,
                            headline: alert.headline,
                            description: alert.description,
                            instruction: alert.instruction,
                            temperature: weatherData.current.temp_f,
                            condition: weatherData.current.condition.text,
                            windSpeed: weatherData.current.wind_mph,
                            windDirection: weatherData.current.wind_dir
                        )
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = "No active alerts"
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to decode JSON: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}

// Assuming your weather API response model looks like this
struct WeatherAPIResponse: Codable {
    struct Alert: Codable {
        var severity: String
        var headline: String
        var description: String
        var instruction: String
    }
    
    struct Current: Codable {
        var temp_f: Double
        var condition: Condition
        var wind_mph: Double
        var wind_dir: String
    }
    
    struct Condition: Codable {
        var text: String
    }
    
    var current: Current
    var alerts: [Alert] // Array of alerts
}
