import Foundation
import CoreLocation

// Define the WeatherData structure according to the WeatherAPI response
struct WeatherData: Codable {
    let current: CurrentWeather
}

struct CurrentWeather: Codable {
    let temp_f: Double // Temperature in Fahrenheit
    let condition: WeatherCondition
    let wind_mph: Double // Wind speed in mph
    let wind_dir: String
}

struct WeatherCondition: Codable {
    let text: String
}



class WeatherAPIManager: ObservableObject {
    @Published var weatherData: WeatherData?
    @Published var alerts: [WeatherAlert] = []
    @Published var errorMessage: String?
    
    private let apiKey = "API-KEY" 
    
    func fetchWeather(latitude: Double, longitude: Double) {
        let urlString = "https://api.weatherapi.com/v1/current.json?key=\(apiKey)&q=\(latitude),\(longitude)"
        
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = "Error: \(error.localizedDescription)"
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self?.errorMessage = "No data received"
                }
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let weatherResponse = try decoder.decode(WeatherData.self, from: data)
                DispatchQueue.main.async {
                    self?.weatherData = weatherResponse
                }
            } catch {
                DispatchQueue.main.async {
                    self?.errorMessage = "Error decoding data: \(error.localizedDescription)"
                }
            }
        }
        task.resume()
    }
    struct WeatherAlert: Identifiable {
        var id = UUID()
        var headline: String
        var severity: String
    }
}
