//
//  LocationManager.swift
//  Loitr
//
//  Created by Timothy Dillman on 5/2/19.
//  Copyright © 2019 Timothy Dillman. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationManagerDelegate: class {
    func locationPermissionDenied()
    func didAddGeofenceLocation()
    func locationPermissionAllowed()
}

protocol LocationManagerInterface: CLLocationManagerDelegate {
    static var instance: LocationManagerInterface { get set }
    var delegate: LocationManagerDelegate? { get set }
    func requestPermission()
    func didReceivePermissionRequestCallback(status: CLAuthorizationStatus)
    func startGeofencing(for region: CLRegion)
    func removeAllFences()
    func monitoredRegions() -> Set<CLRegion>
}

final class LocationProvider: NSObject {
    
    weak var delegate: LocationManagerDelegate?
    
    private var clManager : CLLocationManager = CLLocationManager()
    
    static var instance: LocationManagerInterface = LocationProvider()
    
    private override init() {
        super.init()
        clManager.delegate = self
        removeAllFences()
    }
    
}

extension LocationProvider: LocationManagerInterface {
    
    func requestPermission() {
        let authStatus = CLLocationManager.authorizationStatus()
        switch (authStatus) {
        case .authorizedAlways:
            delegate?.locationPermissionAllowed()
            startGeofencing(for: CLCircularRegion(center: CLLocationCoordinate2D(latitude: 33.4768, longitude: -81.9686), radius: 40.0, identifier: "Work"))
        case .notDetermined:
            clManager.requestAlwaysAuthorization()
        case .authorizedWhenInUse:
            clManager.requestAlwaysAuthorization()
        case .denied:
            clManager.requestWhenInUseAuthorization()
        default:
            break
        }
        
    }
    
    func didReceivePermissionRequestCallback(status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways:
            print("Is authorized can begin monitoring")
            requestPermission()
        case .authorizedWhenInUse:
            requestPermission()
        case .denied:
            delegate?.locationPermissionDenied()
        case .notDetermined:
            requestPermission()
        
        default:
            print("permission changed")
        }
    }
    
    func startGeofencing(for region: CLRegion) {
        clManager.startMonitoring(for: region)
        delegate?.didAddGeofenceLocation()
    }
    
    func monitoredRegions() -> Set<CLRegion> {
        return clManager.monitoredRegions
    }
    
    func removeAllFences() {
        monitoredRegions().forEach { (region) in
            clManager.stopMonitoring(for: region)
        }
    }
    
    // MARK: CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        didReceivePermissionRequestCallback(status: status)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("Entered: \(region.identifier)")
        FenceEventManager.instance.save(event: FenceEvent(type: .entered, date: Date()))
        NoteManager.instance.scheduleNote(title: "Loitering", message: "\(Date().toFormat(Date.hourFormat)) you entered.")
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("Exited: \(region.identifier)")
        FenceEventManager.instance.save(event: FenceEvent(type: .exit, date: Date()))
        NoteManager.instance.scheduleNote(title: "Loitering", message: "\(Date().toFormat(Date.hourFormat)) you exited.")
    }
}
