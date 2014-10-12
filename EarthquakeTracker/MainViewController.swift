//
//  MainViewController.swift
//  EarthquakeTracker
//
//  Created by Julien Lecomte on 10/11/14.
//  Copyright (c) 2014 Julien Lecomte. All rights reserved.
//

import UIKit

enum EarthquakeTrackerDisplayMode {
    case MAP
    case LIST
}

class MainViewController: UIViewController {

    @IBOutlet var containerView: UIView!
    @IBOutlet var switchDisplayModeBarBtnItem: UIBarButtonItem!

    var currentDisplayMode = EarthquakeTrackerDisplayMode.MAP
    var mapViewController: MapViewController!
    var listViewController: ListViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        var storyboard = UIStoryboard(name: "Main", bundle: nil)
        mapViewController = storyboard.instantiateViewControllerWithIdentifier("MapViewController") as MapViewController
        listViewController = storyboard.instantiateViewControllerWithIdentifier("ListViewController") as ListViewController

        // The map view controller is the default.
        // TODO: user setting?
        addChildViewController(mapViewController)
        mapViewController.view.frame = containerView.frame
        containerView.addSubview(mapViewController.view)
        mapViewController.didMoveToParentViewController(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func switchDisplayMode(sender: AnyObject) {
        // TODO: Animate the transition between the two view controllers...

        if currentDisplayMode == EarthquakeTrackerDisplayMode.MAP {
            mapViewController.didMoveToParentViewController(nil)
            mapViewController.removeFromParentViewController()

            addChildViewController(listViewController)
            listViewController.view.frame = containerView.frame
            containerView.addSubview(listViewController.view)
            listViewController.didMoveToParentViewController(self)

            listViewController.refreshList()

            currentDisplayMode = EarthquakeTrackerDisplayMode.LIST
            switchDisplayModeBarBtnItem.image = UIImage(named: "map-icon")
        } else {
            listViewController.didMoveToParentViewController(nil)
            listViewController.removeFromParentViewController()

            addChildViewController(mapViewController)
            mapViewController.view.frame = containerView.frame
            containerView.addSubview(mapViewController.view)
            mapViewController.didMoveToParentViewController(self)

            currentDisplayMode = EarthquakeTrackerDisplayMode.MAP
            switchDisplayModeBarBtnItem.image = UIImage(named: "list-icon")
        }
    }
}
