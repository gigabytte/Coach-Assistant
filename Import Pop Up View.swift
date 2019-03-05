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
    
    let realm = try! Realm()
    
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
    
    func fileCollection() -> [String]{
        
        let fileManager = FileManager.default
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
        let documentsPath = documentsUrl.path
        
        do {
            if let documentPath = documentsPath
            {
                let fileNames = try fileManager.contentsOfDirectory(atPath: "\(documentPath)")
                let csvFileNames = fileNames.filter{$0.contains("Realm_")}
                print("all files in cache: \(fileNames)")
                for fileName in csvFileNames {
                    
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
        return(fileNamesArray)
    }
    
    func csvFileToStringConver() -> ([[String]], [[String]], [[String]], [[String]], [[String]]) {
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let firstDocumentPath = documentsUrl.appendingPathComponent(fileCollection()[fileCollection().firstIndex(of: "Realm_New_Game_Info_Table.csv")!])
        let secDocumentPath = documentsUrl.appendingPathComponent(fileCollection()[fileCollection().firstIndex(of: "Realm_Team_Info_Table.csv")!])
        let thirdDocumentPath = documentsUrl.appendingPathComponent(fileCollection()[fileCollection().firstIndex(of: "Realm_Player_Info_Table.csv")!])
        let fourthDocumentPath = documentsUrl.appendingPathComponent(fileCollection()[fileCollection().firstIndex(of: "Realm_Goal_Marker_Table.csv")!])
        let fifthDocumentPath = documentsUrl.appendingPathComponent(fileCollection()[fileCollection().firstIndex(of: "Realm_Shot_Marker_Table.csv")!])
        
        var firstFileContentsParsed: [[String]] = [[String]]()
        var secFileContentsParsed: [[String]] = [[String]]()
        var thirdFileContentsParsed: [[String]] = [[String]]()
        var forthFileContentsParsed: [[String]] = [[String]]()
        var fifthFileContentsParsed: [[String]] = [[String]]()
        
            do {
                firstFileContentsParsed =  (try String(contentsOf: firstDocumentPath, encoding: .utf8)).components(separatedBy: "\n").map{ $0.components(separatedBy: ",") }
                secFileContentsParsed = (try String(contentsOf: secDocumentPath, encoding: .utf8)).components(separatedBy: "\n").map{ $0.components(separatedBy: ",") }
                thirdFileContentsParsed = (try String(contentsOf: thirdDocumentPath, encoding: .utf8)).components(separatedBy: "\n").map{ $0.components(separatedBy: ",") }
                forthFileContentsParsed = (try String(contentsOf: fourthDocumentPath, encoding: .utf8)).components(separatedBy: "\n").map{ $0.components(separatedBy: ",") }
                fifthFileContentsParsed = (try String(contentsOf: fifthDocumentPath, encoding: .utf8)).components(separatedBy: "\n").map{ $0.components(separatedBy: ",") }
                print("Contents of Parsed File One: ", firstFileContentsParsed)
                print("Contents of Parsed File Two: ", secFileContentsParsed)
                // REMOVE EMPTY SPACE AT END
            } catch {
                print("Error Finding Containts of File")
        }
        return(firstFileContentsParsed, secFileContentsParsed, thirdFileContentsParsed, forthFileContentsParsed, fifthFileContentsParsed)
    }
    
    func csvStringToRealm(){
        
        try? realm.write ({
            //delete contents of DB
            realm.deleteAll()
            
            for i in 0..<csvFileToStringConver().0.count{
                // skip first row
                // loop through and check the nu ber of elemts against the first row
                // if row is lower through error
            }
            
        })

    }
    
    @IBAction func cancelButton(_ sender: Any) {
        self.performSegue(withIdentifier: "cancelButtonSegue", sender: nil);
    }
    
    @IBAction func importButton(_ sender: Any) {
        csvFileToStringConver()
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
