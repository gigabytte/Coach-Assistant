//
//  Initial_Setup_Page_Controller.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-04-22.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class Initial_Setup_Page_Controller: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource  {
    
    @IBAction func unwindBackToSetup(segue: UIStoryboardSegue) {}
    
    var pageControl = UIPageControl()
        
        // MARK: UIPageViewControllerDataSource
        
        lazy var orderedViewControllers: [UIViewController] = {
            return [self.newVc(viewController: "welcomePage_InitialSetupVC"),
                    self.newVc(viewController: "addHomeTeam_InitialSetupVC"), self.newVc(viewController: "addAwayTeam_InitialSetupVC"), self.newVc(viewController: "addPlayers_InitialSetupVC"), self.newVc(viewController: "helpGuide_InitialSetupVC"),
                        self.newVc(viewController: "finishSetup_InitialSetupVC")]
        }()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
             NotificationCenter.default.addObserver(self, selector: #selector(myMethod(notification:)), name: NSNotification.Name(rawValue: "initialSetupPageMover"), object: nil)
            
            // get Realm Databse file location
            print(Realm.Configuration.defaultConfiguration.fileURL!)
            
            self.dataSource = self
            self.delegate = self
            
            // This sets up the first view that will show up on our page control
            if let firstViewController = orderedViewControllers.first {
                setViewControllers([firstViewController],
                                   direction: .forward,
                                   animated: true,
                                   completion: nil)
            }
            
            configurePageControl()
            
        }
    
        @objc func myMethod(notification: NSNotification){
            print("hi")
            
            // set page controler index based on lisener value heard
            switch notification.userInfo?["sideNumber"] as? Int {
            case 2:
                print("Turned to Add Away Team")
                self.setViewControllers([orderedViewControllers[2]], direction: .forward, animated: true, completion: nil)
                pageControl.currentPage = 2
                break
            case 3:
                print("Turned to Add Players Page")
                self.setViewControllers([orderedViewControllers[3]], direction: .forward, animated: true, completion: nil)
               pageControl.currentPage = 3
                break
            case 4:
                print("Turned to Help Guide Gif Page")
                self.setViewControllers([orderedViewControllers[4]], direction: .forward, animated: true, completion: nil)
               pageControl.currentPage = 4
                break
            case 5:
                print("Turned to FInish Page")
                self.setViewControllers([orderedViewControllers[5]], direction: .forward, animated: true, completion: nil)
                pageControl.currentPage = 5
                break
            default:
                print("Page turning error retudred to start")
                self.setViewControllers([orderedViewControllers[0]], direction: .forward, animated: true, completion: nil)
                pageControl.currentPage = 0
                break
            }
            
        }
        
        func configurePageControl() {
            // The total number of pages that are available is based on how many available colors we have.
            pageControl = UIPageControl(frame: CGRect(x: 0,y: UIScreen.main.bounds.maxY - 50,width: UIScreen.main.bounds.width,height: 50))
            self.pageControl.numberOfPages = orderedViewControllers.count
            self.pageControl.currentPage = 0
            self.pageControl.tintColor = UIColor.black
            self.pageControl.pageIndicatorTintColor = UIColor.lightGray
            self.pageControl.currentPageIndicatorTintColor = UIColor.black
            self.pageControl.isUserInteractionEnabled = false
            self.view.addSubview(pageControl)
        }
        
        func newVc(viewController: String) -> UIViewController {
            return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: viewController)
        }
        
        
        // MARK: Delegate methords
        func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
            
            let pageContentViewController = pageViewController.viewControllers![0]
            self.pageControl.currentPage = orderedViewControllers.firstIndex(of: pageContentViewController)!
        }
        
        // MARK: Data source functions.
        func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
            guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
                return nil
            }
            
            let previousIndex = viewControllerIndex - 1
            
            // User is on the first view controller and swiped left to loop to
            // the last view controller.
            guard previousIndex >= 0 else {
                //return orderedViewControllers.last
                // Uncommment the line below, remove the line above if you don't want the page control to loop.
                return nil
            }
            
            guard orderedViewControllers.count > previousIndex else {
                return nil
            }
            
            return orderedViewControllers[previousIndex]
        }
        
        func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
            guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
                return nil
            }
            var nextIndex: Int!
            var orderedViewControllersCount: Int!
            // check if user has added a player to the app
            nextIndex = viewControllerIndex + 1
            orderedViewControllersCount = orderedViewControllers.count
            
 
            // User is on the last view controller and swiped right to loop to
            // the first view controller.
            guard orderedViewControllersCount != nextIndex else {
                //return orderedViewControllers.first
                // Uncommment the line below, remove the line above if you don't want the page control to loop.
                 return nil
            }
            
            guard orderedViewControllersCount > nextIndex else {
                return nil
            }
            
            return orderedViewControllers[nextIndex]

        }
        
        
}
