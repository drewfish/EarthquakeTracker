//
//  MapViewController.swift
//  EarthquakeTracker
//
//  Created by Julien Lecomte on 10/11/14.
//  Copyright (c) 2014 Julien Lecomte. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var map: MKMapView!

    var locmgr: CLLocationManager!
    var annotations: [MKPointAnnotation] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup location manager...
        locmgr = CLLocationManager()
        locmgr.delegate = self
        locmgr.desiredAccuracy = kCLLocationAccuracyBest
        locmgr.requestAlwaysAuthorization()
        locmgr.startUpdatingLocation()

        // Setup map view...
        map.delegate = self
        map.showsUserLocation = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        // We only need the user's location once, so stop updating location immediately!
        locmgr.stopUpdatingLocation()

        var location = locations[0] as CLLocation
        var region = MKCoordinateRegionMakeWithDistance(location.coordinate, 100000, 100000)
        map.setRegion(region, animated: true)
    }

    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        // This trivial implementation removes all existing annotations,
        // requests the USGS service, and creates new annotations based
        // on the data returned whenever the user moves the map or zooms
        // in or out. Needless to say that it is highly inefficient...

        map.removeAnnotations(map.annotations)

        USGSClient.sharedInstance.getEarthquakeList(map.region.center,
            maxradius: max(map.region.span.latitudeDelta, map.region.span.longitudeDelta)) {
            (earthquakes: [Earthquake]!, error: NSError!) -> Void in

            for earthquake in earthquakes {
                var annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(
                    latitude: earthquake.latitude as CLLocationDegrees!,
                    longitude: earthquake.longitude  as CLLocationDegrees!)
                self.map.addAnnotation(annotation)
            }
        }
    }
}
