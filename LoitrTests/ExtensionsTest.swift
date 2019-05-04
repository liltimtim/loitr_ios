//
//  ExtensionsTest.swift
//  LoitrTests
//
//  Created by Timothy Dillman on 5/4/19.
//  Copyright © 2019 Timothy Dillman. All rights reserved.
//

import XCTest
import SwiftDate
@testable import Loitr
class ExtensionsTest: XCTestCase {
    func testHourDisplayFromDate() {
        let date = Date().dateBySet(hour: 8, min: 23, secs: 0)
        XCTAssertEqual(date?.toFormat("h:mm a"), "8:23 AM")
        let date2 = Date().dateBySet(hour: 11, min: 23, secs: 0)
        XCTAssertEqual(date2?.toFormat("h:mm a"), "11:23 AM")
    }
}
