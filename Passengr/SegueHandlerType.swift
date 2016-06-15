//
//  SegueHandlerType.swift
//  Passengr
//
//  Created by Andrew Shepard on 11/28/15.
//  Copyright © 2015 Andrew Shepard. All rights reserved.
//

import UIKit

protocol SegueHandlerType {
    associatedtype SegueIdentifier: RawRepresentable
}

extension SegueHandlerType where Self: UIViewController, SegueIdentifier.RawValue == String {
    
    func preformSegueWithIdentifier(segueIdentifer identifier: SegueIdentifier, sender: AnyObject?) {
        performSegue(withIdentifier: identifier.rawValue, sender: sender)
    }
    
    func segueIdentifier(for segue: UIStoryboardSegue) -> SegueIdentifier {
        guard let identifer = segue.identifier,
            segueIdentifier = SegueIdentifier(rawValue: identifer)
        else {
            fatalError("segue identifier not found for segue: \(segue)")
        }
        
        return segueIdentifier
    }
}
