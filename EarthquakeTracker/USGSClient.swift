//
//  USGSClient.swift
//  EarthquakeTracker
//
//  Created by Julien Lecomte on 10/11/14.
//  Copyright (c) 2014 Julien Lecomte. All rights reserved.
//

// TODO: Implement caching. That would be especially useful when
// switching from the map view to the list view and vice versa...

import Foundation
import CoreLocation

let WEB_SERVICE_BASE_URL = "http://comcat.cr.usgs.gov/fdsnws/event/1/"
let WEB_SERVICE_ENDPOINT = "query"

class USGSClient: AFHTTPRequestOperationManager {

    class var sharedInstance: USGSClient {

        struct Static {
            static var instance: USGSClient?
            static var token: dispatch_once_t = 0
        }

        dispatch_once(&Static.token) {
            Static.instance = USGSClient(baseURL: NSURL(string: WEB_SERVICE_BASE_URL))
        }

        return Static.instance!
    }

    var center: CLLocationCoordinate2D!
    var maxradius: CLLocationDegrees!

    let settings = EarthquakeTrackerSettings.sharedInstance

    func setRegion(center: CLLocationCoordinate2D, maxradius: CLLocationDegrees) {
        self.center = center
        self.maxradius = maxradius
    }

    func getEarthquakeList(callback: (earthquakes: [Earthquake]!, error: NSError!) -> Void) {
        if center == nil {
            callback(earthquakes: nil, error: NSError(domain: "No region has been set", code: 1, userInfo: nil))
            return
        }

        var parameters = [String: AnyObject]()

        // Output format...
        parameters["format"] = "geojson"

        // Start time...
        let now = NSDate()

        let ndays = {
            () -> Int in
            switch self.settings.timeLimit {
            case .DAY:
                return 1
            case .WEEK:
                return 7
            case .MONTH:
                return 30
            }
        }()

        let starttime = now.dateByAddingTimeInterval(NSTimeInterval(-Int(ndays) * 86400))
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZ"
        parameters["starttime"] = dateFormatter.stringFromDate(starttime)

        // Region...
        parameters["latitude"]  = center.latitude
        parameters["longitude"] = center.longitude
        parameters["maxradius"] = maxradius

        // Other...
        parameters["minmagnitude"] = settings.minMagnitude

        GET(WEB_SERVICE_ENDPOINT,
            parameters: parameters,
            success: {
                (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in

                var object = response as NSDictionary
                var features = object["features"] as [NSDictionary]
                var earthquakes: [Earthquake] = []

                for feature in features {
                    var earthquake = Earthquake(jsonObject: feature)
                    earthquakes.append(earthquake)
                }

                callback(earthquakes: earthquakes, error: nil)
            },
            failure: {
                (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                callback(earthquakes: nil, error: error)
            })
    }
}
