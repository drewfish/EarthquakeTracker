//
//  SeismoModel.swift
//  EarthquakeTracker
//
//  Created by Andrew Folta on 10/11/14.
//  Copyright (c) 2014 Andrew Folta. All rights reserved.
//

import UIKit
import CoreMotion


let SEISMO_UPDATE_INTERVAL = 1.0 / 10.0
let SEISMO_BUFFER_SIZE = 10


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
                    self.magnitudes.setup(magnitude)
                    first = false
                    return
                }
                self.magnitudes.update(magnitude)
                self.delegate?.reportMagnitude(self.magnitudes.read())
            }
        })
    }

    // stop listening for seismic activity
    func stop() {
        motionManager?.stopAccelerometerUpdates()
    }

    // We auto-zero the values based on a rolling 1-second window.
    @objc class RingBuffer {
        var ring: [Double] = []
        var index = 0
        var referenceValue = 0.0
        init() {}
        func setup(value: Double) {
            referenceValue = value
            ring = Array<Double>(count: SEISMO_BUFFER_SIZE, repeatedValue: value)
        }
        func update(newValue: Double) {
            // There are different ways to calculate the reference value: average, mean, middle, previous, etc.
            referenceValue = ring[index]
            index = (index + 1) % SEISMO_BUFFER_SIZE
            ring[index] = newValue
        }
        func read() -> Double {
            return ring[index] - referenceValue
        }
    }

    private var motionManager: CMMotionManager?
    private var magnitudes = RingBuffer()
}

