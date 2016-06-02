//
//  CascadePass.swift
//  Passengr
//
//  Created by Andrew Shepard on 12/9/15.
//  Copyright © 2015 Andrew Shepard. All rights reserved.
//

import Foundation

enum CascadePass {
    case Blewett
    case Manastash
    case Satus
    case Snoqualmie
    case Stevens
    case White
    
    var baseURL: NSURL {
        return NSURL(string: "http://www.wsdot.com/traffic/passes")!
    }
    
    var path: String {
        return "\(baseURL)/\(self.name.lowercased()))/"
    }
    
    var name: String {
        switch self {
        case .Blewett: return "Blewett"
        case .Manastash: return "Manastash"
        case .Satus: return "Satus"
        case .Snoqualmie: return "Snoqualmie"
        case .Stevens: return "Stevens"
        case .White: return "White"
        }
    }
}

extension CascadePass {
    static func allPasses() -> [CascadePass] {
        return [.Blewett, .Manastash, .Satus, .Snoqualmie, .Stevens, .White]
    }
}