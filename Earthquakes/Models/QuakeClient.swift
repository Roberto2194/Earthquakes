//
//  QuakeClient.swift
//  Earthquakes
//
//  Created by Roberto Liccardo on 11/10/23.
//

import Foundation

actor QuakeClient {
    // We use the cache to store/retrieve quake location
    private let quakeCache: NSCache<NSString, CacheEntryObject> = NSCache()

    private lazy var decoder: JSONDecoder = {
        let aDecoder = JSONDecoder()
        aDecoder.dateDecodingStrategy = .millisecondsSince1970
        return aDecoder
    }()

    private let feedURL = URL(string: "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.geojson")!

    // The point of creating the data downloader as an existential type (aka 'any'), is to have the flexibility of using different data downloaders. In the case of this app, it is done because we have a test HTTPDataDownloader
    private let downloader: any HTTPDataDownloader

    // In this computed property we firstly fetch and map each earthquake to the Quake structure (using GeoJSON), then fetch the location using quakeLocation and map it to the QuakeLocation structure
    var quakes: [Quake] {
        get async throws {
            // When the property is accessed, we download the data
            let data = try await downloader.httpData(from: feedURL)
            // Then we decode it (notice that GeoJSON at the end of the init maps the earthquakes to the Quake structure)
            let allQuakes = try decoder.decode(GeoJSON.self, from: data)
            // We then take the decoded earthquakes in GeoJSON
            var updatedQuakes = allQuakes.quakes
            if let olderThanOneHour = updatedQuakes.firstIndex(where: { $0.time.timeIntervalSinceNow > 3600 }) {
                // Create a range of indices that indicates all the earthquake measurements in the past hour.
                let indexRange = updatedQuakes.startIndex..<olderThanOneHour
                try await withThrowingTaskGroup(of: (Int, QuakeLocation).self) { group in
                    // Iterate through the indices, and add a task to fetch the location for each quake at their specific url
                    for index in indexRange {
                        group.addTask {
                            // Inside each Quake there is an url 'detail' containing the location of the earthquake
                            let location = try await self.quakeLocation(from: allQuakes.quakes[index].detail)
                            return (index, location)
                        }
                    }
                    // Wait on each task in the group.
                    while let result = await group.nextResult() {
                        switch result {
                        case .failure(let error):
                            throw error
                        case .success(let (index, location)):
                            updatedQuakes[index].location = location
                        }
                    }
                }
            }
            return updatedQuakes
        }
    }

    init(downloader: any HTTPDataDownloader = URLSession.shared) {
        self.downloader = downloader
    }
    
    // This is called by var quakes: [Quake] in the withThrowingTaskGroup() function at each iteration.
    func quakeLocation(from url: URL) async throws -> QuakeLocation {
        if let cached = quakeCache[url] {
            switch cached {
            case .ready(let location):
                return location
            case .inProgress(let task):
                return try await task.value
            }
        }
        // Create a task to fetch the location.
        let task = Task<QuakeLocation, Error> {
            let data = try await downloader.httpData(from: url)
            let location = try decoder.decode(QuakeLocation.self, from: data)
            return location
        }
        // We save the task in the cache so that future fetches wait on the in-progress task, rather than issuing a new network request.
        quakeCache[url] = .inProgress(task)
        do {
            let location = try await task.value
            quakeCache[url] = .ready(location)
            return location
        } catch {
            quakeCache[url] = nil
            throw error
        }
    }
}
