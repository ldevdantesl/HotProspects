//
//  DataController.swift
//  HotProspects
//
//  Created by Buzurg Rakhimzoda on 13.08.2024.
//

import Foundation
import CoreData

class DataController: ObservableObject{
    static let shared = DataController()
    
    let container = NSPersistentContainer(name: "ProspectModel")
    
    init(){
        container.loadPersistentStores { description, error in
            if let error{
                print("Error:\(error.localizedDescription)")
            }
        }
    }
    
    func saveContext(){
        if container.viewContext.hasChanges{
            do {
                try container.viewContext.save()
            } catch {
                print("Error saving to Core Data: \(error.localizedDescription)")
            }
        }
    }
}
