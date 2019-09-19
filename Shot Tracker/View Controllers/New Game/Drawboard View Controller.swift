//
//  Drawboard View Controller.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-09-05.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit
import RealmSwift
import MaLiang

class Drawboard_View_Controller: UIViewController, UIPopoverPresentationControllerDelegate {
    @IBOutlet weak var skatesBrushButton: UIButton!
    @IBOutlet weak var skatingWithPuckBrush: UIButton!
    @IBOutlet weak var backwardSkatingBrush: UIButton!
    @IBOutlet weak var eraserBrushButton: UIButton!
    
    @IBOutlet weak var shotModelSelectionButton: UIButton!
    @IBOutlet weak var playerModelSelectionButton: UIButton!
    @IBOutlet weak var iceRInkImageView: UIImageView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var clipboardImageView: UIImageView!
    @IBOutlet weak var playerModelSelectionView: UIView!
    @IBOutlet var popUpView: UIView!
    @IBOutlet weak var canvas: Canvas!
    
    var orginalSkatesBrushCon: NSLayoutConstraint!
    var enlargedSkatesBrushCon: NSLayoutConstraint!
    
    var orginalSkatingPuckBrushCon: NSLayoutConstraint!
    var enlargedSkatingPuckBrushCon: NSLayoutConstraint!
    
    var orginalBackwardSkatesBrushCon: NSLayoutConstraint!
    var enlargedBackwardSkatesBrushCon: NSLayoutConstraint!
    
    var orginalShotSelectionBtnCon: NSLayoutConstraint!
    var enlargedShotSelectionBtnCon: NSLayoutConstraint!
    
    var orginalPlayerModelBtnCon: NSLayoutConstraint!
    var enlargedPlayerModelBtnCon: NSLayoutConstraint!
    
    var orginalEraserBrushCon: NSLayoutConstraint!
    var enlargedEraserBrushCon: NSLayoutConstraint!
    
    var orginalPlayerModelViewCon: NSLayoutConstraint!
    var enlargedPlayerModelViewCon: NSLayoutConstraint!
    
    var dirFolderName: String!
    
    var iceRinkImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
      
