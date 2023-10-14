//
//  GeoJSON.swift
//  Earthquakes
//
//  Created by Roberto Liccardo on 11/10/23.
//

import Foundation

struct GeoJSON: Decodable {

    private enum RootCodingKeys: String, CodingKey {
        case features
    }
    
    private enum FeatureCodingKeys: String, CodingKey {
        case properties
    }

    private(set) var quakes: [Quake] = []

    init(from decoder: Decoder) throws {
        // We access the first level of the json "features", this is our Key
        // NOTE: JSONs like dictionaries are key-value pairs, and in order to access the values we need to get the keys
        let rootContainer = try decoder.container(keyedBy: RootCodingKeys.self)
        // The features container lets us extract quakes, one at a time. The decoder accesses the elements chronologically.
        var featuresContainer = try rootContainer.nestedUnkeyedContainer(forKey: .features)

        while !featuresContainer.isAtEnd {
            // We then access the "properties" level of the json
            let propertiesContainer = try featuresContainer.nestedContainer(keyedBy: FeatureCodingKeys.self)

            // Finally we decode the properties mapping them to the Quake structure
            if let properties = try? propertiesContainer.decode(Quake.self, forKey: .properties) {
                quakes.append(properties)
            }
        } 
    }
}
