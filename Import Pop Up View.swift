//
//  Import Pop Up View.swift
//  
//
//  Created by Greg Brooks on 2019-03-05.
//

import UIKit
import Realm
import RealmSwift

class Import_Pop_Up_View: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var Popupview: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    var fileNamesArray: [String] = [String]()
    var selectedFileNamesArray: [String] = [String]()
    var limit: String = "5"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        // Apply radius to Popupview
        Popupview.layer.cornerRadius = 10
        Popupview.layer.masksToBounds = true
        fileCollection()
        
    }
    
    func fileCollection(){
        
        let fileManager = FileManager.default
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
        let documentsPath = documentsUrl.path
        
        do {
            if let documentPath = documentsPath
            {
                let fileNames = try fileManager.contentsOfDirectory(atPath: "\(documentPath)")
                print("all files in cache: \(fileNames)")
                for fileName in fileNames {
                    
                    if (fileName.hasSuffix(".csv"))
                    {
                        let filePathName = "\(documentPath)/\(fileName)"
                        fileNamesArray.append(fileName)
                    }
                }
                
                let files = try fileManager.contentsOfDirectory(atPath: "\(documentPath)")
                print("all files in cache after deleting CSV files: \(files)")
            }
            
        } catch {
            print("Could not clear document directory folder: \(error)")
        }
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        self.performSegue(withIdentifier: "cancelButtonSegue", sender: nil);
    }
    
    @IBAction func importButton(_ sender: Any) {
        self.performSegue(withIdentifier: "importButtonSegue", sender: nil);
    }
    // Returns count of items in tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.fileNamesArray.count;
    }
    
    
    // Select item from tableView
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let sr = tableView.indexPathsForSelectedRows {
            if (sr.count > Int(limit)! ){
                
                let alertController = UIAlertController(title: "Oops", message:
                    "No More than \(limit) File Selctions at a Time", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in
                    print(indexPath)
                // deselect ectra row
                tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCell.AccessoryType.none
                tableView.deselectRow(at: indexPath, animated: true)
                // remove deselected file names
                    self.selectedFileNamesArray = self.selectedFileNamesArray.filter(){$0 != self.fileNamesArray[indexPath.row]}
    
                }))
                self.present(alertController, animated: true, completion: nil)
                print("More than 4 items were selcted!")
                
            }
        }
        if tableView.cellForRow(at: indexPath)?.accessoryType == UITableViewCell.AccessoryType.checkmark
        {
            tableView.deselectRow(at: indexPath, animated: true)
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCell.AccessoryType.none
            
            // remove deselected file names
            selectedFileNamesArray = selectedFileNamesArray.filter(){$0 != fileNamesArray[indexPath.row]}
        }
        else
        {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCell.AccessoryType.checkmark
            // get selected file names
            selectedFileNamesArray.append(fileNamesArray[indexPath.row])
        }
        print("File Name : " + fileNamesArray[indexPath.row])
        print("Files Added to Array: ", selectedFileNamesArray)
    }
    
    //Assign values for tableView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = fileNamesArray[indexPath.row]
        
        return cell
    }


}
