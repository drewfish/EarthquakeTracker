//
//  SeismoModel.swift
//  EarthquakeTracker
//
//  Created by Andrew Folta on 10/11/14.
//  Copyright (c) 2014 Andrew Folta. All rights reserved.
//

import UIKit
import CoreMotion


let SEISMO_UPDATE_INTERVAL = 1.0 / 20.0


@objc protocol SeismoModelDelegate {
    func reportMagnitude(magnitude: Double)
    func reportNoAccelerometer()
}


@objc class SeismoModel {
    var delegate: SeismoModelDelegate?

    init() {}

    // start listening for seismic activity
    func start() {
        var first = true
        if motionManager == nil {
            motionManager = CMMotionManager()
        }
        if !motionManager!.accelerometerAvailable {
            delegate?.reportNoAccelerometer()
            return
        }
        motionManager!.accelerometerUpdateInterval = SEISMO_UPDATE_INTERVAL
        motionManager!.startAccelerometerUpdatesToQueue(NSOperationQueue(), withHandler: {
            (data: CMAccelerometerData?, error: NSError?) -> Void in
            if error != nil {
                // FUTURE -- handle error
                self.motionManager!.stopAccelerometerUpdates()
            }
            if data != nil {
                var magnitude = sqrt(
                    (data!.acceleration.x * data!.acceleration.x) +
                    (data!.acceleration.y * data!.acceleration.y) +
                    (data!.acceleration.z * data!.acceleration.z)
                )
                if first {
                    self.lastMagnitude = magnitude
                    first = false
                }
                dispatch_async(dispatch_get_main_queue(), {
                    self.delegate?.reportMagnitude(magnitude - self.lastMagnitude)
                    self.lastMagnitude = magnitude
                })
            }
        })
    }

    // stop listening for seismic activity
    func stop() {
        motionManager?.stopAccelerometerUpdates()
    }

    private var motionManager: CMMotionManager?
    private var lastMagnitude = 0.0
}

