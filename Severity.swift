import Foundation

struct NOAAAlert: Codable {
    let id: String
    let title: String
    let description: String
    let severity: String
    let areaDesc: String
    let instruction: String?
}
import Foundation
import Combine

class WeatherViewModel: ObservableObject {
    @Published var alerts: [NOAAAlert] = []
    private var cancellables = Set<AnyCancellable>()

    func fetchWeatherAlerts(lat: Double, lon: Double) {
        let urlString = "https://api.weather.gov/alerts/active?point=\(lat),\(lon)"
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: AlertsResponse.self, decoder: JSONDecoder())
            .replaceError(with: AlertsResponse(features: []))
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] response in
                self?.alerts = response.features
            })
            .store(in: &cancellables)
    }
}

// Update the AlertsResponse to match the new model structure
struct AlertsResponse: Codable {
    let features: [NOAAAlert]
}
import SwiftUI

struct WeatherAlertView: View {
    @ObservedObject var viewModel = WeatherViewModel()

    var body: some View {
        VStack {
            Text("Weather Alerts")
                .font(.largeTitle)
                .padding()

            List(viewModel.alerts, id: \.id) { alert in
                VStack(alignment: .leading) {
                    Text(alert.title)
                        .font(.headline)
                    Text(alert.description)
                        .font(.subheadline)
                    Text("Severity: \(alert.severity)")
                        .font(.caption)
                        .foregroundColor(.red)
                    Text("Area: \(alert.areaDesc)")
                        .font(.caption)
                    if let instruction = alert.instruction {
                        Text("Instructions: \(instruction)")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                .padding()
            }
        }
        .onAppear {
            viewModel.fetchWeatherAlerts(lat: 40.7128, lon: -74.0060) // Replace with desired coordinates
        }
    }
}

struct WeatherAlertView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherAlertView()
    }
}
