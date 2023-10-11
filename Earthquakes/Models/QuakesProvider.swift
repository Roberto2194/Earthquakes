//
//  QuakesProvider.swift
//  Earthquakes
//
//  Created by Roberto Liccardo on 11/10/23.
//

import Foundation

// Marking the whole class with @MainActor makes methods of this class execute on the main thread.
@MainActor
class QuakesProvider: ObservableObject {

    @Published var quakes: [Quake] = []

    let client: QuakeClient

    func fetchQuakes() async throws {
        let latestQuakes = try await client.quakes
        self.quakes = latestQuakes
    }

    func deleteQuakes(atOffsets offsets: IndexSet) {
        quakes.remove(atOffsets: offsets)
    }

    init(client: QuakeClient = QuakeClient()) {
        self.client = client
    }
}