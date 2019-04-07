//
//  AppStyle.swift
//  Passengr
//
//  Created by Andrew Shepard on 12/8/15.
//  Copyright © 2015 Andrew Shepard. All rights reserved.
//

import UIKit

enum AppStyle {
    enum Color {
        static let red = UIColor.hexColor(string: "#e64e42")
        static let orange = UIColor.hexColor(string: "#e57e31")
        static let green = UIColor.hexColor(string: "#39cb75")
        static let forestGreen = UIColor.hexColor(string: "#2e5037")
        static let lightBlue = UIColor.hexColor(string: "#f8f8ff")
    }
    
    enum Font {
        static let copperplate = UIFont(name: "Copperplate", size: 14.0)
    }
}

extension UIColor {
    class func hexColor(string: String) -> UIColor {
        let set = NSCharacterSet.whitespacesAndNewlines
        var colorString = string.trimmingCharacters(in: set).uppercased()
        
        if (colorString.hasPrefix("#")) {
            let index = colorString.index(after: colorString.startIndex)
            colorString = String(colorString[index..<colorString.endIndex])
        }
        
        if (colorString.count != 6) {
            return UIColor.gray
        }
        
        var rgbValue: UInt32 = 0
        Scanner(string: colorString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red:   CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue:  CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
