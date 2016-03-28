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
    
    @IBOutlet weak var followButton: UIButton!
    
    var followingArray: [String]! = []
    var followersArray: [String]! = []
    var follow: PFObject!
    
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
                
//                print("the other user's followers: \(self.thisUser?["followers"])")
//                print("this user is following: \(PFUser.currentUser()?["following"])")
                
//                if (PFUser.currentUser()?["following"].containsObject((self.thisUser?.objectId)!) == true) {
//                    self.followButton.setTitle("Unfollow", forState: .Normal)
//                }
                
                if (PFUser.currentUser()?["following"] != nil) {
                    if (self.thisUser?.objectId != nil) {
                        if (PFUser.currentUser()!["following"].containsObject((self.thisUser?.objectId)!)) {
                            self.followButton.setTitle("Unfollow", forState: .Normal)
                        }
                    }
                }
                
//                print(self.thisUser?.objectId)
                
            }
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onFollow(sender: AnyObject) {
        
        let me = PFUser.currentUser()
        
//        // Cannot save another user for security reasons because they are not logged in
//        followersArray.append((me?.objectId)!)
//        thisUser!["followers"] = followersArray
//        thisUser?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
//            if (error != nil) {
//                print(error?.description)
//            }
//            else {
//                if (self.thisUser?["followers"] != nil) {
//                    print("the other user's followers: \(self.thisUser!["followers"])")
//                }
//            }
//        })
        
        if (followButton.titleForState(.Normal) == "Follow") {
            followingArray = me!["following"] as? [String]
            if (followingArray == nil) {
                followingArray = []
            }
            followingArray.append((thisUser?.objectId)!)
            me!["following"] = followingArray
            me?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                if (error != nil) {
                    print(error?.description)
                }
                else {
                    if (me?["following"] != nil) {
                        print("this user is following: \(PFUser.currentUser()!["following"])")
                    }
                    
                    self.followButton.setTitle("Unfollow", forState: .Normal)
                }
            })
            
            let query = PFQuery(className: "Followers")
            query.whereKey("creatorId", equalTo: personID)
            query.findObjectsInBackgroundWithBlock { (results: [PFObject]?, error: NSError?) -> Void in
                if let error = error {
                    print("Error: \(error)")
                } else {
                    if let results = results {
                        print("Successfully retrieved \(results.count) ventes")
                        self.follow = results[0]
                    } else {
                        print("No results returned")
                    }
                }
            }
            
            followersArray.append((me?.objectId)!)
            follow["followers"] = followersArray
            
            follow.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                if (error != nil) {
                    print(error?.description)
                }
                else {
                    if (self.thisUser?["followers"] != nil) {
                        print("the other user's followers: \(self.thisUser!["followers"])")
                    }
                }
            })
        }
            
        else if (followButton.titleForState(.Normal) == "Unfollow") {
            followingArray = me!["following"] as? [String]
            followingArray.removeObject((thisUser?.objectId)!)
            me!["following"] = followingArray
            
            me?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                if (error != nil) {
                    print(error?.description)
                }
                else {
                    if (me?["following"] != nil) {
                        print("this user is unfollowing: \(PFUser.currentUser()!["following"])")
                    }
                    
                    self.followButton.setTitle("Follow", forState: .Normal)
                }
            })
        }
        
    }
}
