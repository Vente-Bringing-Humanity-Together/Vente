//
//  OtherProfileViewController.swift
//  Vente
//
//  Created by Alexandra Munoz on 3/15/16.
//  Copyright © 2016 nickbryanmiller. All rights reserved.
//

import UIKit
import Parse

class OtherProfileViewController: UIViewController {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    
    var personID = "";
    
    var thisUser: PFObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let query : PFQuery = PFUser.query()!
        query.getObjectInBackgroundWithId(personID) {
            (user: PFObject?, error: NSError?) -> Void in
            if error != nil {
                print(error)
            }
            else  {
                self.thisUser = user!
                if (user?["first_name"] != nil && user?["last_name"] != nil) {
                    self.nameLabel.text = (user?["first_name"] as! String) + " " + ((user?["last_name"])! as! String)
                }
                if (user?["username"] != nil) {
                    self.emailLabel.text = user!["username"] as? String
                }
                if(user?["number"] != nil){
                    self.numberLabel.text = user?["number"] as? String
                }
            }
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onFollow(sender: AnyObject) {
        let query : PFQuery = PFUser.query()!
        query.getObjectInBackgroundWithId(personID) {
            (user: PFObject?, error: NSError?) -> Void in
            if error != nil {
                print(error)
            }
            else  {
                print((PFUser.currentUser()?.objectId)!)
                user?.addUniqueObject((PFUser.currentUser()?.objectId)!, forKey: "followers")
                user?.saveInBackground()
            }
        }
    }
}
