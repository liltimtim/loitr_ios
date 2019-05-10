//
//  FenceEvent.swift
//  Loitr
//
//  Created by Timothy Dillman on 5/2/19.
//  Copyright © 2019 Timothy Dillman. All rights reserved.
//

import Foundation
import SwiftDate

class FenceEvent: NSObject {
    var type: String = ""
    var date: Date = Date()
    
    enum EventType : String {
        case entered = "enter"
        case exit = "exit"
    }
    
    private override init() {
        super.init()
        type = ""
        date = Date()
    }
    
    init(with dict: [String:Any]) {
        super.init()
        type = dict["type"] as! String
        date = dict["date"] as! Date
    }
    
    init(type: EventType, date: Date) {
        super.init()
        self.type = type.rawValue
        self.date = date
    }
    
    func toDict() -> [String:Any] {
        return ["type":type, "date":date]
    }
}



final class FenceEventManager {
    
    var onSaveEvent: (() -> Void)?
    
    static let instance = FenceEventManager()
    
    var adapter: StorageAdapterInterface?
    
    private var events: [FenceEvent] = []
    
    private init() {
        // init a default adapter user preferences
        adapter = SharedPreferencesAdapter()
    }
    
    func save(event: FenceEvent) {
        var events = allEvents()
        events.append(event)
        adapter?.save(key: "events", object: events.map({ return $0.toDict() }))
        onSaveEvent?()
    }
    
    
    func save() {
        adapter?.save(key: "events", object: events.map({ return $0.toDict() }))
    }
    func delete(event: FenceEvent) {
        if let i = events.firstIndex(where: { $0 == event }) {
            events.remove(at: i)
            save()
        }
    }
    
    func allEvents() -> [FenceEvent] {
        events = (adapter?.getAll(forKey: "events") as? Array<[String:Any]>)?.map({ return FenceEvent(with: $0)}) ?? [FenceEvent]()
        return events
    }
    /**
     Returns dates for the given date ranges
    */
    func dates(for start:Date, end:Date) -> [FenceEvent] {
        return allEvents().filter({ return $0.date >= start && $0.date <= end }).sorted(by: { $0.date < $1.date })
    }
    
    /**
     Returns total number of hours based on entrance and exit events.
    */
    func hourSummary(for start: Date, end: Date) -> Double {
        let events = allEvents().filter({ return $0.date >= start && $0.date <= end })
        var entranceEvents = events.filter({ return $0.type == FenceEvent.EventType.entered.rawValue }).sorted(by: { return $0.date < $1.date })
        var exitEvents = events.filter({ return $0.type == FenceEvent.EventType.exit.rawValue }).sorted(by: { return $0.date < $1.date })
        
        // determine if we have an even number of entrance events and exit events otherwise we missed a punch so drop until even
        let even = (entranceEvents.count + exitEvents.count) % 2
        if (even == 0) {
            var summary: Double = 0
            for (i, _) in entranceEvents.enumerated() {
                let sum = exitEvents[i].date - entranceEvents[i].date
                let hours = sum.hour ?? 0
                let minutes = sum.minute ?? 0
                summary += Double(hours) + Double(minutes / 60)
            }
            return summary
        } else {
            // one is not even figure out which and equalize
            if entranceEvents.count > exitEvents.count {
                // entrance is larger calc by how much
                let diff = entranceEvents.count - exitEvents.count
                entranceEvents.removeLast(diff)
            } else {
                let diff = exitEvents.count - entranceEvents.count
                exitEvents.removeLast(diff)
            }
            return hourSummary(for: entranceEvents.sorted(by: { $0.date < $1.date }).first!.date, end: exitEvents.sorted(by: { $0.date < $1.date }).last!.date)
        }
    }
    /**
     Determines if the day summary should be given or up until the current date given
    */
    func summary(for date: Date) -> Double {
        let startOfDay = date.dateBySet(hour: 0, min: 0, secs: 0)
        let endOfDay = date.dateBySet(hour: 23, min: 59, secs: 59)
        // check if date is less than end of day
        var summary: Double
        if (date < endOfDay!) {
            // grab the summary up to date
            summary = hourSummary(for: startOfDay!, end: date)
        } else {
            // grab the summary for the entire day range
            summary = hourSummary(for: startOfDay!, end: endOfDay!)
        }
        return summary
    }
    
    func arrival(for date: Date) -> Date? {
        return allEvents().filter({ $0.date >= date.dateBySet(hour: 0, min: 0, secs: 0)! && $0.date <= date }).sorted(by: { $0.date < $1.date }).first(where: { $0.type == FenceEvent.EventType.entered.rawValue })?.date
    }
    
    func departure(for date: Date) -> Date? {
        let events = allEvents().filter({ $0.date >= date.dateBySet(hour: 0, min: 0, secs: 0)! && $0.date <= date.dateBySet(hour: 23, min: 59, secs: 59)! })
        // if we have an even number of both arrival and departure dates, then we need to return the last date otherwise return nil
        let arrivalEvents = events.filter({ $0.type == FenceEvent.EventType.entered.rawValue })
        let departureEvents = events.filter({ $0.type == FenceEvent.EventType.exit.rawValue })
        
        // if both events are 1 count
        if arrivalEvents.count == 1 && departureEvents.count == 1 {
            // handle case where you enter and exit very quickly
            var diff: DateComponents
            if let departureEvent = departureEvents.first, let arrivalEvent = arrivalEvents.first {
                diff = departureEvent.date - arrivalEvent.date
                guard let hour = diff.hour, let minute = diff.minute, let second = diff.second else { return nil }
                if hour == 0 && minute == 0 && second < 59 { return nil }
            }
            return events.sorted(by: { $0.date > $1.date }).first(where: { $0.type == FenceEvent.EventType.exit.rawValue })?.date
        }
        

        
        guard departureEvents.count % 2 == 0 else { return nil }
        return events.sorted(by: { $0.date > $1.date }).first(where: { $0.type == FenceEvent.EventType.exit.rawValue })?.date
    }
    
    func summary(for start:Date, end: Date?) -> (hours: Int, minutes: Int, seconds: Int)? {
        var diff: DateComponents
        if end == nil {
            diff = Date() - start
        } else {
            diff = end! - start
        }
        
        guard let hour = diff.hour, let minute = diff.minute, let second = diff.second else { return nil }
        if hour == 0 && minute == 0 && second < 59 { return nil }
        if (hour == 0 && minute == 0 && second == 0) { return nil }
        return (hour, minute, second)
    }
}

protocol StorageAdapterInterface {
    func save(key: String, object: Any)
    func getAll(forKey key: String) -> [Any]?
}

struct SharedPreferencesAdapter: StorageAdapterInterface {
    func save(key: String, object: Any) {
        UserDefaults.standard.set(object, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    func getAll(forKey key: String) -> [Any]? {
        return UserDefaults.standard.value(forKey: key) as? [Any]
    }
}
