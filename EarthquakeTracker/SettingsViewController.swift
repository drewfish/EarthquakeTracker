//
//  SettingsViewController.swift
//  EarthquakeTracker
//
//  Created by Julien Lecomte on 10/12/14.
//  Copyright (c) 2014 Julien Lecomte. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet var timeLimitCtrl: UISegmentedControl!
    @IBOutlet var minMagLabel: UILabel!
    @IBOutlet var minMagSlider: UISlider!
    @IBOutlet var listViewSortCtrl: UISegmentedControl!

    var minMagLabelFormat: String!

    var settings = EarthquakeTrackerSettings.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()
        minMagLabelFormat = minMagLabel.text
    }

    override func viewWillAppear(animated: Bool) {
        // Update UI based on user's settings...
        timeLimitCtrl.selectedSegmentIndex = settings.timeLimit.toRaw()
        minMagSlider.setValue(Float(settings.minMagnitude), animated: false)
        updateMinMagLabelValue(settings.minMagnitude)
        listViewSortCtrl.selectedSegmentIndex = settings.sortListBy.toRaw()
    }

    @IBAction func onTimeLimitCtrlValueChanged(sender: AnyObject) {
        settings.timeLimit = showEventsInThePast.fromRaw(timeLimitCtrl.selectedSegmentIndex)!
        settings.save()
    }

    @IBAction func onListViewSortCtrlValueChanged(sender: AnyObject) {
        settings.sortListBy = sortEventListBy.fromRaw(listViewSortCtrl.selectedSegmentIndex)!
        settings.save()
    }

    @IBAction func onMinMagSliderValueChanged(slider: UISlider) {
        var sliderValue = Float(lroundf(slider.value))
        slider.setValue(sliderValue, animated: false)
        updateMinMagLabelValue(Int(sliderValue))
        settings.minMagnitude = Int(minMagSlider.value)
        settings.save()
    }

    func updateMinMagLabelValue(minmag: Int) {
        minMagLabel.text = String(format: minMagLabelFormat, minmag)
    }
}
