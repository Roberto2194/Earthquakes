//
//  QuakeLocation.swift
//  Earthquakes
//
//  Created by Roberto Liccardo on 11/10/23.
//

import Foundation

struct QuakeLocation: Decodable {
    var latitude: Double { properties.products.origin.first!.properties.latitude }
    var longitude: Double { properties.products.origin.first!.properties.longitude }
    private var properties: RootProperties
    
    struct RootProperties: Decodable {
        var products: Products
    }
    
    struct Products: Decodable {
        var origin: [Origin]
    }
    
    struct Origin: Decodable {
        var properties: OriginProperties
    }
    
    struct OriginProperties {
        var latitude: Double
        var longitude: Double
    }
    
    init(latitude: Double, longitude: Double) {
        self.properties = RootProperties(
            products: Products(origin: [Origin(properties: OriginProperties(latitude: latitude, longitude: longitude))])
        )
    }
}

extension QuakeLocation.OriginProperties: Decodable {
    private enum OriginPropertiesCodingKeys: String, CodingKey {
        case latitude
        case longitude
    }
    
    init(from decoder: Decoder) throws {
        // Just like we did in Quake, we first make a decoder.container with the keys
        let container = try decoder.container(keyedBy: OriginPropertiesCodingKeys.self)
        // And then we decode each property with each key corresponding to a case in the enum
        let longitude = try container.decode(String.self, forKey: .longitude)
        let latitude = try container.decode(String.self, forKey: .latitude)
        guard let longitude = Double(longitude), let latitude = Double(latitude) else { throw QuakeError.missingData }
        self.longitude = longitude
        self.latitude = latitude
    }
}
