//
//  Extensions.swift
//  Loitr
//
//  Created by Timothy Dillman on 5/4/19.
//  Copyright © 2019 Timothy Dillman. All rights reserved.
//

import Foundation
import UIKit
import SwiftDate

extension Date {
    static let hourFormat: String = "h:mm a"
    
    func toRegion(withFormat format: String) -> String {
        return self.convertTo(region: Region.current).toFormat(format)
    }
}

extension Int {
    func pluralize(with word: String) -> String {
        if self == 0 { return "\(self) \(word)s" }
        if self > 1 { return "\(self) \(word)s" } else { return "\(self) \(word)"}
    }
}

extension UIColor {
    static let lightBlueColor: UIColor = UIColor(red: 50/255, green: 197/255, blue: 255/255, alpha: 1)
    static let purpleColor: UIColor = UIColor(red: 182/255, green: 32/255, blue: 224/255, alpha: 1)
    static let yellowOrangeColor: UIColor = UIColor(red: 247/255, green: 181/255, blue: 0/255, alpha: 1)
    static let summaryGradientStopColors: [CGColor] = [UIColor.lightBlueColor.cgColor, UIColor.purpleColor.cgColor, UIColor.yellowOrangeColor.cgColor]
}
