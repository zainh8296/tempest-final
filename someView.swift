//
//  someView.swift
//  final
//
//  Created by Zain Hasnain on 10/18/24.
//

import SwiftUI

struct someView: View {
    var body: some View {
        ZStack{
            ContentView()}
        .ignoresSafeArea()
        
        HStack{
            CustomTabView()

    }

    }
}

#Preview {
    someView()
}
