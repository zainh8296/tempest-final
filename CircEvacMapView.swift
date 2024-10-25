//
//  CircEvacMapView.swift
//  final
//
//  Created by Zain Hasnain on 10/24/24.
//

import SwiftUI

struct CircEvacMapView: View {
    var body: some View {
        
            GeometryReader { geometry in
                let padding = geometry.size.width * 0.05 // 5% padding from the edge

                EvacuationMapView()
                    .frame(width: geometry.size.width - 2 * padding, height: geometry.size.width - 2 * padding) // Adjust size based on padding
                    .clipShape(Circle())
                    .overlay {
                      /*  Circle()
                            .stroke(.blue, lineWidth: 4)*/
                    }
                    .shadow(radius: 7)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2) // Center the view
            }
            .aspectRatio(1, contentMode: .fit) // Maintain a square aspect ratio
        
    }
}

#Preview {
    CircEvacMapView()
}
