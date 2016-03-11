//
//  SecondViewController.swift
//  Example
//
//  Created by Alexander Schuch on 01/03/16.
//  Copyright © 2016 Alexander Schuch. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {
    
    @IBOutlet var dynamicLabel: UILabel?
    @IBOutlet var dynamicLabel2: UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()

        dynamicLabel?.text = NSLocalizedString("secondViewController.dynamicLabel.text", value: "First Dynamic Label Text", comment: "First dynamic text, should be short")
        dynamicLabel2?.text = NSLocalizedString("secondViewController.dynamicLabel2.text", value: "Second Dynamic Label Text", comment: "Second dynamic text, can be longer")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
