//
//  HotProspectsApp.swift
//  HotProspects
//
//  Created by Buzurg Rakhimzoda on 13.08.2024.
//

import SwiftUI

@main
struct HotProspectsApp: App {
    @StateObject var dataController = DataController.shared
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
        }
    }
}
