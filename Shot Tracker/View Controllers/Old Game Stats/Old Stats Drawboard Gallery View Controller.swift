//
//  Old Stats Drawboard Gallery View Controller.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-09-07.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit

class Old_Stats_Drawboard_Gallery_View_Controller: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var iceSurfaceImageArray: [UIImage] = [UIImage]()
    
    var currentImage: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        scrollView.frame = subView.frame
        // Do any additional setup after loading the view.
        onLoad()
    }
    
    func onLoad(){
        iceSurfaceImageArray.append(UIImage(named: "ice_rink")!)
        iceSurfaceImageArray.append(UIImage(named: "ice_rink")!)
        
        scrollViewProperties()
        
        pageControl.numberOfPages = iceSurfaceImageArray.count
        
    }


    
    func scrollViewProperties(){
        for i in 0..<iceSurfaceImageArray.count{
            let imageView = UIImageView()
            imageView.image = iceSurfaceImageArray[i]
            imageView.contentMode = .scaleAspectFit
            let xPosition = self.subView.frame.width * CGFloat(i)
            imageView.frame = CGRect(x: xPosition, y: 0, width: self.scrollView.frame.width, height: self.scrollView.frame.height)
            
            scrollView.contentSize.width = scrollView.frame.width * CGFloat(i + 1)
            scrollView.addSubview(imageView)
        }
    }
    

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
       
        pageControl.currentPage = Int(scrollView.contentOffset.x / scrollView.bounds.size.width)
    }
    
    @IBAction func closeButton(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
    }
}
