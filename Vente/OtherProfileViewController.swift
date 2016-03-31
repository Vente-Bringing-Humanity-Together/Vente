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
    
    @IBOutlet weak var optionSegmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        doDatabaseQuery()
    }
    
    @IBAction func optionSegmentedControlChanged(sender: AnyObject) {
    }
    
    func doDatabaseQuery() {
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
                
                if (PFUser.currentUser()?["following"] != nil) {
                    if (self.thisUser?.objectId != nil) {
                        if (PFUser.currentUser()!["following"].containsObject((self.thisUser?.objectId)!)) {
                            self.followButton.setTitle("Unfollow", forState: .Normal)
                        }
                    }
                }
                
            }
        }

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
                        self.follow = results[0]
                        
                        self.followersArray.append((me?.objectId)!)
                        self.follow["followers"] = self.followersArray
                        
                        self.follow.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                            if (error != nil) {
                                print(error?.description)
                            }
                            else {
                                if (self.thisUser?["followers"] != nil) {
                                    print("the other user's followers: \(self.thisUser!["followers"])")
                                }
                            }
                        })
                    } else {
                        print("No results returned")
                    }
                }
            }
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
                        print("this user is following: \(PFUser.currentUser()!["following"])")
                    }
                    
                    self.followButton.setTitle("Follow", forState: .Normal)
                }
            })
            
            let query = PFQuery(className: "Followers")
            query.whereKey("creatorId", equalTo: personID)
            query.findObjectsInBackgroundWithBlock { (results: [PFObject]?, error: NSError?) -> Void in
                if let error = error {
                    print("Error: \(error)")
                } else {
                    if let results = results {
                        self.follow = results[0]
                        
                        self.followersArray.removeObject((self.thisUser?.objectId)!)
                        self.follow["followers"] = self.followersArray
                        
                        self.follow.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                            if (error != nil) {
                                print(error?.description)
                            }
                            else {
                                if (self.thisUser?["followers"] != nil) {
                                    print("the other user's followers: \(self.thisUser!["followers"])")
                                }
                            }
                        })
                    } else {
                        print("No results returned")
                    }
                }
            }
        }
        
    }
}
