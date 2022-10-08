//
//  SettingsView.swift
//  ClickbaitControllerSwiftUI
//
//  Created by Simon on 05/10/2022.
//

import SwiftUI


public struct SettingsView: View {
    @EnvironmentObject var settings: SettingsStore
    
    @State private var destination_ip: String
    @State private var destination_port: String
    
    public init(destination_ip: String, destination_port: String) {
        self.destination_ip = destination_ip
        self.destination_port = destination_port
    }
    
    
    public var body: some View {
        VStack {
            Form{
                Section(header: Text("Destination IP")) {
                    TextField("IP Her", text: $destination_ip)
                    {_ in }
                onCommit: {
                        settings.destination_ip = self.destination_ip
                    }
                }
                
                Section(header: Text("Destination Port")) {
                    TextField("Port her", text: $destination_port)
                    {_ in }
                onCommit: {
                        settings.destination_port = self.destination_port
                    }
                }
            }
        }
    }
}

class SettingsStore: ObservableObject {
    private enum Keys {
        static let destination_ip = "destination_ip"
        static let destination_port = "destination_port"
    }
    
    private let defaults: UserDefaults
    
    
    init(defaults: UserDefaults = .standard) {
            self.defaults = defaults

            defaults.register(defaults: [
                Keys.destination_ip: "0.0.0.0",
                Keys.destination_port: 1103
                ])        
    }
    
    var destination_ip: String {
        set { self.defaults.set(newValue, forKey: Keys.destination_ip) }
        get { self.defaults.string(forKey: Keys.destination_ip)! }
    }
    
    var destination_port: String {
        set { self.defaults.set(newValue, forKey: Keys.destination_port) }
        get { self.defaults.string(forKey: Keys.destination_port)! }
    }
    
}

