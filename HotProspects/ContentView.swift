//
//  ContentView.swift
//  HotProspects
//
//  Created by Buzurg Rakhimzoda on 13.08.2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView{
            ProspectView(filterType: .none)
                .tabItem { Label("Everyone", systemImage: "person.3") }
            ProspectView(filterType: .contacted)
                .tabItem { Label("Contacted", systemImage: "checkmark.circle") }
            ProspectView(filterType: .uncontacted)
                .tabItem { Label("Uncontacted", systemImage: "questionmark.circle") }
            MeView()
                .tabItem { Label("Home", systemImage: "house") }
        }
    }
}

#Preview {
    ContentView()
}
