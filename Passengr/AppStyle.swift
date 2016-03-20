//
//  AppStyle.swift
//  Passengr
//
//  Created by Andrew Shepard on 12/8/15.
//  Copyright © 2015 Andrew Shepard. All rights reserved.
//

import UIKit

struct AppStyle {
    struct Color {
        static let Red = UIColor.hexColor("#e64e42")
        static let Orange = UIColor.hexColor("#e57e31")
        static let Green = UIColor.hexColor("#39cb75")
        static let ForestGreen = UIColor.hexColor("#2e5037")
        static let LightBlue = UIColor.hexColor("#f8f8ff")
    }
    
    struct Font {
        static let Copperplate = UIFont(name: "Copperplate", size: 14.0)
    }
}

extension UIColor {
    class func hexColor(string: String) -> UIColor {
        let set = NSCharacterSet.whitespaceAndNewline()
        var colorString = string.trimmingCharacters(in: set).uppercased()
        
        if (colorString.hasPrefix("#")) {
            colorString = colorString.substring(from: colorString.startIndex.advanced(by: 1))
        }
        
        if (colorString.characters.count != 6) {
            return UIColor.gray()
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
