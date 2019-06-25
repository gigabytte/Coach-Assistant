//
//  Faceoff Info Table.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-06-20.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import Foundation
import RealmSwift

class faceOffInfoTable: Object {
    
    @objc dynamic var faceoffID: Int = 0
    @objc dynamic var gameID: Int = 0
    
    @objc dynamic var winingPlayerID: Int = 0
    @objc dynamic var losingPlayerID: Int = 0
    @objc dynamic var periodNum: Int = 0
    @objc dynamic var faceoffLocationCode: Int = 0
    @objc dynamic var activeState: Bool = true
    
    override class func primaryKey() -> String {
        return "faceoffID"
    }
    
}

