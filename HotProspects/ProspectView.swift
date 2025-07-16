//
//  ProspectView.swift
//  HotProspects
//
//  Created by Buzurg Rakhimzoda on 13.08.2024.
//

import SwiftUI
import CodeScanner
import UserNotifications

struct ProspectView: View {
    enum FilterType: String{
        case none = "Everyone", contacted, uncontacted
    }
    
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: []) var prospects: FetchedResults<Prospect>
    @StateObject private var dataController = DataController.shared
    @State private var selectedProspects = Set<Prospect>()
    @State private var isScanning: Bool = false
    
    let filterType: FilterType
    
    var body: some View {
        NavigationStack{
            List(prospects, selection: $selectedProspects){ prospect in
                VStack(alignment: .leading){
                    Text(prospect.name ?? "Uknown")
                        .font(.headline)
                    Text(prospect.email ?? "No email")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true){
                    Button("Delete", systemImage: "trash", role:.destructive){
                        moc.delete(prospect)
                        dataController.saveContext()
                    }
                }
                .swipeActions(edge: .leading, allowsFullSwipe: true){
                    if prospect.isContacted{
                        Button("Mark Uncontacted", systemImage: "person.crop.circle.fill.badge.xmark"){
                            prospect.isContacted.toggle()
                            dataController.saveContext()
                        }
                        .tint(Color.gray)
                    } else {
                        Button("Mark Contacted", systemImage: "person.crop.circle.fill.badge.checkmark"){
                            prospect.isContacted.toggle()
                            dataController.saveContext()
                        }
                        .tint(Color.green)
                    }
                    
                    Button("Remind Me", systemImage:"bell"){
                        addNotification(for: prospect)
                    }
                    .tint(Color.orange)
                }
                .tag(prospect)
            }
            .toolbar{
                ToolbarItemGroup(placement: .topBarTrailing) {
                    EditButton()
                    Button(action: {isScanning.toggle()}){
                        Image(systemName: "qrcode")
                    }
                }
                if selectedProspects.count > 0 {
                    ToolbarItem(placement:.topBarLeading) {
                        Button("Delete", systemImage:"trash", role: .destructive){
                            deleteSelectedProspects()
                            dataController.saveContext()
                        }
                        .tint(.red)
                    }
                }
            }
            .navigationTitle("\(filterType.rawValue.capitalized)")
            .sheet(isPresented: $isScanning){
                CodeScannerView(codeTypes: [.qr], simulatedData: "Buzurgmehr Rahimzoda\nldevdantesl@gmail.com", shouldVibrateOnSuccess: true, completion: handleScan)
            }
        }
    }
    
    func addNotification(for prospect: Prospect){
        let center = UNUserNotificationCenter.current()
        
        let addRequest = {
            let content = UNMutableNotificationContent()
            content.title = "Contact: \(prospect.name ?? "Uknown")"
            content.subtitle = prospect.email ?? "Uknown email"
            content.sound = .default
            
            var dateComponent = DateComponents()
            dateComponent.hour = 9
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: false)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        }
        
        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                addRequest()
            } else {
                center.requestAuthorization(options: [.alert,.badge, .sound]) { success, error in
                    if success {
                        addRequest()
                    } else if let error{
                        print("Error: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func deleteSelectedProspects(){
        for prospect in selectedProspects {
            moc.delete(prospect)
            dataController.saveContext()
        }
    }
    
    func handleScan(result: Result<ScanResult, ScanError>){
        isScanning.toggle()
        switch result {
        case .success(let result):
            let details = result.string.components(separatedBy: "\n")
            guard details.count == 2 else { return }
            let newProspect = Prospect(context: moc)
            newProspect.id = UUID()
            newProspect.name = details[0]
            newProspect.email = details[1]
            newProspect.isContacted = false
            
        case .failure(let error):
            print("Error:\(error.localizedDescription)")
        }
    }
    
    init(filterType: FilterType){
        self.filterType = filterType
        
        if filterType != .none{
            let showContactedOnly = filterType == .contacted
            
            _prospects = FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)], predicate: NSPredicate(format: "isContacted == %@", NSNumber(value: showContactedOnly)))
        }
    }
}

#Preview {
    ProspectView(filterType: .none)
}
