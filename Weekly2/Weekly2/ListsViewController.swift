//
//  ViewController.swift
//  Weekly2
//
//  Created by René Melo de Lucena on 26/02/19.
//  Copyright © 2019 René Melo de Lucena. All rights reserved.
//

import UIKit
import CloudKit

class ListsViewController: UIViewController, AddListViewControllerDelegate {
    func controller(controller: AddListViewController, didAddList list: CKRecord) {
        // Add List to Lists
        lists.append(list)
        
        // Sort Lists
        sortLists()
        
        // Update Table View
        listsTableView.reloadData()
        
        // Update View
        updateView()
    }
    
    func controller(controller: AddListViewController, didUpdateList list: CKRecord) {
        sortLists()
        
        // Update Table View
        listsTableView.reloadData()
    }
    
    
    @IBOutlet weak var listsTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var labelOutlet: UILabel!
    
    var lists = [CKRecord]()
    var selection: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupView()
        fetchLists()
    }
    
    func setupView(){
        listsTableView.isHidden = true
        labelOutlet.isHidden = true
        activityIndicator.startAnimating()
    }
    
    func fetchLists(){
        let privateDatabase = CKContainer.default().privateCloudDatabase
        let query = CKQuery(recordType: "Lists", predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        privateDatabase.perform(query, inZoneWith: nil) { (records, error) in
            records?.forEach({ (record) in
                
                guard error == nil else{
                    print(error?.localizedDescription as Any)
                    return
                }
                
                print(record.value(forKey: "name") ?? "")
                self.lists.append(record)
                DispatchQueue.main.sync {
                    self.listsTableView.reloadData()
                    self.labelOutlet.text = ""
                    self.updateView()
                }
            })
            
        }
    }
    
    private func sortLists() {
        self.lists.sort {
            var result = false
            let name0 = $0.object(forKey: "name") as? String
            let name1 = $1.object(forKey: "name") as? String
            
            if let listName0 = name0, let listName1 = name1 {
                result = listName0.localizedCaseInsensitiveCompare(listName1) == .orderedAscending
            }
            
            return result
        }
    }
    
    private func updateView(){
        let hasRecords = self.lists.count > 0
        
        self.listsTableView.isHidden = !hasRecords
        labelOutlet.isHidden = hasRecords
        activityIndicator.stopAnimating()
    }
    
    private func fetchUserRecordID() {
        // Fetch Default Container
        let defaultContainer = CKContainer.default()
        
        // Fetch User Record
        defaultContainer.fetchUserRecordID { (recordID, error) -> Void in
            if let responseError = error {
                print(responseError)
                
            } else if let userRecordID = recordID {
                DispatchQueue.main.sync {
                    self.fetchUserRecord(recordID: userRecordID)
                }
            }
        }
    }
    
    private func fetchUserRecord(recordID: CKRecord.ID) {
        // Fetch Default Container
        let defaultContainer = CKContainer.default()
        
        // Fetch Private Database
        let privateDatabase = defaultContainer.privateCloudDatabase
        
        // Fetch User Record
        privateDatabase.fetch(withRecordID: recordID) { (record, error) -> Void in
            if let responseError = error {
                print(responseError)
                
            } else if let userRecord = record {
                print(userRecord)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Fetch Destination View Controller
        let addListViewController = segue.destination as! AddListViewController
        
        // Configure View Controller
        addListViewController.delegate = self
        
        if let selection = selection {
            // Fetch List
            let list = lists[selection]
            
            // Configure View Controller
            addListViewController.list = list
        }
    }
    
    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier else { return }
        
        if identifier == "ListDetail" {
            // Fetch Destination View Controller
            let addListViewController = segue.destination as! AddListViewController
            
            // Configure View Controller
            addListViewController.delegate = self
            
            if let selection = selection {
                // Fetch List
                let list = lists[selection]
                
                // Configure View Controller
                addListViewController.list = list
            }
            
        }
            else {
            return
        }
    }
}

extension ListsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        // Save Selection
        selection = indexPath.row
        
        // Perform Segue
        performSegue(withIdentifier: "ListDetail", sender: self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = listsTableView.dequeueReusableCell(withIdentifier: "ListCell")
        cell?.accessoryType = .detailDisclosureButton
        let list = lists[indexPath.row]
        if let listName = list.object(forKey: "name") as? String {
            // Configure Cell
            cell?.textLabel?.text = listName
            
        } else {
            cell?.textLabel?.text = "-"
        }
        
        return cell!
    }
    
    
}
