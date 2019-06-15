//
//  In Game Settings ViewController.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-06-14.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit

class In_Game_Settings_ViewController: UIViewController, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var inGameLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var helpButton: UIButton!
    @IBOutlet weak var goalSwitch: UISwitch!
    @IBOutlet weak var shotSwitch: UISwitch!
    @IBOutlet weak var panaltySwitch: UISwitch!
    @IBOutlet weak var penaltyLengthPicker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // add blur effect to view along with popUpView
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        view.addSubview(popUpView)
        
        popUpView.layer.cornerRadius = 10
        roundedCorners().labelViewTopLeftRight(labelViewType: inGameLabel)
        roundedCorners().buttonBottomLeftRight(bottonViewType: saveButton)
    }
    

    @IBAction func saveButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func helpButon(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: "Need Some Help?", message: "In Game Settings allow for the disabling / enabling of elements residing on the Ice Surface of your current game along with this game attributes such as penalty minutes and more. These attributes do not reflect your global settings.", preferredStyle: .actionSheet)
        
        // tapp anywhere outside of popup alert controller
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert: UIAlertAction!) -> Void in
            print("didPress Cancel")
        })
        // Add the actions to your actionSheet
        actionSheet.addAction(cancelAction)
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = self.helpButton
            
        }
        // Present the controller
        self.present(actionSheet, animated: true, completion: nil)
    }
}
