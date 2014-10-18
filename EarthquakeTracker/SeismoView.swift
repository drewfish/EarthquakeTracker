//
//  SeismoView.swift
//  EarthquakeTracker
//
//  Created by Andrew Folta on 10/11/14.
//  Copyright (c) 2014 Andrew Folta. All rights reserved.
//

import UIKit


let SEISMO_VALUES_WINDOW = 100      // 10 readings/second * 10 seconds
let SEISMO_GRID_SPACING = 0.2
let SEISMO_NEEDLE_OFFSET = CGFloat(-12.5)
let SEISMO_COLOR_GRID = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
let SEISMO_COLOR_AXIS = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
let SEISMO_COLOR_DATA = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)


class SeismoView: UIView, SeismoModelDelegate {
    @IBOutlet weak var needleView: UIImageView!
    var values: [Double] = []
    var scale = SEISMO_GRID_SPACING

    override init(frame: CGRect) {
        super.init(frame: frame)
        moreInit()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        moreInit()
    }

    func moreInit() {
        contentMode = .Redraw
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onOrientationChange", name:UIDeviceOrientationDidChangeNotification, object: nil)
        values = Array<Double>(count: SEISMO_VALUES_WINDOW, repeatedValue: 0.0)
        NSBundle.mainBundle().loadNibNamed("SeismoView", owner: self, options: nil)
        self.addSubview(self.needleView)
    }

    func reset() {
        values = Array<Double>(count: SEISMO_VALUES_WINDOW, repeatedValue: 0.0)
        scale = SEISMO_GRID_SPACING
    }

    func reportMagnitude(magnitude: Double) {
        values.insert(magnitude, atIndex: 0)
        var lastValue = values.removeLast()

        // rescale
        var newScale = ceil(fabs(magnitude) / SEISMO_GRID_SPACING) * SEISMO_GRID_SPACING
        scale = max(scale, newScale)
        var f = fabs(lastValue)
        if f > 0.00001 && f <= scale && scale != newScale {
            var m = values.reduce(0.0) { max($0, fabs($1)) }
            scale = ceil(m / SEISMO_GRID_SPACING) * SEISMO_GRID_SPACING
        }

        // The CoreMotion updates happen in a different thread?
        dispatch_async(dispatch_get_main_queue(), {
            () -> Void in
            self.setNeedsDisplay()
        })
    }

    func reportNoAccelerometer() {
        // TODO -- tell the user
        println("No accelerometer available")
    }

    func onOrientationChange() {
        // I'm surprised that this doesn't happen automatically.
        setNeedsDisplay()
    }

    override func drawRect(rect: CGRect) {
        var context = UIGraphicsGetCurrentContext()
        CGContextSetLineWidth(context, 1.0)

        var x0: CGFloat, x1: CGFloat
        var y0: CGFloat, y1: CGFloat

        var canvas = bounds
        canvas.origin.x += 20.0
        canvas.origin.y += 8.0
        canvas.size.width -= 20.0
        canvas.size.height -= 16.0

        var yRange = 2 * scale
        var yPixelsPerG = canvas.height / CGFloat(yRange)

        // draw grid
        CGContextBeginPath(context)
        CGContextSetStrokeColorWithColor(context, SEISMO_COLOR_GRID.CGColor)
        var numGrid = Int(yRange / SEISMO_GRID_SPACING)
        x0 = canvas.origin.x
        x1 = x0 + canvas.size.width
        y0 = canvas.origin.y
        for g in 0...numGrid {
            CGContextMoveToPoint(context, x0, y0)
            CGContextAddLineToPoint(context, x1, y0)
            y0 += CGFloat(SEISMO_GRID_SPACING) * yPixelsPerG
        }
        CGContextStrokePath(context)

        // draw axes
        CGContextBeginPath(context)
        CGContextSetStrokeColorWithColor(context, SEISMO_COLOR_AXIS.CGColor)
        y0 = canvas.origin.y + (canvas.size.height / 2.0)
        CGContextMoveToPoint(context, x0, y0)
        CGContextAddLineToPoint(context, x1, y0)
        y0 = canvas.origin.y
        y1 = y0 + canvas.size.height
        CGContextMoveToPoint(context, x0, y0)
        CGContextAddLineToPoint(context, x0, y1)
        CGContextStrokePath(context)
        // TODO -- draw text label for each grid line

        var zeroY = canvas.origin.y + (canvas.size.height / 2.0)

        // draw data
        var needleY: CGFloat?
        var xPixelsPerValue = canvas.size.width / CGFloat(values.count)
        CGContextBeginPath(context)
        CGContextSetStrokeColorWithColor(context, SEISMO_COLOR_DATA.CGColor)
        x0 = canvas.origin.x
        y0 = zeroY
        CGContextMoveToPoint(context, x0, y0)
        x1 = x0
        for v in 0..<values.count {
            var value = values[v]
            x1 += xPixelsPerValue
            y1 = canvas.origin.y + CGFloat(scale - value) * yPixelsPerG
            CGContextAddLineToPoint(context, x1, y1)
            if needleY == nil {
                needleY = y1
            }
        }
        CGContextStrokePath(context)

        // update needle
        needleView.frame.origin.y = (needleY ?? zeroY) + SEISMO_NEEDLE_OFFSET
    }
}

