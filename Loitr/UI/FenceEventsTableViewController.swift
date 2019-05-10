//
//  FenceEventsTableViewController.swift
//  Loitr
//
//  Created by Timothy Dillman on 5/2/19.
//  Copyright © 2019 Timothy Dillman. All rights reserved.
//

import UIKit
import SwiftDate
final class FenceEventsTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        FenceEventManager.instance.onSaveEvent = newEventSaved
    }
    
    private func newEventSaved() {
        tableView.reloadData()
    }
    
}

extension FenceEventsTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FenceEventManager.instance.allEvents().count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        let event = FenceEventManager.instance.allEvents()[indexPath.row]
        cell.textLabel?.text = event.type
        cell.detailTextLabel?.text = "\(event.date.toRegion(withFormat: "M/d/yyyy h:mm a"))"
        return cell
    }
}
