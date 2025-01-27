//
//  gemeinde_kompass_360App.swift
//  gemeinde-kompass-360
//
//  Created by Alex Polan on 06/11/2023.
//

import SwiftUI
import SwiftData

@main
struct gemeinde_kompass_360App: App {
   /* init() {
        let selectedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage") ?? "en"
        Bundle.setLanguage(selectedLanguage)
    }*/

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.locale, .init(identifier: "de"))

        }
    }
}
