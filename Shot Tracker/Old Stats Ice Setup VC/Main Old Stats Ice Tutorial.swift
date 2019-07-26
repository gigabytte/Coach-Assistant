//
//  Main Old Stats Ice Tutorial.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-07-24.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit


class Main_Old_Stats_Ice_Tutorial: UIPageViewController {

    weak var tutorialDelegate: OldIceTutorialPageViewControllerDelegate?
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        // The view controllers will be shown in this order
        return [self.newViewController("first_oldstatsice"),
                self.newViewController("second_oldstatsice"),
                self.newViewController("third_oldstatsice")]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self as UIPageViewControllerDataSource
        delegate = self as UIPageViewControllerDelegate
        
        if let initialViewController = orderedViewControllers.first {
            scrollToViewController(viewController: initialViewController)
        }
        
        tutorialDelegate?.tutorialPageViewController(tutorialPageViewController: self, didUpdatePageCount: orderedViewControllers.count)
    }
    
    /**
     Scrolls to the next view controller.
     */
    func scrollToNextViewController() {
        if let visibleViewController = viewControllers?.first,
            let nextViewController = pageViewController(self, viewControllerAfter: visibleViewController) {
            scrollToViewController(viewController: nextViewController)
        }
        print("hi")
    }
    
    /**
     Scrolls to the view controller at the given index. Automatically calculates
     the direction.
     
     - parameter newIndex: the new index to scroll to
     */
    func scrollToViewController(index newIndex: Int) {
        if let firstViewController = viewControllers?.first,
            let currentIndex = orderedViewControllers.firstIndex(of: firstViewController) {
            let direction: UIPageViewController.NavigationDirection = newIndex >= currentIndex ? .forward : .reverse
            let nextViewController = orderedViewControllers[newIndex]
            scrollToViewController(viewController: nextViewController, direction: direction)
            print("hi")
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
                            // Setting the view controller programmatically does not fire
                            // any delegate methods, so we have to manually notify the
                            // 'tutorialDelegate' of the new index.
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

extension Main_Old_Stats_Ice_Tutorial: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
            print("hi")
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
        
        return orderedViewControllers[nextIndex]
    }
    
}

extension Main_Old_Stats_Ice_Tutorial: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        notifyTutorialDelegateOfNewIndex()
    }
    
}

protocol OldIceTutorialPageViewControllerDelegate: class {
    
    
    
    func tutorialPageViewController(tutorialPageViewController: Main_Old_Stats_Ice_Tutorial,
                                    didUpdatePageCount count: Int)
    
    
    func tutorialPageViewController(tutorialPageViewController: Main_Old_Stats_Ice_Tutorial,
                                    didUpdatePageIndex index: Int)
    
}

