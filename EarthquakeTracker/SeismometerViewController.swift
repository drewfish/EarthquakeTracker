//
//  SeismometerViewController.swift
//  EarthquakeTracker
//
//  Created by Andrew Folta on 10/13/14.
//  Copyright (c) 2014 Julien Lecomte. All rights reserved.
//

import UIKit

class SeismometerViewController: UIViewController {
    @IBOutlet weak var seismoView: SeismoView!
    var seismoModel: SeismoModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        seismoModel = SeismoModel()
        seismoModel?.delegate = seismoView
    }

    override func viewDidAppear(animated: Bool) {
        seismoModel?.start()
    }

    override func viewWillDisappear(animated: Bool) {
        seismoModel?.stop()
        seismoView.reset()
    }
}
