//
//  ViewController.swift
//  SimpleDyanmoDB
//
//  Created by Phani on 12/2/15.
//  Copyright © 2015 Phani. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var DBTableVIew: UITableView!
    var tableRows:Array<DDBTableRow>?
    var lock:NSLock?
    var lastEvaluatedKey:[NSObject : AnyObject]!
    var  doneLoading = false
    
    var needsToRefresh = false
    @IBOutlet var addBarButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableRows = []
        lock = NSLock()
        self.setupTable()
        self.title = "DynamoDB"
        getListOftablesInDb()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.needsToRefresh {
            self.refreshList(true)
            self.needsToRefresh = false
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func barButtonClick(sender: AnyObject) {
        
            
            let vc = storyboard!.instantiateViewControllerWithIdentifier("AddViewController_ID") as! AddViewController
            vc.viewType = .Insert
            navigationController?.pushViewController(vc as UIViewController, animated: true)
       
        
    }
    
    func getListOftablesInDb(){
        let dynamoDB = AWSDynamoDB.defaultDynamoDB()
        let listTableInput = AWSDynamoDBListTablesInput()
        dynamoDB.listTables(listTableInput).continueWithBlock{ (task: AWSTask!) -> AnyObject! in
            if let error = task.error {
                print("Error occurred: \(error)")
                return nil
            }
            
            let listTablesOutput = task.result as! AWSDynamoDBListTablesOutput
            
            for tableName : AnyObject in listTablesOutput.tableNames {
                print("Test:\(tableName)")
               // self.title = "TableName :\(tableName) "
                
            }
            
            return nil
        }

        
    }
    func setupTable() {
        //See if the test table exists.
        DDBDynamoDBManger.describeTable().continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task:AWSTask!) -> AnyObject! in
            
            
            
            // If the test table doesn't exist, create one.
            if (task.error != nil && task.error.domain == AWSDynamoDBErrorDomain) && (task.error.code == AWSDynamoDBErrorType.ResourceNotFound.rawValue) {
                
                self.performSegueWithIdentifier("DDBLoadingViewSegue", sender: self)
                
                return DDBDynamoDBManger.createTable() .continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task:AWSTask!) -> AnyObject! in
                    //Handle erros.
                    if ((task.error) != nil) {
                        print("Error: \(task.error)")
                        
                        
                        let alertController = UIAlertController(title: "Failed to setup a test table.", message: task.error.description, preferredStyle: UIAlertControllerStyle.Alert)
                        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: { (action:UIAlertAction) -> Void in
                        })
                        alertController.addAction(okAction)
                        
                        self.presentViewController(alertController, animated: true, completion: nil)
                        
                        
                        
                    } else {
                        self.dismissViewControllerAnimated(false, completion: nil)
                    }
                    return nil
                    
                })
            } else {
                //load table contents
                self.refreshList(true)
            }
            
            return nil
        })
    }

    
    func refreshList(startFromBeginning: Bool)  {
        if (self.lock?.tryLock() != nil) {
            if startFromBeginning {
                self.lastEvaluatedKey = nil;
                self.doneLoading = false
            }
            
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            
            let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
            let queryExpression = AWSDynamoDBScanExpression()
            queryExpression.exclusiveStartKey = self.lastEvaluatedKey
            queryExpression.limit = 20;
            dynamoDBObjectMapper.scan(DDBTableRow.self, expression: queryExpression).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task:AWSTask!) -> AnyObject! in
                
                if self.lastEvaluatedKey == nil {
                    self.tableRows?.removeAll(keepCapacity: true)
                }
                
                if task.result != nil {
                    let paginatedOutput = task.result as! AWSDynamoDBPaginatedOutput
                    for item in paginatedOutput.items as! [DDBTableRow] {
                        self.tableRows?.append(item)
                    }
                    
                    self.lastEvaluatedKey = paginatedOutput.lastEvaluatedKey
                    if paginatedOutput.lastEvaluatedKey == nil {
                        self.doneLoading = true
                    }
                }
                
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                self.DBTableVIew.reloadData()
                
                if ((task.error) != nil) {
                    print("Error: \(task.error)")
                }
                return nil
            })
        }
    }
    
    func deleteTableRow(row: DDBTableRow) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        dynamoDBObjectMapper.remove(row).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task:AWSTask!) -> AnyObject! in
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
            if ((task.error) != nil) {
                print("Error: \(task.error)")
                
                let alertController = UIAlertController(title: "Failed to delete a row.", message: task.error.description, preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: { (action:UIAlertAction) -> Void in
                })
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
                
                
            }
            return nil
        })
        
    }



}

extension ViewController: UITableViewDataSource {
    //MARK: UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableRows?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RowCell", forIndexPath: indexPath) as! RowCell
        
        if let myTableRows = self.tableRows {
            let item = myTableRows[indexPath.row]
            
            cell.artist.text = "Artist Name :\(item.Artist! as String)"
            cell.SongTitle.text = "SongTitle :\(item.SongTitle! as String)"
            
            
            if indexPath.row == myTableRows.count - 1 && !self.doneLoading {
                self.refreshList(false)
            }
        }

        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
         return 60
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            if var myTableRows = self.tableRows {
                let item = myTableRows[indexPath.row]
                self.deleteTableRow(item)
                myTableRows.removeAtIndex(indexPath.row)
                self.tableRows = myTableRows
                
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            
            
        }
    }

    
}

extension ViewController: UITableViewDelegate{
    //MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vc = storyboard!.instantiateViewControllerWithIdentifier("AddViewController_ID") as! AddViewController
        vc.viewType = .Update
        vc.tableRow = self.tableRows![indexPath.row]
        navigationController?.pushViewController(vc as UIViewController, animated: true)
        
    }
    
}

