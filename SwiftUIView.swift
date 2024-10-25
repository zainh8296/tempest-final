import SwiftUI

struct SwiftUIView: View {
    @StateObject private var weatherManager = WeatherAPIManager()
    @StateObject private var locationmanager = locationManager()
    @StateObject private var weatherViewModel = WeatherViewModel()
    
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
    
    @State private var newItemName = ""
    @State private var showingAddItemSheet = false
    
    var body: some View {
        NavigationView {
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
                        }
                        .padding()
                        
                        // Weather Information GroupBox
                        GroupBox(label: Text("Weather Information")) {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text("Severity in Location:")
                                    AlertSeverityView()
                                }
                                Text("Current conditions:")
                                HStack(alignment: .center) {
                                    if let weatherData = weatherManager.weatherData {
                                        Spacer()
                                        Image(systemName: "thermometer.variable")
                                        Text(String(format: "%.0f", weatherData.current.temp_f))
                                        Spacer()
                                        Image(systemName: "cloud")
                                        Text(weatherData.current.condition.text.capitalized)
                                        Spacer()
                                        Image(systemName: "wind")
                                        Text("\(String(format: "%.0f", weatherData.current.wind_mph)) mph \(weatherData.current.wind_dir)")
                                        Spacer()
                                    } else if let errorMessage = weatherManager.errorMessage {
                                        Text("Error: \(errorMessage)")
                                    } else {
                                        Text("Loading...")
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .onAppear {
                                locationmanager.requestLocation()
                            }
                            .onChange(of: locationmanager.latitude) { _ in
                                if let latitude = locationmanager.latitude,
                                   let longitude = locationmanager.longitude {
                                    weatherManager.fetchWeather(latitude: latitude, longitude: longitude)
                                    weatherViewModel.fetchWeatherAlerts(lat: latitude, lon: longitude)  // Fetch alerts based on location
                                }
                            }
                        }
                        
                        // Evacuation Information GroupBox
                        GroupBox(label: Text("Evacuation Information")) {
                            VStack(alignment: .leading, spacing: 10) {
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
                                
                                if !weatherViewModel.alerts.isEmpty {
                                    if let alert = weatherViewModel.alerts.first {  // Assuming we're using the first alert for simplicity
                                        Text(evacuationMessage(for: alert.severity)) // Dynamic evacuation message
                                        
                                        
                                    }
                                } else {
                                    if let alert = weatherViewModel.alerts.first {  // Assuming we're using the first alert for simplicity
                                        Text(evacuationMessage(for: alert.severity)) // Dynamic evacuation message
                                        
                                        
                                    }
                                }
                                
                                // Debugging: Show what the current alert array looks like
                                
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Emergency Checklist GroupBox
                    GroupBox(label:
                                HStack {
                        Text("Emergency Checklist")
                        Spacer()
                        Button(action: {
                            showingAddItemSheet = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    ) {
                        VStack {
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
                                    Button(action: {
                                        if let index = checklist.firstIndex(where: { $0.id == item.id }) {
                                            checklist.remove(at: index)
                                        }
                                    }) {
                                        Image(systemName: "minus.circle.fill")
                                            .foregroundColor(.red)
                                    }
                                }
                                .padding(.vertical, 5)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    
                    
                    // Countdown Timer GroupBox
                    GroupBox(label: Text("Alert Information:")) {
                        WeatherDescriptionView()                        }
                    .padding(.horizontal)
                    Spacer()
                }
            }
        }

        .sheet(isPresented: $showingAddItemSheet) {
            AddItemView(checklist: $checklist, isPresented: $showingAddItemSheet)
            
        }
    }
    struct AddItemView: View {
        @Binding var checklist: [SwiftUIView.ChecklistItem]
        @Binding var isPresented: Bool
        @State private var newItemName = ""
        
        var body: some View {
            NavigationView {
                Form {
                    TextField("New Item", text: $newItemName)
                    Button("Add Item") {
                        if !newItemName.isEmpty {
                            checklist.append(ChecklistItem(name: newItemName, isChecked: false))
                            isPresented = false
                        }
                    }
                    .disabled(newItemName.isEmpty)
                }
                .navigationTitle("Add New Item")
                .navigationBarItems(
                    trailing: Button("Cancel") {
                        isPresented = false
                    }
                )
            }
        }
    }
    
    
    
    // Function to determine evacuation message based on severity
    private func evacuationMessage(for severity: String) -> String {
        switch severity.uppercased() {
        case "Extreme":
            return "It is *critically* recommended to take immediate action and evacuate!"
        case "Severe":
            return "It is *strongly* recommended to take action and evacuate."
        case "Moderate":
            return "It is advised to stay cautious and be ready to evacuate if needed."
        case "Minor":
            return "Monitor the situation closely, but evacuation is not required at this time."
        default:
            return "No evacuation necessary. Stay informed."
        }
    }
}
    
    #Preview {
        SwiftUIView()
    }

