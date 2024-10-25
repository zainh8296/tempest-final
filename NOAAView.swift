import SwiftUI

struct NOAAView: View {
    @StateObject private var weatherManager = WeatherManager() // Updated to use WeatherManager

    struct ChecklistItem: Identifiable {
        let name: String
        let id = UUID()
        var isChecked: Bool
    }

    @State private var checklist = [
        ChecklistItem(name: "Food (3-day supply)", isChecked: false),
        ChecklistItem(name: "Water (1 gallon/person/day)", isChecked: false),
        ChecklistItem(name: "Flashlight", isChecked: false),
    ]

    var body: some View {
        NavigationView {  // Add this wrapper
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue, Color.indigo]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)

                ScrollView {
                    VStack(spacing: 20) {
                        // Weather Header
                        HStack {
                            Image(systemName: "cloud.bolt.rain.fill")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                            Text("Weather Effect for [Location]:")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                        }
                        .padding()

                        // Weather Information GroupBox
                        GroupBox(label: Text("Weather Information")) {
                            VStack(alignment: .leading, spacing: 10) {
                                // Display severity, headline, description, and instruction
                                if let weatherEvent = weatherManager.weatherEvent {
                                    HStack {
                                        Text("Severity: ")
                                        Text(weatherEvent.severity)
                                            .fontWeight(.bold)
                                            .foregroundColor(.red)
                                    }
                                    HStack {
                                        Text("Headline: ")
                                        Text(weatherEvent.headline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.blue)
                                    }
                                    HStack {
                                        Text("Description: ")
                                        Text(weatherEvent.description)
                                    }
                                    HStack {
                                        Text("Instruction: ")
                                        Text(weatherEvent.instruction)
                                            .italic()
                                    }

                                    // Weather details (temperature, condition, wind)
                                    Text("Current conditions:")
                                    HStack(alignment: .center) {
                                        Spacer()
                                        Image(systemName: "thermometer.variable")
                                        Text(String(format: "%.0f", weatherEvent.temperature))
                                        Spacer()
                                        Image(systemName: "cloud")
                                        Text(weatherEvent.condition.capitalized)
                                        Spacer()
                                        Image(systemName: "wind")
                                        Text("\(String(format: "%.0f", weatherEvent.windSpeed)) mph \(weatherEvent.windDirection)")
                                        Spacer()
                                    }
                                } else if let errorMessage = weatherManager.errorMessage {
                                    Text("Error: \(errorMessage)")
                                } else {
                                    Text("Loading...")
                                        .onAppear {
                                            weatherManager.fetchWeather(latitude: 40.7920, longitude: -73.5398) // Example coordinates
                                        }
                                }
                            }
                        }
                        .padding(.horizontal)

                        // Evacuation Information GroupBox
                        GroupBox(label: Text("Evacuation Information")) {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("It is ") +
                                Text("strongly").bold().underline() +
                                Text(" recommended to take action and evacuate:")

                                CircEvacMapView()

                                NavigationLink {
                                    EvacuationView()
                                } label: {
                                    Text("View evacuation options")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.blue)
                                        .cornerRadius(10)
                                }
                                .padding(.top)
                            }
                        }
                        .padding(.horizontal)

                        // Emergency Checklist GroupBox
                        GroupBox(label: Text("Emergency Checklist")) {
                            ForEach($checklist) { $item in
                                HStack {
                                    Image(systemName: item.isChecked ? "checkmark.square.fill" : "square")
                                        .foregroundColor(item.isChecked ? .green : .gray)
                                        .onTapGesture {
                                            item.isChecked.toggle()
                                        }
                                    Text(item.name)
                                        .strikethrough(item.isChecked)
                                    Spacer()
                                }
                                .padding(.vertical, 5)
                            }
                        }
                        .padding(.horizontal)

                        // Countdown Timer GroupBox
                        GroupBox(label: Text("Countdown Timer:")) {
                            Text("Approx: 02:30 PM (12 hours from now)")
                                .bold()
                                .foregroundStyle(.red)
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
    }
}
#Preview {
    NOAAView()
}
