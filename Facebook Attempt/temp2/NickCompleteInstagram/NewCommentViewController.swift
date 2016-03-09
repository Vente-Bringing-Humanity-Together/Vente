//
//  NewCommentViewController.swift
//  NickCompleteInstagram
//
//  Created by Nicholas Miller on 2/17/16.
//  Copyright © 2016 nickmiller. All rights reserved.
//

import UIKit

class NewCommentViewController: UIViewController {
    
    @IBOutlet weak var commentTextView: UITextView!
    var onDataAvailable : ((data: String) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func cancelButtonTouched(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func sendData(data: String) {
        self.onDataAvailable?(data: data)
    }
    
    @IBAction func postButtonTouched(sender: AnyObject) {
        if (self.commentTextView.text != "" && self.commentTextView.text != "Comment") {
            sendData(self.commentTextView.text!)
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}
