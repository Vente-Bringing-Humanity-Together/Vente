//
//  ImageViewController.swift
//  Vente
//
//  Created by Nicholas Miller on 4/20/16.
//  Copyright © 2016 nickbryanmiller. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    var userImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if userImage != nil {
            photoImageView.image = userImage
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonTouched(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
