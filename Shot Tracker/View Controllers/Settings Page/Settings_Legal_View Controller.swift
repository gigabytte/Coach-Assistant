//
//  Settings_Legal_View Controller.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-04-21.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit
import SafariServices

class Settings_Legal_View_Controller: UITableViewController, SFSafariViewControllerDelegate {

    @IBOutlet var legalTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(myMethod(notification:)), name: NSNotification.Name(rawValue: "darModeToggle"), object: nil)
        tableView.tableFooterView = UIView()
        
        viewColour()
    }
    
    func viewColour(){
        
        self.tableView.backgroundColor = systemColour().tableViewColor()
    }
    
    @objc func myMethod(notification: NSNotification){
        viewColour()
    }
    
    func safarieView(urlString: String){
        let safariVC = SFSafariViewController(url: URL(string: urlString)!)
        present(safariVC, animated: true, completion: nil)
        
        safariVC.delegate = self
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
   
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.row)!")
        switch indexPath.row {
        case 0:
            //guard let url = URL(string: universalValue().legalSupportURL) else { return }
            //UIApplication.shared.open(url)
            safarieView(urlString: universalValue().legalSupportURL)
            break
        case 1:
            //guard let url = URL(string: universalValue().helpAndSupportURL) else { return }
            //UIApplication.shared.open(url)
            safarieView(urlString: universalValue().helpAndSupportURL)
            break
        default:
           
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    
}
