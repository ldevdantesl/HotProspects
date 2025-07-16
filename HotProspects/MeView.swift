//
//  MeView.swift
//  HotProspects
//
//  Created by Buzurg Rakhimzoda on 13.08.2024.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct MeView: View {
    @AppStorage("Name") var name: String = "Anonymous"
    @AppStorage("Email") var email: String = "test@test.com"
    
    @State var showSheetName: Bool = false
    @State private var showSheetEmail: Bool = false
    @State private var showSheetQRCode: Bool = false
    @State private var qrCode: UIImage = UIImage()
    
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    var body: some View {
        NavigationStack{
            Form{
                Section("Name"){
                    Button(action:{showSheetName.toggle()}){
                        Text(name)
                    }
                }
                .sheet(isPresented: $showSheetName){
                    sheetView(for: "name", toggleButton: $showSheetName)
                        .presentationDetents([.fraction(1/3)])
                }
                Section("Email Address"){
                    Button(action:{showSheetEmail.toggle()}){
                        Text(email)
                    }
                }
                .sheet(isPresented: $showSheetEmail){
                    sheetView(for: "Email Address", toggleButton: $showSheetEmail)
                        .presentationDetents([.fraction(1/3)])
                }
                Section{
                    Button(action:{showSheetQRCode.toggle()}){
                        Text("My QRCode")
                            .foregroundStyle(.white)
                            .font(.system(.title2, design: .rounded, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color.blue, in:.rect(cornerRadius: 15))
                }
                .listRowBackground(Color.clear)
                
            }
            .onChange(of: name, updateQRCode)
            .onChange(of: email, updateQRCode)
            .navigationTitle("Home")
            .sheet(isPresented: $showSheetQRCode){
                NavigationStack{
                    Image(uiImage: qrCode)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .padding(10)
                        .onAppear(perform: updateQRCode)
                        .toolbar{
                            Button("Done"){
                                showSheetQRCode.toggle()
                            }
                        }
                        .contextMenu{
                            ShareLink(item: Image(uiImage:qrCode), preview: SharePreview("Hey this is my QR code.", image: Image(uiImage:qrCode)))
                        }
                }
                .presentationDetents([.medium])
            }
            
        }
    }
    
    func updateQRCode(){
        qrCode = generateQRCode(for: "\(name)\n\(email)")
    }
    
    func generateQRCode(for str: String) -> UIImage{
        filter.message = Data(str.utf8)
        
        if let outputImage = filter.outputImage{
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent){
                return UIImage(cgImage: cgImage)
            }
        }
        
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
    
    @ViewBuilder
    func sheetView(for str: String, toggleButton: Binding<Bool>) -> some View{
        NavigationStack{
            Form{
                Section("\(str.capitalized)"){
                    if str == "name"{
                        TextField("Name", text: $name)
                            .textContentType(.name)
                            .autocorrectionDisabled()
                        
                    } else {
                        TextField("Email Address", text: $email)
                            .textContentType(.emailAddress)
                            .autocorrectionDisabled()
                    }
                }
                
                Button{
                    toggleButton.wrappedValue = false
                } label:{
                    Text("Save")
                }
            }
        }
    }
}

#Preview {
    NavigationStack{
        MeView()
    }
}
