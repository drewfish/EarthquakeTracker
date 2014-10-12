//
//  EarthquakeTrackerSettings.swift
//  EarthquakeTracker
//
//  Created by Julien Lecomte on 10/12/14.
//  Copyright (c) 2014 Julien Lecomte. All rights reserved.
//

import Foundation

enum showEventsInThePast: Int {
    case DAY
    case WEEK
    case MONTH
}

enum sortEventListBy: Int {
    case TIME
    case MAGNITUDE
    case PROXIMITY
}

class EarthquakeTrackerSettings {

    class var sharedInstance: EarthquakeTrackerSettings {

        struct Static {
            static var instance: EarthquakeTrackerSettings?
            static var token: dispatch_once_t = 0
        }

        dispatch_once(&Static.token) {
            Static.instance = EarthquakeTrackerSettings()
        }

        return Static.instance!
    }

    var timeLimit    = showEventsInThePast.WEEK
    var sortListBy   = sortEventListBy.TIME
    var minMagnitude = 3

    var settings = NSUserDefaults.standardUserDefaults()

    init() {
        if settings.objectForKey("timeLimit") != nil {
            var timeLimit = settings.integerForKey("timeLimit")
            if timeLimit >= 0 && timeLimit <= 2 {
                self.timeLimit = showEventsInThePast.fromRaw(timeLimit)!
            }
        }

        if settings.objectForKey("sortListBy") != nil {
            var sortListBy = settings.integerForKey("sortListBy")
            if sortListBy >= 0 && sortListBy <= 2 {
                self.sortListBy = sortEventListBy.fromRaw(sortListBy)!
            }
        }

        if settings.objectForKey("minMagnitude") != nil {
            var minMagnitude = settings.integerForKey("minMagnitude")
            if minMagnitude >= 0 && minMagnitude <= 6 {
                self.minMagnitude = minMagnitude
            }
        }
    }

    func save() {
        settings.setInteger(timeLimit.toRaw(),  forKey: "timeLimit")
        settings.setInteger(sortListBy.toRaw(), forKey: "sortListBy")
        settings.setInteger(minMagnitude,       forKey: "minMagnitude")
        settings.synchronize()
    }
}