//
//  NSCache+Subscript.swift
//  Earthquakes
//
//  Created by Roberto Liccardo on 11/10/23.
//

import Foundation

// NSCache is thread safe, which means that it won’t corrupt the data if accessed from multiple threads
extension NSCache where KeyType == NSString, ObjectType == CacheEntryObject {
    // We are using the subscript to retrieve and add data to the cache
    subscript(_ url: URL) -> CacheEntry? {
        // retrieves a CacheEntryObject from the cache
        get {
            let key = url.absoluteString as NSString
            // object(forKey:) is a method of NSCache
            let value = object(forKey: key)
            return value?.entry
        }
        // stores a CacheEntryObject to the cache
        set {
            let key = url.absoluteString as NSString
            if let entry = newValue {
                let value = CacheEntryObject(entry: entry)
                // setObject(_:forKey:) is a method of NSCache
                setObject(value, forKey: key)
            } else {
                // removeObject(forKey:) is a method of NSCache
                removeObject(forKey: key)
            }
        }
    }
}
