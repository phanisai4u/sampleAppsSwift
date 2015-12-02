//
//  AddViewController.swift
//  SimpleDyanmoDB
//
//  Created by Phani on 12/2/15.
//  Copyright © 2015 Phani. All rights reserved.
//

import UIKit

class AddViewController: UIViewController {

    enum DDBDetailViewType {
        case Insert
        case Update
        case Unknown
    }
    var viewType:DDBDetailViewType = DDBDetailViewType.Insert
    var tableRow:DDBTableRow?
    
    var dataChanged = false
    @IBOutlet var atristTF: UITextField!
    @IBOutlet var songTf: UITextField!
    @IBOutlet var addButton: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch self.viewType {
        case DDBDetailViewType.Insert:
            self.title = "Insert"
            self.addButton.setTitle("Add", forState:.Normal)
            self.atristTF.enabled = true
            self.songTf.enabled = true
            
        case DDBDetailViewType.Update:
            self.title = "Update"
            self.atristTF.enabled = false
            self.songTf.enabled = false
            self.addButton.setTitle("Update", forState:.Normal)
            self.getTableRow()
            
        default:
            print("ERROR: Invalid viewType!")
        }

        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (self.dataChanged) {
            let c = self.navigationController?.viewControllers.count
            let mainTableViewController = self.navigationController?.viewControllers [c! - 1] as! ViewController
            mainTableViewController.needsToRefresh = true
        }
    }
    
    func getTableRow() {
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        
        dynamoDBObjectMapper .load(DDBTableRow.self, hashKey: tableRow?.Artist, rangeKey: tableRow?.SongTitle) .continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task:AWSTask!) -> AnyObject! in
            if (task.error == nil) {
                if (task.result != nil) {
                    
                    let tableRow = task.result as! DDBTableRow
                    self.atristTF.text = tableRow.Artist
                    self.songTf.text = tableRow.SongTitle
                }
            } else {
                print("Error: \(task.error)")
                let alertController = UIAlertController(title: "Failed to get item from table.", message: task.error.description, preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: { (action:UIAlertAction) -> Void in
                })
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
                
            }
            return nil
        })
    }
    
    func updateTableRow(tableRow:DDBTableRow) {
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        
        dynamoDBObjectMapper .save(tableRow) .continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task:AWSTask!) -> AnyObject! in
            if (task.error == nil) {
                let alertController = UIAlertController(title: "Succeeded", message: "Successfully updated the data into the table.", preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: { (action:UIAlertAction) -> Void in
                })
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
                
                if (self.viewType == DDBDetailViewType.Insert) {
                    self.songTf.text = nil
                    self.atristTF.text = nil
                }
                
                self.dataChanged = true
            } else {
                print("Error: \(task.error)")
                
                let alertController = UIAlertController(title: "Failed to update the data into the table.", message: task.error.description, preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: { (action:UIAlertAction) -> Void in
                })
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
            
            return nil
        })
    }

    func insertTableRow(tableRow: DDBTableRow) {
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        
        dynamoDBObjectMapper.save(tableRow) .continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task:AWSTask!) -> AnyObject! in
            if (task.error == nil) {
                let alertController = UIAlertController(title: "Succeeded", message: "Successfully inserted the data into the table.", preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: { (action:UIAlertAction) -> Void in
                })
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
                
                self.songTf.text = nil
                self.atristTF.text = nil
                self.dataChanged = true
                
            } else {
                print("Error: \(task.error)")
                
                let alertController = UIAlertController(title: "Failed to insert the data into the table.", message: task.error.description, preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: { (action:UIAlertAction) -> Void in
                })
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
            
            return nil
        })
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func AddButtonClick(sender: AnyObject) {
        let tableRow = DDBTableRow()
        tableRow.Artist = self.atristTF.text
        tableRow.SongTitle = self.songTf.text
        
        switch self.viewType {
        case DDBDetailViewType.Insert:
            if (self.atristTF.text!.utf16.count > 0) {
                self.insertTableRow(tableRow)
            } else {
                let alertController = UIAlertController(title: "Error: Invalid Input", message: "Range Key Value cannot be empty.", preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: { (action:UIAlertAction) -> Void in
                })
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        case DDBDetailViewType.Update:
            if (self.songTf.text!.utf16.count > 0) {
                self.updateTableRow(tableRow)
            } else {
                let alertController = UIAlertController(title: "Error: Invalid Input", message: "Range Key Value cannot be empty.", preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: { (action:UIAlertAction) -> Void in
                })
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        default:
            print("ERROR: Invalid viewType!")
        }
        

        
    }

    
}
