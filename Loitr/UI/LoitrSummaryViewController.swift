//
//  LoitrSummaryViewController.swift
//  Loitr
//
//  Created by Timothy Dillman on 5/4/19.
//  Copyright © 2019 Timothy Dillman. All rights reserved.
//

import UIKit
import SwiftDate
final class LoitrSummaryViewController : UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    private var todayLabel: UILabel!
    
    private var todaySummaryLabel: UILabel!
    
    private var bouncyView: BouncyView!
    
    private var locationProvider: LocationManagerInterface!
    
    private var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        registerAppChanges()
        FenceEventManager.instance.onSaveEvent = saveEvent
        locationProvider = LocationProvider.instance
        locationProvider.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
        locationProvider.requestPermission()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        LocationProvider.instance.requestPermission()
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateUI), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
        timer = nil
    }
    
    private func saveEvent() {
        updateUI()
    }
    
    @objc private func updateUI() {
        DispatchQueue.main.async {
            let verbiage = self.generateVerbiage(for: FenceEventManager.instance.arrival(for: Date()), departure: FenceEventManager.instance.departure(for: Date()))
            self.todaySummaryLabel.attributedText = NSAttributedString(string: verbiage, attributes: [.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 30, weight: .semibold)])
        }
        
    }
    
    private func registerAppChanges() {
        // listen for background / foreground events to update UI
        // TODO: Add Background and foreground method listeners
    }
    
    private func generateVerbiage(for arrival: Date?, departure: Date?) -> String {
        let region = Region(calendar: Calendar.current, zone: TimeZone.current, locale: Locales.english)
        let arrivalVerbiage = arrival == nil ? "You have not arrived yet":"You arrived at \(arrival!.convertTo(region: region).toFormat(Date.hourFormat))"
        let departureVerbiage = departure == nil ? "you have not departed yet.":"you departed at \(departure!.convertTo(region: region).toFormat(Date.hourFormat))."
        let summary = FenceEventManager.instance.summary(for: arrival ?? Date(), end: departure ?? Date())
        let totalTimeVerbiage = summary == nil ? "I don't think you have loitered enough today.":"So far, you have spent \(summary?.hours.pluralize(with: "hour") ?? 0.pluralize(with: "hour")) \(summary?.minutes.pluralize(with: "minute") ?? 0.pluralize(with: "minute")) and \(summary?.seconds.pluralize(with: "second") ?? 0.pluralize(with: "second")) loitering!"
        return "\(arrivalVerbiage) and \(departureVerbiage)  \(totalTimeVerbiage)"
    }
    
    private func setupUI() {
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = UIColor.summaryGradientStopColors
        view.layer.addSublayer(gradient)
        
        todayLabel = UILabel()
        view.addSubview(todayLabel)
        todayLabel.translatesAutoresizingMaskIntoConstraints = false
        todayLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 38).isActive = true
        todayLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 28).isActive = true
        todayLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -28).isActive = true
        todayLabel.attributedText = NSAttributedString(string: "Today", attributes: [.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 50, weight: .bold)])
        todaySummaryLabel = UILabel()
        view.addSubview(todaySummaryLabel)
        todaySummaryLabel.translatesAutoresizingMaskIntoConstraints = false
        todaySummaryLabel.attributedText = NSAttributedString(string: "")
        todaySummaryLabel.numberOfLines = 0
        todaySummaryLabel.topAnchor.constraint(equalTo: todayLabel.bottomAnchor, constant: 8).isActive = true
        todaySummaryLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 28).isActive = true
        todaySummaryLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -28).isActive = true
        
        bouncyView = BouncyView()
        bouncyView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bouncyView)
        bouncyView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -28).isActive = true
        bouncyView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 28).isActive = true
        bouncyView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -28).isActive = true
    }
}

extension LoitrSummaryViewController : LocationManagerDelegate {
    func locationPermissionDenied() {
        
    }
    
    func didAddGeofenceLocation() {
        updateUI()
    }
    
    func locationPermissionAllowed() {
        updateUI()
    }
}
