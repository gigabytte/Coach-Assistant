//
//  Initial_Setup_Container_ViewController.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-04-22.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit

class Initial_Setup_Container_ViewController: UIViewController {

    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var containerView: UIView!
    
    var tutorialPageViewController: Intial_Setup_Page_ViewController? {
        didSet {
            Intial_Setup_Page_ViewController?.tutorialDelegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pageControl.addTarget(self, action: Selector("didChangePageControlValue"), for: .valueChanged)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let tutorialPageViewController = segue.destination as? Intial_Setup_Page_ViewController {
            self.tutorialPageViewController = tutorialPageViewController
        }
    }
    
    @IBAction func didTapNextButton(_ sender: Any) {
        tutorialPageViewController?.scrollToNextViewController()
    }
    
    /**
     Fired when the user taps on the pageControl to change its current page.
     */
    func didChangePageControlValue() {
        tutorialPageViewController?.scrollToViewController(index: pageControl.currentPage)
    }
}

extension Initial_Setup_Container_ViewController: Intial_Setup_Page_ViewController {
    
    func tutorialPageViewController(tutorialPageViewController: Intial_Setup_Page_ViewController,
                                    didUpdatePageCount count: Int) {
        pageControl.numberOfPages = count
    }
    
    func tutorialPageViewController(tutorialPageViewController: Intial_Setup_Page_ViewController,
                                    didUpdatePageIndex index: Int) {
        pageControl.currentPage = index
    }


}
