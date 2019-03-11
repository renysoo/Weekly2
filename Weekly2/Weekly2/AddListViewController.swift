//
//  AddListViewController.swift
//  Weekly2
//
//  Created by René Melo de Lucena on 27/02/19.
//  Copyright © 2019 René Melo de Lucena. All rights reserved.
//

import UIKit
import CloudKit

protocol AddListViewControllerDelegate {
    func controller(controller: AddListViewController, didAddList list: CKRecord)
    func controller(controller: AddListViewController, didUpdateList list: CKRecord)
}

class AddListViewController: UIViewController{
    
    var delegate: AddListViewControllerDelegate?
    var newList: Bool = true
    var list: CKRecord?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupView()
        
        // Update Helper
        self.newList = self.list == nil
        
        // Add Observer
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(AddListViewController.textFieldTextDidChange(notification:)), name: UITextField.textDidChangeNotification, object: nameTextField)
    }
    
    private func setupView() {
        updateNameTextField()
        updateSaveButton()
    }
    
    // MARK: -
    private func updateNameTextField() {
        if let name = list?.object(forKey: "name") as? String {
            nameTextField.text = name
        }
    }
    
    // MARK: -
    private func updateSaveButton() {
        let text = nameTextField.text
        
        if let name = text {
            saveButton.isEnabled = !name.isEmpty
        } else {
            saveButton.isEnabled = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        nameTextField.becomeFirstResponder()
    }
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBAction func cancel(sender: AnyObject) {
         self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(sender: AnyObject) {
        // Helpers
        let name = self.nameTextField.text! as NSString
        
        // Fetch Private Database
        let privateDatabase = CKContainer.default().privateCloudDatabase
        
        if list == nil {
            list = CKRecord(recordType: "Lists")
        }
        
        // Configure Record
        list?.setObject(name, forKey: "name")
        
        // Save Record
        privateDatabase.save(list!) { (record, error) -> Void in
            DispatchQueue.main.sync {
                
                // Process Response
                self.processResponse(record: record, error: error)
            }
            
        }
    }
    
    @objc func textFieldTextDidChange(notification: NSNotification) {
        updateSaveButton()
    }
    
    private func processResponse(record: CKRecord?, error: Error?) {
        var message = ""
        
        if let error = error {
            print(error)
            message = "We were not able to save your list."
            
        } else if record == nil {
            message = "We were not able to save your list."
        }
        
        if !message.isEmpty {
            // Initialize Alert Controller
            let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            
            // Present Alert Controller
            present(alertController, animated: true, completion: nil)
            
        } else {
            // Notify Delegate
            if newList {
                delegate?.controller(controller: self, didAddList: list!)
            } else {
                delegate?.controller(controller: self, didUpdateList: list!)
            }
            
            // Pop View Controller
            self.dismiss(animated: true, completion: nil)
            
        }
    }
}
