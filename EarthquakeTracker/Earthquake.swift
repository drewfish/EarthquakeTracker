//
//  Earthquake.swift
//  EarthquakeTracker
//
//  Created by Julien Lecomte on 10/11/14.
//  Copyright (c) 2014 Julien Lecomte. All rights reserved.
//

import Foundation

class Earthquake {

    var time: NSDate?
    var place: String?
    var magnitude: Double?
    var longitude: Double?
    var latitude: Double?
    var depth: Double?

    init(jsonObject: NSDictionary) {
        var properties = jsonObject["properties"] as NSDictionary

        var timems = properties["time"] as? NSNumber
        time = NSDate(timeIntervalSince1970: NSTimeInterval(timems!/1000))

        place = properties["place"] as? String

        magnitude = properties["mag"] as? Double

        var geometry = jsonObject["geometry"] as NSDictionary
        var coordinates = geometry["coordinates"] as [Double]
        longitude = coordinates[0]
        latitude = coordinates[1]
        depth = coordinates[2]
    }
}
