//
//  ContentView.swift
//  ClickbaitControllerSwiftUI
//
//  Created by Simon on 28/09/2022.
//

import SwiftUI

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LandingPageContent()
    }
}

struct LandingPageContent: View {
    
    private var settings: SettingsStore = SettingsStore()
    var body: some View {
        TabView {
            PreShowView()
                .tabItem { Label("PreShow", systemImage: "book") }
            
            InShowView()
                .tabItem { Label("InShow", systemImage: "person") }
            
            SettingsView(destination_ip: settings.destination_ip, destination_port: settings.destination_port)
                .tabItem { Label("Innstillinger", systemImage: "network") }
        }.environmentObject(self.settings)
    }
}

struct PreShowView: View {
    
    @EnvironmentObject private var settings: SettingsStore
    @State private var showingAlert = false
    
    @State private var selectedImage: UIImage?
    @State private var isImagePickerDisplay = false
    
    var body: some View {
        VStack {
            Text("Før showstart")
                .padding()
                .navigationTitle("PreShow")
                .font(.largeTitle)
                .foregroundColor(.white)
            
            Button("Reset/Klar for show") {
                showingAlert = true
            }.padding()
                .background(Color.orange)
                .foregroundColor(.white)
            .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Sikker? Denne handlingen sletter alle bildene og gjør klart til show"),
                          message: Text("Sikker?"),
                          primaryButton: .destructive(Text("Ja, jeg vil slette alle bildene"), action: {
                            deleteImagesRequest(settings: settings)
                            }),
                          secondaryButton: .default(Text("Nei det var et uhell"))
                          )
                    }
            
            
            Button("Ta Bilde") {
                self.isImagePickerDisplay = true
            }.padding()
                .background(Color.orange)
                .foregroundColor(.white)
            
            
        }
        .sheet(isPresented: self.$isImagePickerDisplay) {
            ImagePickerView(selectedImage: self.$selectedImage, preOrPost: true, sourceType: .camera)}
        .foregroundColor(.black)
    }
}

struct InShowView: View {
    
    @EnvironmentObject private var settings: SettingsStore
    
    @State private var title: String = ""
    @State private var isEditing = false
    @State private var showingAlert = false
    
    @State private var selectedImage: UIImage?
    @State private var isImagePickerDisplay = false
    
    var body: some View {
        VStack {
            Text("Mens showet pågår")
                .padding()
                .navigationTitle("InShow")
                .font(.largeTitle)
                .foregroundColor(.white)
            
            Button("Ta Bilde") {
                //Send bilde til server
                self.isImagePickerDisplay = true
            }.padding()
            .background(Color.orange)
            .foregroundColor(.white)
            
            TextField(
                "Skriv tittel her",
                text: $title) {
                isEditing in self.isEditing = isEditing
            } onCommit: {
                sendTitlePost(title: self.title, settings: self.settings)
            }
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .border(.white)
            .foregroundColor(.white)
            
            Button("Fjern bilde og tittel") {
                showingAlert = true
            }.padding()
            .background(Color.orange)
            .foregroundColor(.white)
            .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Sikker?"),
                          message: Text("Sikker?"),
                          primaryButton: .destructive(Text("JA JEG VIL SLETTE BILDET OG TITTELEN"), action: {
                            self.title = ""
                        deletePictureAndTitle(settings: self.settings)
                            }),
                          secondaryButton: .default(Text("Nei det var et uhell"))
                          )
                    }
            
            
        }
        .sheet(isPresented: self.$isImagePickerDisplay) {
            ImagePickerView(selectedImage: self.$selectedImage, preOrPost: false, sourceType: .camera)}
    }
}

func imageUploadRequest(image: UIImage, preorpost: Bool, settings: SettingsStore) {

    let request = NSMutableURLRequest(url: NSURL(string:  craftIP(settings: settings) + (preorpost ? "/postpicturepre" : "/postpicturein"))! as URL);
    request.httpMethod = "POST"

    guard let imageData = image.jpegData(compressionQuality: 1) else {
        print("oopsie")
        return;
    }

    var body = Data()
    
    body.append(imageData)
    
    request.httpBody = body

    
    sendRequest(request: request)

    
}

func deleteImagesRequest(settings: SettingsStore) {
    print("sending delete image request")
    let request = NSMutableURLRequest(url: URL(string: craftIP(settings: settings) + "/deletepictures")!)
    
    request.httpMethod = "DELETE"

    
    sendRequest(request: request)
}

func deletePictureAndTitle(settings: SettingsStore) {
    print("sending delete image and title request")
    let request = NSMutableURLRequest(url: URL(string: craftIP(settings: settings) + "/deletepictureandtitle")!)
    
    request.httpMethod = "DELETE"
    
    sendRequest(request: request)
}

func sendTitlePost(title: String, settings: SettingsStore) {
    print("sending title: " + title)
    let request = NSMutableURLRequest(url: URL(string: craftIP(settings: settings) + "/posttitle")!)
    
    request.httpMethod = "POST"

    request.setValue("text/plain; charset=UTF-8", forHTTPHeaderField: "Content-Type")
    request.httpBody = title.data(using: .utf8)!
    
    sendRequest(request: request)
}

public func sendRequest(request: NSMutableURLRequest) {
    print("sending request: " + request.debugDescription)
    let task = URLSession.shared.dataTask(with: request as URLRequest,
          completionHandler: {
              (data, response, error) -> Void in
              if let data = data {
                
                if((error) != nil) {print(error)}

                print(" response = \(response)")
                print(data.count)
                  
                let responseString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                  print(" response data = \(responseString!)")
                
            }
        }
        )
    
    task.resume()

}

func craftIP(settings: SettingsStore) -> String {
    return "http://" + settings.destination_ip + ":" + settings.destination_port.description
}


