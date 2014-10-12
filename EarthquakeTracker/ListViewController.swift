//
//  ListViewController.swift
//  EarthquakeTracker
//
//  Created by Julien Lecomte on 10/11/14.
//  Copyright (c) 2014 Julien Lecomte. All rights reserved.
//

import UIKit

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!

    var earthquakes: [Earthquake] = []
    var dateFormatter: NSDateFormatter!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd 'at' h:mm a"
    }

    override func viewDidAppear(animated: Bool) {
        // Handle case where the settings have changed...
    }

    func refresh() {
        earthquakes = USGSClient.sharedInstance.earthquakes
        tableView.reloadData()
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return earthquakes.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("EarthquakeTableViewCell") as EarthquakeTableViewCell
        var earthquake = earthquakes[indexPath.row]

        cell.timeLabel.text = dateFormatter.stringFromDate(earthquake.time!)
        cell.placeLabel.text = earthquake.place
        cell.magnitudeLabel.text = NSString(format: "%.2f", earthquake.magnitude!)
        cell.depthLabel.text = NSString(format: "%.2f miles", earthquake.depth! * 0.621371)

        return cell
    }
}
