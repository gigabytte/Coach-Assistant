//
//  LockerRoom Add View Controller.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-09-10.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit

class LockerRoom_Add_View_Controller: UIViewController, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var addConatinerView: UIView!
    @IBOutlet weak var addPlayerButton: UIButton!
    @IBOutlet weak var addTeamButton: UIButton!
    
    var tutorialPageViewController: Add_Page_Controller_View_Controller? {
        didSet {
            tutorialPageViewController?.tutorialDelegate = self as? addVCPageViewControllerDelegate
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    func onLoad(){
        
        
    }
    
    func viewColour(){
        
    }
    
    @IBAction func addTeamButton(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "addVC_menuBtnPress"), object: nil, userInfo: ["btnNumber":1])
    }
    
    
    @IBAction func adPlayerButton(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "addVC_menuBtnPress"), object: nil, userInfo: ["btnNumber":0])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let tutorialPageViewController = segue.destination as? Add_Page_Controller_View_Controller {
            self.tutorialPageViewController = tutorialPageViewController
        }
    }
}
extension LockerRoom_Add_View_Controller: addVCPageViewControllerDelegate {
    func tutorialPageViewController(tutorialPageViewController: Add_Page_Controller_View_Controller, didUpdatePageCount count: Int) {
        
    }
    
    func tutorialPageViewController(tutorialPageViewController: Add_Page_Controller_View_Controller, didUpdatePageIndex index: Int) {
        switch index {
        case 0:
            addPlayerButton.alpha = 1.0
            addTeamButton.alpha = 0.5
        case 1:
            addPlayerButton.alpha = 0.5
            addTeamButton.alpha = 1.0
        default:
            addPlayerButton.alpha = 1.0
            addTeamButton.alpha = 0.5
        }
    }
    
  
}

