import SwiftUI

struct WeatherView: View {
    @StateObject private var weatherManager = WeatherAPIManager()
    
    var body: some View {
        VStack {
            if let weatherData = weatherManager.weatherData {
                Text("Temperature:\(weatherData.current.temp_f.rounded())°F")
                Text("Condition: \(weatherData.current.condition.text.capitalized)")
            } else if let errorMessage = weatherManager.errorMessage {
                Text("Error: \(errorMessage)")
            } else {
                Text("Loading...")
                    .onAppear {

                        weatherManager.fetchWeather(latitude: 40.7920, longitude: -73.5398)
                    }
            }
        }
        .padding()
    }
}

#Preview {
    WeatherView()
}
