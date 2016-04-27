//
//  PieGraphVC.swift
//  Graphs
//
//  Created by Phani on 4/27/16.
//  Copyright © 2016 Phani. All rights reserved.
//

import UIKit

class PieGraphVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func CloseButtonClick(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }


}
