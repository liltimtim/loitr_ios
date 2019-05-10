//
//  MapOverviewViewController.swift
//  Loitr
//
//  Created by Timothy Dillman on 5/2/19.
//  Copyright © 2019 Timothy Dillman. All rights reserved.
//

import UIKit
import MapKit
final class MapOverviewViewController : UIViewController {
    
    private var mapview: MKMapView!
    
    var locationProvider: LocationManagerInterface!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationProvider = LocationProvider.instance
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        locationProvider.requestPermission()
        mapview.setUserTrackingMode(.follow, animated: true)
    }
    
    private func setupUI() {
        mapview = MKMapView()
        mapview.delegate = self
        
        mapview.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapview)
        mapview.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        mapview.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        mapview.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        mapview.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        mapview.showsUserLocation = true
    }
    
    private func setupFenceOverlays() {
        DispatchQueue.main.async {
            self.mapview.removeOverlays(self.mapview.overlays)
            let monitoredRegions = self.locationProvider.monitoredRegions()
            self.mapview.addOverlays(monitoredRegions.map({
                let region = $0 as! CLCircularRegion
                return MKCircle(center: region.center, radius: region.radius)
            }))
        }
    }
}

extension MapOverviewViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let render = MKCircleRenderer(circle: overlay as! MKCircle)
            render.strokeColor = UIColor.lightBlueColor
            render.lineWidth = 1
            render.fillColor = UIColor.lightBlueColor.withAlphaComponent(0.2)
            return render
        }
        
        return MKOverlayRenderer()
    }
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        if fullyRendered {
            setupFenceOverlays()
        }
    }
}

extension MapOverviewViewController: LocationManagerDelegate {
    func locationPermissionDenied() {
        print("permission denied")
    }
    
    func didAddGeofenceLocation() {
        setupFenceOverlays()
    }
    
    func locationPermissionAllowed() {
        print("pmerission allowed")
    }
}
