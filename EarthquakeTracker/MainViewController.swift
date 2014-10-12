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

    @IBAction func switchDisplayMode(sender: AnyObject) {

        if currentDisplayMode == EarthquakeTrackerDisplayMode.MAP {
            var fromView = mapViewController.view
            var toView = listViewController.view

            // First add the list view controller...
            addChildViewController(listViewController)
            listViewController.view.frame = containerView.frame
            containerView.addSubview(listViewController.view)
            listViewController.didMoveToParentViewController(self)

            // Then start the transition between the two views...
            UIView.transitionFromView(fromView, toView: toView, duration: 0.5, options: UIViewAnimationOptions.TransitionFlipFromLeft) {
                (Bool) -> Void in

                // Finally, remove the map view controller...
                self.mapViewController.didMoveToParentViewController(nil)
                self.mapViewController.removeFromParentViewController()

                // Tell the list view controller to use the current data set.
                // This will copy the data used to render the map, so even if
                // there is a pending request to the USGS service, the two views
                // will be in sync...
                self.listViewController.refresh()

                self.currentDisplayMode = EarthquakeTrackerDisplayMode.LIST
                self.switchDisplayModeBarBtnItem.image = UIImage(named: "map-icon")
            }

        } else {
            // Same deal as above, but in reverse order...
            var fromView = listViewController.view
            var toView = mapViewController.view

            addChildViewController(mapViewController)
            mapViewController.view.frame = containerView.frame
            containerView.addSubview(mapViewController.view)
            mapViewController.didMoveToParentViewController(self)

            UIView.transitionFromView(fromView, toView: toView, duration: 0.5, options: UIViewAnimationOptions.TransitionFlipFromRight) {
                (Bool) -> Void in

                self.listViewController.didMoveToParentViewController(nil)
                self.listViewController.removeFromParentViewController()

                self.currentDisplayMode = EarthquakeTrackerDisplayMode.MAP
                self.switchDisplayModeBarBtnItem.image = UIImage(named: "list-icon")
            }
        }

    }
}
