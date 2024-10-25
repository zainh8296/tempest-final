import SwiftUI

struct CustomTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        VStack {
            // Switch between ContentView, SwiftUIView, and EvacuationView
            if selectedTab == 0 {
                ContentView()  // Show ContentView when Home is selected
            } else if selectedTab == 1 {
                SwiftUIView()  // Show SwiftUIView when Alerts is selected
            } else if selectedTab == 2 {
                EvacuationView()  // Show EvacuationView when Evacuation is selected
            }

            Spacer()

            // Tab bar at the bottom
            HStack {
                TabBarItem(icon: "house.fill", label: "Home", isSelected: selectedTab == 0) {
                    selectedTab = 0
                }
                
                Spacer()

                TabBarItem(icon: "cloud.bolt", label: "Alerts", isSelected: selectedTab == 1) {
                    selectedTab = 1
                }

                Spacer()

                TabBarItem(icon: "car.fill", label: "Evacuation", isSelected: selectedTab == 2) {
                    selectedTab = 2
                }
            }
            .padding()
            .background(Color(.systemGray6).opacity(0.0))
            .padding(.horizontal)
        }
    }
}

struct TabBarItem: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            action()
            performHapticFeedback()
        }) {
            VStack {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .blue : .gray)

                Text(label)
                    .font(.caption)
                    .foregroundColor(isSelected ? .blue : .gray)
            }
        }
    }

    private func performHapticFeedback() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
}

struct CustomTabView_Previews: PreviewProvider {
    static var previews: some View {
        CustomTabView()
    }
}
