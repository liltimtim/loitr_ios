//
//  FenceEventManagerTests.swift
//  LoitrTests
//
//  Created by Timothy Dillman on 5/3/19.
//  Copyright © 2019 Timothy Dillman. All rights reserved.
//

import XCTest
import SwiftDate
@testable import Loitr
class FenceEventManagerTests : XCTestCase {
    func testSumTimeLoiteringTodayRange() {
        let compsStartDate = DateComponents(calendar: Calendar.current, timeZone: TimeZone.current, year: 2000, month: 1, day: 1, hour: 13, minute: 0, second: 0)
        let startDate = Calendar.current.date(from: compsStartDate)
        var endDate = compsStartDate
        endDate.hour = 16
        let veryFarPastDate = DateComponents(calendar: Calendar.current, timeZone: TimeZone.current, year: 1999, month: 1, day: 1, hour: 13, minute: 0, second: 0).date!
        let event1 = FenceEvent(type: .entered, date: startDate!)
        let event2 = FenceEvent(type: .exit, date: endDate.date!)
        let event3 = FenceEvent(type: .entered, date: veryFarPastDate)
        FenceEventManager.instance.adapter = MockStorage()
        FenceEventManager.instance.save(event: event1)
        FenceEventManager.instance.save(event: event2)
        FenceEventManager.instance.save(event: event3)
        let summaries = FenceEventManager.instance.dates(for: startDate!, end: endDate.date!)
        XCTAssertEqual(summaries.count, 2)
        let firstEvent = summaries.first
        let lastEvent = summaries.last
        XCTAssertEqual((lastEvent!.date - firstEvent!.date).hour, 3)
    }
    
    func testSumTimeLoiteringWeekRange() {
        let startOfWeek = Date().dateAt(.startOfWeek)
        let endOfWeek = Date().dateAt(.endOfWeek)
        FenceEventManager.instance.adapter = MockStorage()
        for i in 0...6 {
            let startTime = startOfWeek.dateByAdding(i, .day).dateByAdding(8, .hour)
            let endTime = startOfWeek.dateByAdding(i, .day).dateByAdding(16, .hour)
            let enterEvent = FenceEvent(type: .entered, date: startTime.date)
            let exitEvent = FenceEvent(type: .exit, date: endTime.date)
            FenceEventManager.instance.save(event: enterEvent)
            FenceEventManager.instance.save(event: exitEvent)
        }
        let summaries = FenceEventManager.instance.dates(for: startOfWeek, end: endOfWeek)
        XCTAssertEqual(summaries.count, 14)
        XCTAssertEqual(FenceEventManager.instance.hourSummary(for: startOfWeek, end: endOfWeek), 56)
    }
    
    func testSumTimeLoiteringWeekRangeMissingEventsEntrance() {
        let startOfWeek = Date().dateAt(.startOfWeek)
        let endOfWeek = Date().dateAt(.endOfWeek)
        FenceEventManager.instance.adapter = MockStorage()
        for i in 0...6 {
            let startTime = startOfWeek.dateByAdding(i, .day).dateByAdding(8, .hour)
            let endTime = startOfWeek.dateByAdding(i, .day).dateByAdding(16, .hour)
            let enterEvent = FenceEvent(type: .entered, date: startTime.date)
            let exitEvent = FenceEvent(type: .exit, date: endTime.date)
            FenceEventManager.instance.save(event: enterEvent)
            FenceEventManager.instance.save(event: exitEvent)
        }
        
        let summaries = FenceEventManager.instance.dates(for: startOfWeek, end: endOfWeek)
        XCTAssertEqual(summaries.count, 14)
        XCTAssertEqual(FenceEventManager.instance.hourSummary(for: startOfWeek, end: endOfWeek), 56)
    }
    
    func testDepartureForUnevenNumberOfArrivalEvents() {
        let compsStartDate = DateComponents(calendar: Calendar.current, timeZone: TimeZone.current, year: 2000, month: 1, day: 1, hour: 13, minute: 0, second: 0)
        var arrival2 = DateComponents(calendar: Calendar.current, timeZone: TimeZone.current, year: 2000, month: 1, day: 1, hour: 13, minute: 0, second: 0)
        arrival2.hour = 17
        let startDate = Calendar.current.date(from: compsStartDate)
        var endDate = compsStartDate
        let arrival2Date = Calendar.current.date(from: arrival2)
        endDate.hour = 16
        FenceEventManager.instance.adapter = MockStorage()
        let event1 = FenceEvent(type: .entered, date: startDate!)
        let event2 = FenceEvent(type: .exit, date: endDate.date!)
        let event3 = FenceEvent(type: .entered, date: arrival2Date!)
        [event1, event2, event3].forEach({ FenceEventManager.instance.save(event: $0) })
        XCTAssertNil(FenceEventManager.instance.departure(for: startDate!))
    }
    func testDepartureForEvenNumberOfArrivalEvents() {
        let compsStartDate = DateComponents(calendar: Calendar.current, timeZone: TimeZone.current, year: 2000, month: 1, day: 1, hour: 13, minute: 0, second: 0)
        var arrival2 = DateComponents(calendar: Calendar.current, timeZone: TimeZone.current, year: 2000, month: 1, day: 1, hour: 13, minute: 0, second: 0)
        arrival2.hour = 17
        let startDate = Calendar.current.date(from: compsStartDate)
        var endDate = compsStartDate
        var depDate = arrival2
        depDate.hour = 18
        let depDate2 = Calendar.current.date(from: depDate)
        let arrival2Date = Calendar.current.date(from: arrival2)
        endDate.hour = 16
        FenceEventManager.instance.adapter = MockStorage()
        let event1 = FenceEvent(type: .entered, date: startDate!)
        let event2 = FenceEvent(type: .exit, date: endDate.date!)
        let event3 = FenceEvent(type: .entered, date: arrival2Date!)
        let event4 = FenceEvent(type: .exit, date: depDate2!)
        [event1, event2, event3, event4].forEach({ FenceEventManager.instance.save(event: $0) })
        XCTAssertNotNil(FenceEventManager.instance.departure(for: startDate!))
    }
}

class MockStorage: StorageAdapterInterface {
    
    private var database: [String:Any] = [:]
    
    func save(key: String, object: Any) {
        database[key] = object
    }
    
    func getAll(forKey key: String) -> [Any]? {
        return database[key] as? [Any]
    }
}
