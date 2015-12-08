//
//  Styles.swift
//  Passengr
//
//  Created by Andrew Shepard on 12/8/15.
//  Copyright © 2015 Andrew Shepard. All rights reserved.
//

import UIKit

struct AppStyle {
    static let redColor = UIColor.hexColor("#e64e42")
    static let orangeColor = UIColor.hexColor("#e57e31")
    static let greenColor = UIColor.hexColor("#39cb75")
    static let forestGreenColor = UIColor.hexColor("#2e5037")
    
    static let lightBlueColor = UIColor.hexColor("#f8f8ff")
}

extension UIColor {
    class func hexColor(string: String) -> UIColor {
        let set = NSCharacterSet.whitespaceAndNewlineCharacterSet()
        var colorString = string.stringByTrimmingCharactersInSet(set).uppercaseString
        
        if (colorString.hasPrefix("#")) {
            colorString = colorString.substringFromIndex(colorString.startIndex.advancedBy(1))
        }
        
        if (colorString.characters.count != 6) {
            return UIColor.grayColor()
        }
        
        var rgbValue: UInt32 = 0
        NSScanner(string: colorString).scanHexInt(&rgbValue)
        
        return UIColor(
            red:   CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue:  CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}