//
//  QuakesProvider.swift
//  Earthquakes
//
//  Created by Roberto Liccardo on 11/10/23.
//

import Foundation

// Marking the whole class with @MainActor makes methods of this class execute on the main thread.
@MainActor
// The QuakesProvider is the class which the views will interface with.
class QuakesProvider: ObservableObject {

    @Published var quakes: [Quake] = []

    private let client: QuakeClient

    // By calling fetchQuakes() the QuakeClient is invoked, and all the process of downloading and mapping the Earthquakes is started
    func fetchQuakes() async throws {
        let latestQuakes = try await client.quakes
        self.quakes = latestQuakes
    }

    func deleteQuakes(atOffsets offsets: IndexSet) {
        quakes.remove(atOffsets: offsets)
    }

    // Similarly, we call location() in the quakes detail
    func location(for quake: Quake) async throws -> QuakeLocation {
        return try await client.quakeLocation(from: quake.detail)
    }

    init(client: QuakeClient = QuakeClient()) {
        self.client = client
    }
}
