//
//  PassInfoType.swift
//  Passengr
//
//  Created by Andrew Shepard on 12/7/15.
//  Copyright © 2015 Andrew Shepard. All rights reserved.
//

struct PassInfoKeys {
    static let Title = "title"
    static let ReferenceURL = "referenceURL"
    static let Conditions = "conditions"
    static let Westbound = "westbound"
    static let Eastbound = "eastbound"
    static let LastUpdated = "last_updated"
}

typealias PassInfo = [String: String]

protocol PassInfoType {
    var passInfo: PassInfo { get }
    func updateUsingPassInfo(info: PassInfo)
}
