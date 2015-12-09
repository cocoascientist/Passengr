//
//  Pass+Helpers.swift
//  Passengr
//
//  Created by Andrew Shepard on 12/9/15.
//  Copyright © 2015 Andrew Shepard. All rights reserved.
//

import UIKit

extension Pass {
    var open: Bool {
        let westboundOpen = westbound.lowercaseString.rangeOfString("no restrictions") != nil
        let eastboundOpen = eastbound.lowercaseString.rangeOfString("no restrictions") != nil
        return westboundOpen && eastboundOpen
    }
    
    var closed: Bool {
        let westboundClosed = westbound.lowercaseString.rangeOfString("pass closed") != nil
        let eastboundClosed = eastbound.lowercaseString.rangeOfString("pass closed") != nil
        return eastboundClosed || westboundClosed
    }
    
    var color: UIColor {
        if self.open {
            return AppStyle.greenColor
        }
        else if self.closed {
            return AppStyle.redColor
        }
        else {
            return AppStyle.orangeColor
        }
    }
}
