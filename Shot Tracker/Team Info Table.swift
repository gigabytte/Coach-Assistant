//
//  Team Info Table.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-01-21.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import Foundation
import RealmSwift


class teamInfoTable: Object {
    
    @objc dynamic var teamID: Int = 0
    @objc dynamic var nameOfTeam: String = ""
    @objc dynamic var activeState: Bool = true
    
    override class func primaryKey() -> String {
        return "teamID"
    }
    
}
