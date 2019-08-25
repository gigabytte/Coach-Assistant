//
//  Locker Room UIPageController.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-08-19.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit

class Locker_Room_UIPageController: UIPageViewController {

    weak var tutorialDelegate: LockerRoomPageViewControllerDelegate?
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        // The view controllers will be shown in this order
        return [self.newViewController("lockerroom_stats_VC"),
                self.newViewController("lockerroom_old_stats_VC"),
                self.newViewController("lockerroom_add_VC")]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // listen for notification to chnage page by button press
        NotificationCenter.default.addObserver(self, selector: #selector(myMethod(notification:)), name: NSNotification.Name(rawValue: "menuBtnPress"), object: nil)
        
        dataSource = self as UIPageViewControllerDataSource
        delegate = self as UIPageViewControllerDelegate
        
        if let initialViewController = orderedViewControllers.first {
            scrollToViewController(viewController: initialViewController)
        }
        
        tutorialDelegate?.tutorialPageViewController(tutorialPageViewController: self, didUpdatePageCount: orderedViewControllers.count)
    }
    
    @objc func myMethod(notification: NSNotification){
        
        // set page controler index based on lisener value heard
        switch notification.userInfo?["btnNumber"] as? Int {
        case 0:
            print("Turned to Stats")
            self.setViewControllers([orderedViewControllers[0]], direction: .forward, animated: true, completion: nil)
            self.notifyTutorialDelegateOfNewIndex()
        case 1:
            print("Turned to Old Stats")
            self.setViewControllers([orderedViewControllers[1]], direction: .forward, animated: true, completion: nil)
            self.notifyTutorialDelegateOfNewIndex()
        case 2:
            print("Turned to Add Player")
            self.setViewControllers([orderedViewControllers[3]], direction: .forward, animated: true, completion: nil)
            self.notifyTutorialDelegateOfNewIndex()
        default:
            self.setViewControllers([orderedViewControllers[0]], direction: .forward, animated: true, completion: nil)
            self.notifyTutorialDelegateOfNewIndex()
            print("Turned to Stats")
        }
    
    }
    
    /**
     Scrolls to the next view controller.
     */
    func scrollToNextViewController() {
        if let visibleViewController = viewControllers?.first,
            let nextViewController = pageViewController(self, viewControllerAfter: visibleViewController) {
            print("hi")
            scrollToViewController(viewController: nextViewController)
        }
       
    }
    
    /**
     Scrolls to the view controller at the given index. Automatically calculates
     the direction.
     
     - parameter newIndex: the new index to scroll to
     */
    func scrollToViewController(index newIndex: Int) {
        print("hi")
        if let firstViewController = viewControllers?.first,
            let currentIndex = orderedViewControllers.firstIndex(of: firstViewController) {
            let direction: UIPageViewController.NavigationDirection = newIndex >= currentIndex ? .forward : .reverse
            let nextViewController = orderedViewControllers[newIndex]
            scrollToViewController(viewController: nextViewController, direction: direction)
           
        }
    }
    
    func newViewController(_ type: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewController(withIdentifier: "\(type)")
    }
    
    /**
     Scrolls to the given 'viewController' page.
     
     - parameter viewController: the view controller to show.
     */
    private func scrollToViewController(viewController: UIViewController,
                                        direction: UIPageViewController.NavigationDirection = .forward) {
        setViewControllers([viewController],
                           direction: direction,
                           animated: true,
                           completion: { (finished) -> Void in
                            
                            self.notifyTutorialDelegateOfNewIndex()
        })
    }
    
    /**
     Notifies '_tutorialDelegate' that the current page index was updated.
     */
    private func notifyTutorialDelegateOfNewIndex() {
        if let firstViewController = viewControllers?.first,
            let index = orderedViewControllers.firstIndex(of: firstViewController) {
            tutorialDelegate?.tutorialPageViewController(tutorialPageViewController: self, didUpdatePageIndex: index)
        }
    }
    
    
}

// MARK: UIPageViewControllerDataSource

extension Locker_Room_UIPageController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
            
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        // User is on the first view controller and swiped left to loop to
        // the last view controller.
        guard previousIndex >= 0 else {
            let previousIndex = previousIndex - 1
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            
            return nil
        }
        print("backward")
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        // User is on the last view controller and swiped right to loop to
        // the first view controller.
        guard orderedViewControllersCount != nextIndex else {
            let nextIndex = nextIndex - 1
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            
            return nil
        }
         print("forward")
        return orderedViewControllers[nextIndex]
    }
    
}

extension Locker_Room_UIPageController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        notifyTutorialDelegateOfNewIndex()
    }
    
}

protocol LockerRoomPageViewControllerDelegate: class {
    
    
    
    func tutorialPageViewController(tutorialPageViewController: Locker_Room_UIPageController,
                                    didUpdatePageCount count: Int)
    
    
    func tutorialPageViewController(tutorialPageViewController: Locker_Room_UIPageController,
                                    didUpdatePageIndex index: Int)
    
}

