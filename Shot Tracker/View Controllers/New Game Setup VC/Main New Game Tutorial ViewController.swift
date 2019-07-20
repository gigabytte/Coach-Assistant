//
//  Main New Game Tutorial ViewController.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-07-20.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class Main_New_Game_Tutorial_ViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    let realm = try! Realm()
    var pageControl = UIPageControl()
    
    // MARK: UIPageViewControllerDataSource
    
    lazy var orderedViewControllers: [UIViewController] = {
        return [self.newVc(viewController: "first_newgame"),
                self.newVc(viewController: "second_newgame"), self.newVc(viewController: "third_newgame"), self.newVc(viewController: "fourth_newgame")]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.dataSource = self
        self.delegate = self
        
        newVc(viewController: "first_newgame").view.frame(forAlignmentRect: self.view.frame)
        newVc(viewController: "second_newgame").view.frame(forAlignmentRect: self.view.frame)
        newVc(viewController: "third_newgame").view.frame(forAlignmentRect: self.view.frame)
        newVc(viewController: "fourth_newgame").view.frame(forAlignmentRect: self.view.frame)
        
        // This sets up the first view that will show up on our page control
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
        
        configurePageControl()
        
    }
    
    func configurePageControl() {
        // The total number of pages that are available is based on how many available colors we have.
        pageControl = UIPageControl(frame: CGRect(x: 0,y: UIScreen.main.bounds.width / 2,width: UIScreen.main.bounds.width,height: 50))
        self.pageControl.numberOfPages = orderedViewControllers.count
        self.pageControl.currentPage = 0
        self.pageControl.tintColor = UIColor.black
        self.pageControl.pageIndicatorTintColor = UIColor.lightGray
        self.pageControl.currentPageIndicatorTintColor = UIColor.black
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
        let className = String(describing: New_Game_Tutorial_Shot_View_Controller.self)
        print(className)
        //if (className == "Initial_Setup_Team_Add_View_Controlle"{
        //  return orderedViewControllers[viewControllerIndex]
        //}else{
        return orderedViewControllers[nextIndex]
        //}
    }
    
    
}
