//
//  Add Team View Controller.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-08-30.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit

class Add_Team_View_Controller: UIViewController {

    @IBOutlet weak var pageControl: UIPageControl!
    
    
    var addTeamPageViewController: Main_Add_Team_Page_Controller_View? {
        didSet {
            addTeamPageViewController?.tutorialDelegate = self
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func closeButton(_ sender: UIButton) {
        // dismiss view controller
        self.dismiss(animated: true, completion: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let tutorialPageViewController = segue.destination as? Main_Add_Team_Page_Controller_View {
            self.addTeamPageViewController = tutorialPageViewController
        }
    }
  
}
extension Add_Team_View_Controller: AddTeamPageViewControllerDelegate {
    func tutorialPageViewController(tutorialPageViewController: Main_Add_Team_Page_Controller_View, didUpdatePageCount count: Int) {
        
        pageControl.numberOfPages = count
    }
    
    func tutorialPageViewController(tutorialPageViewController: Main_Add_Team_Page_Controller_View, didUpdatePageIndex index: Int) {
        pageControl.currentPage = index
        
    }
    
}
