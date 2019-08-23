//
//  Settings_About_View_Controller.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-04-27.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit

class Settings_About_View_Controller: UITableViewController {

    @IBOutlet var aboutTableView: UITableView!
    @IBOutlet weak var internalVersionNumberLabel: UILabel!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(myMethod(notification:)), name: NSNotification.Name(rawValue: "darModeToggle"), object: nil)
        // query for build for version nnumber
        if let versionNumber = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
             self.internalVersionNumberLabel.text = "Internal Version #\(versionNumber)"
        }
       tableView.tableFooterView = UIView()
        viewColour()
    }
    
    func viewColour(){
        
        self.tableView.backgroundColor = systemColour().tableViewColor()
    }
    
    @objc func myMethod(notification: NSNotification){
        viewColour()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    enum VersionError: Error {
        case invalidBundleInfo, invalidResponse
    }
    
    class LookupResult: Decodable {
        var results: [AppInfo]
    }
    
    class AppInfo: Decodable {
        var version: String
        var trackViewUrl: String
    }
    
    class AppUpdater: NSObject {
        
        private override init() {}
        static let shared = AppUpdater()
        
        func showUpdate(withConfirmation: Bool) {
            DispatchQueue.global().async {
                self.checkVersion(force : !withConfirmation)
            }
        }
        
        private  func checkVersion(force: Bool) {
            let info = Bundle.main.infoDictionary
            if let currentVersion = info?["CFBundleShortVersionString"] as? String {
                _ = getAppInfo { (info, error) in
                    if let appStoreAppVersion = info?.version{
                        if let error = error {
                            print("error getting app store version: ", error)
                            UserDefaults.standard.set("1.0", forKey: "versionNumber")
                        } else if appStoreAppVersion == currentVersion {
                            print("Already on the last app version: ",currentVersion)
                            UserDefaults.standard.set(currentVersion, forKey: "versionNumber")
                        } else {
                            print("Needs update: AppStore Version: \(appStoreAppVersion) > Current version: ",currentVersion)
                            UserDefaults.standard.set(appStoreAppVersion, forKey: "versionNumber")
                        }
                    }
                }
            }
        }
        
        private func getAppInfo(completion: @escaping (AppInfo?, Error?) -> Void) -> URLSessionDataTask? {
            guard let identifier = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String,
                let url = URL(string: "http://itunes.apple.com/lookup?bundleId=\(identifier)") else {
                    
                    DispatchQueue.main.async {
                        completion(nil, VersionError.invalidBundleInfo)
                    }
                    return nil
            }
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                do {
                    if let error = error { throw error }
                    guard let data = data else { throw VersionError.invalidResponse }
                    let result = try JSONDecoder().decode(LookupResult.self, from: data)
                    guard let info = result.results.first else { throw VersionError.invalidResponse }
                    
                    completion(info, nil)
                } catch {
                    completion(nil, error)
                }
            }
            print(url)
            task.resume()
            return task
            
        }
        
    }
    
    
    
}
extension UIViewController {
    @objc fileprivate func showAppUpdateAlert( Version : String, Force: Bool, AppURL: String) {
        let appName = Bundle.appName()
        
        let alertTitle = "New Version"
        let alertMessage = "\(appName) Version \(Version) is available on AppStore."
        
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        
        if !Force {
            let notNowButton = UIAlertAction(title: "Not Now", style: .default)
            alertController.addAction(notNowButton)
        }
        
        let updateButton = UIAlertAction(title: "Update", style: .default) { (action:UIAlertAction) in
            guard let url = URL(string: AppURL) else {
                return
            }
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
        
        alertController.addAction(updateButton)
        self.present(alertController, animated: true, completion: nil)
    }
}
extension Bundle {
    static func appName() -> String {
        guard let dictionary = Bundle.main.infoDictionary else {
            return ""
        }
        if let version : String = dictionary["CFBundleName"] as? String {
            return version
        } else {
            return ""
        }
    }
}

