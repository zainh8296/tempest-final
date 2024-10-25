

import SwiftUI

struct EvacuationView: View {
    var body: some View {
        VStack {
            EvacuationMapView()
            ShelterListView()
        }
        .navigationTitle("Evacuation Info")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarHidden(true)  // Hide the default navigation bar
    }
}

#Preview {
    EvacuationView()
}
