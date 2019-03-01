//
//  monster.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-03-01.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import Foundation
import UIKit

enum Weapon {
    case blowgun, ninjaStar, fire, sword, smoke
}

class Monster {
    let name: String
    let description: String
    let iconName: String
    let weapon: Weapon
    
    init(name: String, description: String, iconName: String, weapon: Weapon) {
        self.name = name
        self.description = description
        self.iconName = iconName
        self.weapon = weapon
    }
    
    var weaponImage: UIImage {
        switch weapon {
        case .blowgun:
            return #imageLiteral(resourceName: "blowgun.png")
        case .fire:
            return #imageLiteral(resourceName: "fire.png")
        case .ninjaStar:
            return #imageLiteral(resourceName: "ninjastar.png")
        case .smoke:
            return #imageLiteral(resourceName: "smoke.png")
        case .sword:
            return #imageLiteral(resourceName: "sword.png")
        }
    }
    
    var icon: UIImage? {
        return UIImage(named: iconName)
    }
}
