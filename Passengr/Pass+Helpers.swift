//
//  Pass+Helpers.swift
//  Passengr
//
//  Created by Andrew Shepard on 12/9/15.
//  Copyright © 2015 Andrew Shepard. All rights reserved.
//

import UIKit

extension Pass {
    var isOpen: Bool {
        let westboundOpen = westbound.lowercased().range(of: "no restrictions") != nil
        let eastboundOpen = eastbound.lowercased().range(of: "no restrictions") != nil
        return westboundOpen && eastboundOpen
    }
    
    var isClosed: Bool {
        let westboundClosed = westbound.lowercased().range(of: "pass closed") != nil
        let eastboundClosed = eastbound.lowercased().range(of: "pass closed") != nil
        return eastboundClosed || westboundClosed
    }
    
    var color: UIColor {
        if self.isOpen {
            return AppStyle.Color.Green
        } else if self.isClosed {
            return AppStyle.Color.Red
        } else {
            return AppStyle.Color.Orange
        }
    }
}