        onLoad()
    }
    

    func onLoad(){
        // load ice runk image from segue pass
        iceRInkImageView.image = iceRinkImage
        
        viewColour()
        // set dynamic brush button cons
        loadConstraints()
        // set the first briush type as defaulted selection on launch
        loadBrushs(brushType: 0)
        enlargeButtons(buttonType: 0)
        
        
    }
    
    func loadConstraints(){
        // brush btn selection constraints
        orginalSkatesBrushCon = skatesBrushButton.heightAnchor.constraint(equalTo: popUpView.heightAnchor, multiplier: 0.1, constant: 0)
        orginalSkatesBrushCon.isActive = true
        enlargedSkatesBrushCon = skatesBrushButton.heightAnchor.constraint(equalTo: popUpView.heightAnchor, multiplier: 0.15, constant: 0)
        enlargedSkatesBrushCon.isActive = false
        
        orginalSkatingPuckBrushCon = skatingWithPuckBrush.heightAnchor.constraint(equalTo: popUpView.heightAnchor, multiplier: 0.1, constant: 0)
        orginalSkatingPuckBrushCon.isActive = true
        enlargedSkatingPuckBrushCon = skatingWithPuckBrush.heightAnchor.constraint(equalTo: popUpView.heightAnchor, multiplier: 0.15, constant: 0)
        enlargedSkatingPuckBrushCon.isActive = false
        
        orginalBackwardSkatesBrushCon = backwardSkatingBrush.heightAnchor.constraint(equalTo: popUpView.heightAnchor, multiplier: 0.1, constant: 0)
        orginalBackwardSkatesBrushCon.isActive = true
        enlargedBackwardSkatesBrushCon = backwardSkatingBrush.heightAnchor.constraint(equalTo: popUpView.heightAnchor, multiplier: 0.15, constant: 0)
        enlargedBackwardSkatesBrushCon.isActive = false
        
        orginalShotSelectionBtnCon = shotModelSelectionButton.heightAnchor.constraint(equalTo: popUpView.heightAnchor, multiplier: 0.1, constant: 0)
        orginalShotSelectionBtnCon.isActive = true
        enlargedShotSelectionBtnCon = shotModelSelectionButton.heightAnchor.constraint(equalTo: popUpView.heightAnchor, multiplier: 0.15, constant: 0)
        enlargedShotSelectionBtnCon.isActive = false
        
        orginalPlayerModelBtnCon = playerModelSelectionButton.heightAnchor.constraint(equalTo: popUpView.heightAnchor, multiplier:0.1, constant: 0)
        orginalPlayerModelBtnCon.isActive = true
        enlargedPlayerModelBtnCon = playerModelSelectionButton.heightAnchor.constraint(equalTo: popUpView.heightAnchor, multiplier: 0.15, constant: 0)
        enlargedPlayerModelBtnCon.isActive = false
        
        orginalEraserBrushCon = eraserBrushButton.heightAnchor.constraint(equalTo: popUpView.heightAnchor, multiplier: 0.1, constant: 0)
        orginalEraserBrushCon.isActive = true
        enlargedEraserBrushCon = eraserBrushButton.heightAnchor.constraint(equalTo: popUpView.heightAnchor, multiplier: 0.15, constant: 0)
        enlargedEraserBrushCon.isActive = false
        
        
        orginalPlayerModelViewCon = playerModelSelectionView.widthAnchor.constraint(equalTo: playerModelSelectionButton.widthAnchor, multiplier: 0.0, constant: 0)
        orginalPlayerModelViewCon.isActive = true
        enlargedPlayerModelViewCon = playerModelSelectionView.widthAnchor.constraint(equalTo: playerModelSelectionButton.widthAnchor, multiplier: 5.5, constant: 0)
        enlargedPlayerModelViewCon.isActive = false
    }
    
    func loadBrushs(brushType: Int){
        
        var brushName: String!
       
        switch brushType {
        case 0:
            brushName = "skating_brush"
            break
        case 1:
            brushName = "claw"
            break
        case 2:
            brushName = "pencil"
            break
        case 3:
            brushName = "claw"
            break
        case 4:
            brushName = "pencil"
            break
        case 5:
            brushName = "Eraser"
            break
        default:
            brushName = "pencil"
            break
        }
        if brushName != "Eraser"{
            let data = UIImage(named: "skating_brush")
            let texture = try! canvas.makeTexture(with: data!.pngData()!)
            let pencil: Brush = try! canvas.registerBrush(name: "skating_brush", textureID: texture.id)
            
            //pencil.opacity = 0.05
            //pencil.coreProportion = 0.2
            pencil.pointSize = 20
            pencil.pointStep = data!.size.height + 5
            pencil.rotation = .ahead
            
            pencil.use()
       }else{
            let eraser = try! canvas.registerBrush(name: "Eraser") as Eraser
            eraser.pointSize = 30.0
            eraser.use()
        }
    }
    
    func viewColour(){
        
        // give background blur effect
        // add blur effect to view along with popUpView
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        view.addSubview(popUpView)
        
        playerModelSelectionView.layer.cornerRadius = playerModelSelectionView.frame.height / 2
    }
    
    // Enable detection of shake motion
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let popupVC = storyboard.instantiateViewController(withIdentifier: "Help_View_Controller") as! Help_Guide_View_Controller
            popupVC.modalPresentationStyle = .overCurrentContext
            popupVC.modalTransitionStyle = .crossDissolve
            let pVC = popupVC.popoverPresentationController
            pVC?.permittedArrowDirections = .any
            pVC?.delegate = self
            
            present(popupVC, animated: true, completion: nil)
            print("Help Guide Presented!")
        }
    }
    
    func enlargeButtons(buttonType: Int){
        switch  buttonType{
        case 0:
            orginalSkatesBrushCon.isActive = false
            enlargedSkatesBrushCon.isActive = true
            
            orginalSkatingPuckBrushCon.isActive = true
            enlargedSkatingPuckBrushCon.isActive = false
            
            orginalBackwardSkatesBrushCon.isActive = true
            enlargedBackwardSkatesBrushCon.isActive = false
            
            orginalShotSelectionBtnCon.isActive = true
            enlargedShotSelectionBtnCon.isActive = false
            
            orginalPlayerModelBtnCon.isActive = true
            enlargedPlayerModelBtnCon.isActive = false
            
            orginalEraserBrushCon.isActive = true
            enlargedEraserBrushCon.isActive = false
            break
        case 1:
            orginalSkatesBrushCon.isActive = true
            enlargedSkatesBrushCon.isActive = false
            
            orginalSkatingPuckBrushCon.isActive = false
            enlargedSkatingPuckBrushCon.isActive = true
            
            orginalBackwardSkatesBrushCon.isActive = true
            enlargedBackwardSkatesBrushCon.isActive = false
            
            orginalShotSelectionBtnCon.isActive = true
            enlargedShotSelectionBtnCon.isActive = false
            
            orginalPlayerModelBtnCon.isActive = true
            enlargedPlayerModelBtnCon.isActive = false
            
            orginalEraserBrushCon.isActive = true
            enlargedEraserBrushCon.isActive = false
            break
        case 2:
            orginalSkatesBrushCon.isActive = true
            enlargedSkatesBrushCon.isActive = false
            
            orginalSkatingPuckBrushCon.isActive = true
            enlargedSkatingPuckBrushCon.isActive = false
            
            orginalBackwardSkatesBrushCon.isActive = false
            enlargedBackwardSkatesBrushCon.isActive = true
            
            orginalShotSelectionBtnCon.isActive = true
            enlargedShotSelectionBtnCon.isActive = false
            
            orginalPlayerModelBtnCon.isActive = true
            enlargedPlayerModelBtnCon.isActive = false
            
            orginalEraserBrushCon.isActive = true
            enlargedEraserBrushCon.isActive = false
            break
        case 3:
            orginalSkatesBrushCon.isActive = true
            enlargedSkatesBrushCon.isActive = false
            
            orginalSkatingPuckBrushCon.isActive = true
            enlargedSkatingPuckBrushCon.isActive = false
            
            orginalBackwardSkatesBrushCon.isActive = true
            enlargedBackwardSkatesBrushCon.isActive = false
            
            orginalShotSelectionBtnCon.isActive = false
            enlargedShotSelectionBtnCon.isActive = true
            
            orginalPlayerModelBtnCon.isActive = true
            enlargedPlayerModelBtnCon.isActive = false
            
            orginalEraserBrushCon.isActive = true
            enlargedEraserBrushCon.isActive = false
            break
        case 4:
            orginalSkatesBrushCon.isActive = true
            enlargedSkatesBrushCon.isActive = false
            
            orginalSkatingPuckBrushCon.isActive = true
            enlargedSkatingPuckBrushCon.isActive = false
            
            orginalBackwardSkatesBrushCon.isActive = true
            enlargedBackwardSkatesBrushCon.isActive = false
            
            orginalShotSelectionBtnCon.isActive = true
            enlargedShotSelectionBtnCon.isActive = false
            
            orginalPlayerModelBtnCon.isActive = false
            enlargedPlayerModelBtnCon.isActive = true
            
            orginalEraserBrushCon.isActive = true
            enlargedEraserBrushCon.isActive = false
            break
        case 5:
            orginalSkatesBrushCon.isActive = true
            enlargedSkatesBrushCon.isActive = false
            
            orginalSkatingPuckBrushCon.isActive = true
            enlargedSkatingPuckBrushCon.isActive = false
            
            orginalBackwardSkatesBrushCon.isActive = true
            enlargedBackwardSkatesBrushCon.isActive = false
            
            orginalShotSelectionBtnCon.isActive = true
            enlargedShotSelectionBtnCon.isActive = false
            
            orginalPlayerModelBtnCon.isActive = true
            enlargedPlayerModelBtnCon.isActive = false
            
            orginalEraserBrushCon.isActive = false
            enlargedEraserBrushCon.isActive = true
            break
        default:
            orginalSkatesBrushCon.isActive = false
            enlargedSkatesBrushCon.isActive = true
            
            orginalSkatingPuckBrushCon.isActive = true
            enlargedSkatingPuckBrushCon.isActive = false
            
            orginalBackwardSkatesBrushCon.isActive = true
            enlargedBackwardSkatesBrushCon.isActive = false
            
            orginalShotSelectionBtnCon.isActive = true
            enlargedShotSelectionBtnCon.isActive = false
            
            orginalPlayerModelBtnCon.isActive = true
            enlargedPlayerModelBtnCon.isActive = false
            
            orginalEraserBrushCon.isActive = true
            enlargedEraserBrushCon.isActive = false
            break
        }
        
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    func playerModelViewFade(isVisable: Bool){
        if isVisable == true && orginalPlayerModelViewCon.isActive == true{
            orginalPlayerModelViewCon.isActive = false
            enlargedPlayerModelViewCon.isActive = true
            
            self.playerModelSelectionView.isHidden = false
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [], animations: {
                
                self.playerModelSelectionView.alpha = 1.0
                self.view.layoutIfNeeded()
                
            }, completion: { _ in
                print("Player Model View Shown")
            })
        }else if isVisable == false && enlargedPlayerModelViewCon.isActive == true {
            
            orginalPlayerModelViewCon.isActive = true
            enlargedPlayerModelViewCon.isActive = false
            
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [], animations: {
                
                self.playerModelSelectionView.alpha = 0.0
                self.view.layoutIfNeeded()
                
            }, completion: { _ in
                print("Player Model View Had disappeared")
                self.playerModelSelectionView.isHidden = true
            })
        }
    }
    
    func getDate() -> String{
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy.hh.mm.ss"
        
        return formatter.string(from: date)
    }
    
    func createDir(dirName: String){
        
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let docURL = URL(string: documentsDirectory)!
        let tempDir = docURL.appendingPathComponent("DrawboardSaves")
        let teamlogo_dataPath = tempDir.appendingPathComponent(dirName)
        
        
        // check and creat apporate directories for drawboard images
        if !FileManager.default.fileExists(atPath: teamlogo_dataPath.absoluteString) {
            do {
                try FileManager.default.createDirectory(atPath: teamlogo_dataPath.absoluteString, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription);
            }
        }
    }
    
    func dirNameGen(){
        
        let realm = try! Realm()
        let teamObjc = realm.object(ofType: teamInfoTable.self, forPrimaryKey: UserDefaults.standard.integer(forKey: "homeTeam"))
     
        
        dirFolderName =  "\((teamObjc?.nameOfTeam)!)_\((teamObjc?.teamID)!)_\(getDate())_drawboard"
    }
    
    func saveDrawing(){
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let tempUrl = dir.appendingPathComponent("DrawboardSaves")
            let fileURL = tempUrl.appendingPathComponent(dirFolderName)
            
            // 1. create an instance of `DataExporter` with your canvas:
            let exporter = DataExporter(canvas: self.canvas)
            // 2. save to empty folders on disk:
            exporter.save(to: fileURL, identifier: "", progress: { (progress) in
                print(progress)
                if progress == 1.0{
                    self.saveBackgroundImage()
                }
            }, result: { (results: Result<Void, Error>) -> () in
               
               print(results)
            
               
            })
            
        }
        
    }
    
    func saveBackgroundImage() -> Bool{
        
        let imageData = iceRInkImageView.image!.jpegData(compressionQuality: 0.50)
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let tempUrl = dir.appendingPathComponent("DrawboardSaves")
            let fileURL = tempUrl.appendingPathComponent(dirFolderName)
            let fileName = fileURL.appendingPathComponent("background_\((dirFolderName)!)")
            
            do {
                try imageData!.write(to: fileName, options: .atomicWrite)
                // send realm the location of the logo in DD
               
                
            } catch {
                fatalErrorAlert("An error has occured while attempting to save your sketchs. Please contact support!")
                return false
            }
        }
        return true
    }
    
    // ------------------------------------ popup alerts -------------------------------------
    func saveBeforeExitAlert(){
        // create the alert
        let saveAlert = UIAlertController(title: localizedString().localized(value:"Save your Work!"), message: localizedString().localized(value:"Would you like to save your sketch before exiting? Not saving your sketch will result in lost work."), preferredStyle: UIAlertController.Style.alert)
       
        
        // add an action (button)
        saveAlert.addAction(UIAlertAction(title: "Don't Save", style: UIAlertAction.Style.cancel, handler: { action in
            print("NOT Saving Sketch")
           self.dismiss(animated: true, completion: nil)
        }))
       
        
        // add an action (button)
        saveAlert.addAction(UIAlertAction(title: "Save", style: UIAlertAction.Style.default, handler: { action in
            
            print("Saving Sketch")
            self.dirNameGen()
            self.createDir(dirName: self.dirFolderName)
            self.saveDrawing()
            if self.saveBackgroundImage() == true{
                self.dismiss(animated: true, completion: nil)
            }
            
            let realm = try! Realm()
            let newGameObjc = realm.object(ofType: newGameTable.self, forPrimaryKey: UserDefaults.standard.integer(forKey: "gameID"))
            try! realm.write {
                newGameObjc?.drawboardURL.append(self.dirFolderName!)
            }
            
            
        }))
        
        // show the alert
        self.present(saveAlert, animated: true, completion: nil)
    }
    
    func fatalErrorAlert(_ msg: String){
        
        let errorAlert = UIAlertController(title: localizedString().localized(value:"Whoops!"), message: localizedString().localized(value:"\(msg)"), preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        errorAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        // show the alert
        self.present(errorAlert, animated: true, completion: nil)
        
    }
    
    // -----------------------------------------------------------------
    
    @IBAction func closeButton(_ sender: UIButton) {
        
        
        saveBeforeExitAlert()
    }
    

    @IBAction func skatesBrushTypeButton(_ sender: UIButton) {
        
        loadBrushs(brushType: 0)
        enlargeButtons(buttonType: 0)
        
        playerModelViewFade(isVisable:  false)
    
        
    }
    @IBAction func skatingWithPuckBrush(_ sender: UIButton) {
        
        loadBrushs(brushType: 1)
        enlargeButtons(buttonType: 1)
        
        playerModelViewFade(isVisable:  false)
        
       
    }
    @IBAction func backwardSkating(_ sender: UIButton) {
        
        loadBrushs(brushType: 2)
        enlargeButtons(buttonType: 2)
        
        playerModelViewFade(isVisable:  false)
       
    }
    @IBAction func shotSelectionButton(_ sender: UIButton) {
        
        loadBrushs(brushType: 3)
        enlargeButtons(buttonType: 3)
        
        playerModelViewFade(isVisable:  false)
        
    }
    @IBAction func playerTypeSelectionButton(_ sender: UIButton) {
        
        loadBrushs(brushType: 4)
        enlargeButtons(buttonType: 4)
    
        playerModelViewFade(isVisable:  true)
       
    }
    
    @IBAction func eraserBrushButton(_ sender: UIButton) {
        loadBrushs(brushType: 5)
        enlargeButtons(buttonType: 5)
        
        playerModelViewFade(isVisable:  false)
       
    }
    
    @IBAction func goalieBrushButton(_ sender: UIButton) {
    }
    
    @IBAction func forwardBrushButton(_ sender: Any) {
    }
    @IBAction func defenseBrushButton(_ sender: Any) {
    }
    
}
