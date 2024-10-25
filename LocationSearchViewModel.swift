// LocationSearchViewModel.swift
import Foundation
import MapKit

class LocationSearchViewModel: NSObject, ObservableObject {
    @Published var results = [MKLocalSearchCompletion]()
    @Published var selectedLocation: MKMapItem?
    private let searchCompleter = MKLocalSearchCompleter()
    @Published var queryFragment: String = "" {
        didSet {
            searchCompleter.queryFragment = queryFragment
        }
    }
    
    override init() {
        super.init()
        searchCompleter.delegate = self
        searchCompleter.queryFragment = queryFragment
        searchCompleter.resultTypes = .pointOfInterest
    }
    
    func getLocation(for result: MKLocalSearchCompletion, completion: @escaping (MKMapItem?) -> Void) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = result.title.appending(result.subtitle)
        
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            guard let location = response?.mapItems.first else {
                completion(nil)
                return
            }
            completion(location)
        }
    }
    
    func openInMaps(result: MKLocalSearchCompletion) {
        getLocation(for: result) { mapItem in
            guard let mapItem = mapItem else { return }
            
            let launchOptions = [
                MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
            ]
            mapItem.openInMaps(launchOptions: launchOptions)
        }
    }
}

extension LocationSearchViewModel: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        DispatchQueue.main.async {
            self.results = completer.results
        }
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Error: \(error.localizedDescription)")
    }
}

// ShelterListView.swift
import SwiftUI
import MapKit

struct ShelterListView: View {
    @StateObject private var viewModel = LocationSearchViewModel()
    
    var body: some View {
        NavigationView {
            List(viewModel.results, id: \.self) { result in
                VStack(alignment: .leading, spacing: 8) {
                    Text(result.title)
                        .font(.headline)
                    
                    Text(result.subtitle)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Button(action: {
                        viewModel.openInMaps(result: result)
                    }) {
                        HStack {
                            Image(systemName: "map.fill")
                            Text("Get Directions")
                        }
                        .foregroundColor(.blue)
                        .padding(.top, 4)
                    }
                }
                .padding(.vertical, 4)
            }
            .listStyle(PlainListStyle())
            .navigationTitle("Nearby Shelters")
            .onAppear {
                viewModel.queryFragment = "Hotels"
            }
        }
    }
}

#Preview {
    ShelterListView()
}
