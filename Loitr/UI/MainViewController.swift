//
//  MainViewController.swift
//  Loitr
//
//  Created by Timothy Dillman on 5/2/19.
//  Copyright © 2019 Timothy Dillman. All rights reserved.
//

import UIKit

final class MainViewController: UIViewController {
    
    private var mapContainer: UIView!
    
    private var tableContainer: UIView!
    
    private var mapVC: MapOverviewViewController!
    
    private var eventsVC: FenceEventsTableViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    @objc private func dismissVC() {
        dismiss(animated: true, completion: nil)
    }
    
    private func setupUI() {
        mapVC = MapOverviewViewController()
        addChild(mapVC)
        mapContainer = UIView()
        view.addSubview(mapContainer)
        
        mapContainer.translatesAutoresizingMaskIntoConstraints = false
        mapContainer.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: (1.0/3.0)).isActive = true
        mapContainer.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        mapContainer.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        mapContainer.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        view.setNeedsLayout()
        view.layoutIfNeeded()
        mapVC.view.frame = mapContainer.frame
        mapContainer.addSubview(mapVC.view)
        mapVC.didMove(toParent: self)
        
        tableContainer = UIView()
        tableContainer.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableContainer)
        tableContainer.topAnchor.constraint(equalTo: mapContainer.bottomAnchor).isActive = true
        tableContainer.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableContainer.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        eventsVC = FenceEventsTableViewController()
        addChild(eventsVC)
        tableContainer.addSubview(eventsVC.view)
        eventsVC.didMove(toParent: self)
        
        eventsVC.view.translatesAutoresizingMaskIntoConstraints = false
        eventsVC.view.topAnchor.constraint(equalTo: tableContainer.topAnchor).isActive = true
        eventsVC.view.leftAnchor.constraint(equalTo: tableContainer.leftAnchor).isActive = true
        eventsVC.view.rightAnchor.constraint(equalTo: tableContainer.rightAnchor).isActive = true
        eventsVC.view.bottomAnchor.constraint(equalTo: tableContainer.bottomAnchor).isActive = true
        
        let closeBtn = UIButton()
        closeBtn.setTitle("Close", for: .normal)
        closeBtn.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeBtn)
        closeBtn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 28).isActive = true
        closeBtn.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -28).isActive = true
        closeBtn.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
    }
}
