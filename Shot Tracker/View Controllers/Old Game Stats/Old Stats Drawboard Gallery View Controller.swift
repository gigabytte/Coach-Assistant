//
//  Old Stats Drawboard Gallery View Controller.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-09-07.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit
import MaLiang
import RealmSwift

class Old_Stats_Drawboard_Gallery_View_Controller: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var canvas: Canvas!
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var noSketchIMageViewError: UIImageView!
    @IBOutlet weak var noSketchError: UILabel!
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var iceSurfaceImageArray: [UIImage] = [UIImage]()
    var drawboardDirectoriesList = List<String>()
    var drawboardDirectoriesArray: [String] = [String]()
    var tagCounterArray: [Int] = [Int]()
    
    var gameID = UserDefaults.standard.integer(forKey: "gameID")
    
    var currentImage: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        scrollView.frame = subView.frame
        // Do any additional setup after loading the view.
        onLoad()
    }
    
    func onLoad(){
        
        canvas.isUserInteractionEnabled = false
        
        if getBackgroundImages() == true{
            getCanvasSketch(pageIndex: pageControl.currentPage)
        }
        scrollViewProperties()
        viewColour()
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
    }
    
    func getCanvasSketch(pageIndex: Int){
        
        let URLs = drawboardDirectoriesArray[pageIndex]
        let fileManager = FileManager.default
        
            if let dir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
                
                let currentDIR = (dir.appendingPathComponent("DrawboardSaves")).appendingPathComponent(URLs)
                
                do {
                    
                    DataImporter.importData(from: currentDIR, to: canvas, progress: { (progress) in
                        print(progress)
                    }, result: { (results: Result<Void, Error>) -> () in
                        
                        print(results)
                        
                        
                    })
    
                    
                }catch{
                    print("Sketch read error 2")
                    fatalErrorAlert("Unable to locate files specfied by User, please try again. If problem persits please conatct support")
                }
           
                
            }
        }
    

    func getBackgroundImages() -> Bool{
        let realm = try! Realm()
        
        let newGameObjc = realm.object(ofType: newGameTable.self, forPrimaryKey: gameID)
        
        drawboardDirectoriesArray = Array(newGameObjc!.drawboardURL)
        
        if drawboardDirectoriesArray.isEmpty != true{
            
            let fileManager = FileManager.default
            
            for URLs in drawboardDirectoriesArray{
                if let dir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
                    
                    let currentDIR = (dir.appendingPathComponent("DrawboardSaves")).appendingPathComponent(URLs)
                   
                    do {
                        let allDirFiles = try fileManager.contentsOfDirectory(atPath: "\(currentDIR.path)")
                        let backgroundFileName = allDirFiles.filter{$0.contains("background_")}
                       
                        guard let data = try? Data(contentsOf: currentDIR.appendingPathComponent(backgroundFileName.first!)) else {
                                print("Sketch read error 1")
                                fatalErrorAlert("An error has occured while attempting to retrieve your sketchs, please try again. If problem persits please conatct support")
                                break
                                // return or break
                            }
                        iceSurfaceImageArray.append(UIImage(data: data)!)
                       
                       
                    }catch{
                        print("Sketch read error 2")
                        fatalErrorAlert("Unable to locate files specfied by User, please try again. If problem persits please conatct support")
                    }
                    
                    
                   
                }
            }
            return true
        }else{
            noSketchIMageViewError.isHidden = false
            noSketchError.isHidden = false
             return false
        }
    }
    
    func scrollViewProperties(){
        var tagCounter = 0
        
        
        for i in 0..<iceSurfaceImageArray.count{
            let imageView = UIImageView()
            imageView.image = iceSurfaceImageArray[i]
            imageView.contentMode = .scaleAspectFit
            let xPosition = self.subView.frame.width * CGFloat(i)
            imageView.frame = CGRect(x: xPosition, y: 0, width: self.scrollView.frame.width, height: self.scrollView.frame.height)
            
            scrollView.contentSize.width = scrollView.frame.width * CGFloat(i + 1)
            scrollView.addSubview(imageView)
            
            tagCounterArray.append(tagCounter)
            tagCounter = tagCounter + 1
        }
        
        pageControl.numberOfPages = iceSurfaceImageArray.count
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x / scrollView.bounds.size.width)
        
        self.pageControl.currentPage = index
        self.getCanvasSketch(pageIndex: self.pageControl.currentPage)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [], animations: {
            self.canvas.alpha = 0.0
            
            self.view.layoutIfNeeded()
            
        }, completion: { _ in
            
            //self.canvas.isHidden = true
        })
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        //self.canvas.isHidden = false
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [], animations: {
            self.canvas.alpha = 1.0
            
            self.view.layoutIfNeeded()
            
        }, completion: { _ in
            
            
            
        })
    }
    
    func fatalErrorAlert(_ msg: String){
        
        let errorAlert = UIAlertController(title: localizedString().localized(value:"Whoops!"), message: localizedString().localized(value:"\(msg)"), preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        errorAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        // show the alert
        self.present(errorAlert, animated: true, completion: nil)
        
    }
    
    @IBAction func closeButton(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
    }
}
