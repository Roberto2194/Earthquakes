//
//  EarthquakesApp.swift
//  Earthquakes
//
//  Created by Roberto Liccardo on 10/10/23.
//

import SwiftUI

@main
struct EarthquakesApp: App {
    @StateObject var quakesProvider = QuakesProvider()
    var body: some Scene {
        WindowGroup {
            Quakes()
                .environmentObject(quakesProvider)
        }
    }
}
