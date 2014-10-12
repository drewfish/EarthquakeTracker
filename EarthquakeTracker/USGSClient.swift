//
//  USGSClient.swift
//  EarthquakeTracker
//
//  Created by Julien Lecomte on 10/11/14.
//  Copyright (c) 2014 Julien Lecomte. All rights reserved.
//

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

    var earthquakes: [Earthquake] = []

    func getEarthquakeList(
        ndays: UInt8,
        minmagnitude: Double,
        center: CLLocationCoordinate2D,
        maxradius: CLLocationDegrees,
        callback: (earthquakes: [Earthquake]!, error: NSError!) -> Void
    ) {
        var parameters = [String: AnyObject]()

        // Output format...
        parameters["format"] = "geojson"

        // Start time...
        var now = NSDate()
        var starttime = now.dateByAddingTimeInterval(NSTimeInterval(-Int(ndays) * 86400))
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        parameters["starttime"] = dateFormatter.stringFromDate(starttime)

        // Region...
        parameters["latitude"]  = center.latitude
        parameters["longitude"] = center.longitude
        parameters["maxradius"] = maxradius

        // Other...
        parameters["minmagnitude"] = minmagnitude

        GET(WEB_SERVICE_ENDPOINT,
            parameters: parameters,
            success: {
                (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in

                var object = response as NSDictionary
                var features = object["features"] as [NSDictionary]
                self.earthquakes = []

                for feature in features {
                    var earthquake = Earthquake(jsonObject: feature)
                    self.earthquakes.append(earthquake)
                }

                callback(earthquakes: self.earthquakes, error: nil)
            },
            failure: {
                (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                callback(earthquakes: nil, error: error)
            })
    }
}
