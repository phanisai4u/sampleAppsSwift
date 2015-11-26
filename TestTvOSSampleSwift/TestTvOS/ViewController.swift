//
//  ViewController.swift
//  TestTvOS
//
//  Created by Phani on 11/24/15.
//  Copyright © 2015 Phani. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
   
    

}

//MARK: UITableViewDataSource
extension ViewController : UITableViewDataSource{
    
  
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CellIdentifier", forIndexPath: indexPath) as!TVTableViewCell
        cell.textLabel?.text = "Test section \(indexPath.section), Row index \(indexPath.row)"
        cell.Labeltest.text = "Hai  \(indexPath.row) !!"
        return cell
    }
    
}
extension ViewController : UITableViewDelegate{
    //MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 150
    }
}