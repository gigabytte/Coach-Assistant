//
//  Old_Stats_Game_View.swift
//  Shot Tracker
//
//  Created by Ahad Ahmed on 2019-02-18.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit
import RealmSwift
import Realm

class Old_Stats_Game_View: UIViewController, UITableViewDelegate {
    //Create variables to hold game information
    
    
    var selectedGameID: Int!
    var selectedDate: Int!
    
    let realm = try! Realm()
    
    var GameData:Results<newGameTable>!
    var GameSelected:[newGameTable] = []
    var SeletedGame: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(SeletedGame)
        //Methods for populating page with game data from Realm
        querySelectedGame()
        
    }
    func querySelectedGame(){
        let GameList = realm.object(ofType: newGameTable.self, forPrimaryKey: realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)
        
    }
    
    
    
}
