//
//  ViewController.swift
//  GoogleAnalyticsSampleSwift
//
//  Created by Phani on 11/25/15.
//  Copyright © 2015 Phani. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var trackmeLabel: UILabel!
    
    @IBOutlet weak var trackmeButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "mainView")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
        
    }
    @IBAction func trackMeButtonClick(sender: AnyObject) {
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIEvent, value: "trackMeButtionClick")

        let builder = GAIDictionaryBuilder.createEventWithCategory("ui_Event", action: "trackMeButtionClick", label: "testOne", value: 1)
        tracker.send(builder.build() as [NSObject : AnyObject])


                
    }

}

