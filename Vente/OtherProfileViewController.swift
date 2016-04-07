//
//  OtherProfileViewController.swift
//  Vente
//
//  Created by Alexandra Munoz on 3/15/16.
//  Copyright © 2016 nickbryanmiller. All rights reserved.
//

import UIKit
import Parse

class OtherProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

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
    
    var events: [PFObject]!
    var tableFollowingArray: [String]! = []
    var tableFollowersArray: [String]! = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let cellNib = UINib(nibName: "PastEventsTableViewCell", bundle: NSBundle.mainBundle())
        tableView.registerNib(cellNib, forCellReuseIdentifier: "PastEventsTableViewCell")
        let cellNib2 = UINib(nibName: "XIBPeopleTableViewCell", bundle: NSBundle.mainBundle())
        tableView.registerNib(cellNib2, forCellReuseIdentifier: "XIBPeopleTableViewCell")
        
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.barTintColor = UIColor(red: 132/255, green: 87/255, blue: 48/255, alpha: 1.0)
            navigationBar.backgroundColor = UIColor.whiteColor()
            navigationBar.tintColor = UIColor.whiteColor()
            
            self.navigationItem.title = "Profile"
            
            let shadow = NSShadow()
            shadow.shadowColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
            shadow.shadowOffset = CGSizeMake(1, 1);
            shadow.shadowBlurRadius = 1;
            navigationBar.titleTextAttributes = [
                NSFontAttributeName : UIFont.boldSystemFontOfSize(22),
                NSForegroundColorAttributeName : UIColor.whiteColor(),
                NSShadowAttributeName : shadow
            ]
        }
        
        if let tabBar = tabBarController?.tabBar {
            tabBar.barTintColor = UIColor.whiteColor()
            tabBar.backgroundColor = UIColor.whiteColor()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        doDatabaseQuery()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (optionSegmentedControl.selectedSegmentIndex == 0) {
            if (self.events != nil) {
                return self.events!.count
            }
            else {
                return 0
            }
        }
        else if (optionSegmentedControl.selectedSegmentIndex == 1) {
            if (self.tableFollowingArray != nil && self.tableFollowingArray != []) {
                return self.tableFollowingArray!.count
            }
            else {
                return 0
            }
        }
        else if (optionSegmentedControl.selectedSegmentIndex == 2) {
            if (self.tableFollowersArray != nil && self.tableFollowersArray != []) {
                return self.tableFollowersArray!.count
            }
            else {
                return 0
            }
        }
        else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (optionSegmentedControl.selectedSegmentIndex == 0) {
            let cell = tableView.dequeueReusableCellWithIdentifier("PastEventsTableViewCell") as! PastEventsTableViewCell
            
            cell.Event = events[indexPath.row]
            
            if (events?[indexPath.row]["event_image"] != nil) {
                let userImageFile = events?[indexPath.row]["event_image"] as! PFFile
                userImageFile.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError?) -> Void in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                    else {
                        if(imageData != nil){
                            let image = UIImage(data: imageData!)
                            cell.eventImageView.image = image
                        }
                    }
                })
            }
            
            return cell
        }
        else if (optionSegmentedControl.selectedSegmentIndex == 1) {
            let cell = tableView.dequeueReusableCellWithIdentifier("XIBPeopleTableViewCell") as! XIBPeopleTableViewCell
            
            let query : PFQuery = PFUser.query()!
            query.getObjectInBackgroundWithId(tableFollowingArray[indexPath.row]) {
                (user: PFObject?, error: NSError?) -> Void in
                if error != nil {
                    print(error)
                } else if let user = user {
                    cell.firstNameLabel.text = user["first_name"] as? String
                    cell.lastNameLabel.text = user["last_name"] as? String
                    
                    if (user["profile_image"] != nil) {
                        let userImageFile = user["profile_image"] as! PFFile
                        userImageFile.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError?) -> Void in
                            if let error = error {
                                print(error.localizedDescription)
                            }
                            else {
                                if(imageData != nil){
                                    let image = UIImage(data: imageData!)
                                    cell.profileImageView.image = image
                                }
                            }
                        })
                    }
                }
            }
            
            return cell
        }
        else if (optionSegmentedControl.selectedSegmentIndex == 2) {
            let cell = tableView.dequeueReusableCellWithIdentifier("XIBPeopleTableViewCell") as! XIBPeopleTableViewCell
            
            let query : PFQuery = PFUser.query()!
            query.getObjectInBackgroundWithId(tableFollowersArray[indexPath.row]) {
                (user: PFObject?, error: NSError?) -> Void in
                if error != nil {
                    print(error)
                } else if let user = user {
                    cell.firstNameLabel.text = user["first_name"] as? String
                    cell.lastNameLabel.text = user["last_name"] as? String
                    
                    if (user["profile_image"] != nil) {
                        let userImageFile = user["profile_image"] as! PFFile
                        userImageFile.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError?) -> Void in
                            if let error = error {
                                print(error.localizedDescription)
                            }
                            else {
                                if(imageData != nil){
                                    let image = UIImage(data: imageData!)
                                    cell.profileImageView.image = image
                                }
                            }
                        })
                    }
                }
            }
            
            return cell
        }
        else {
            return UITableViewCell()
        }

    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (optionSegmentedControl.selectedSegmentIndex == 0) {
            let eventDetailsViewController = EventsDetailViewController()
            
            let event = events![indexPath.row]
            eventDetailsViewController.event = event
            
            self.navigationController?.pushViewController(eventDetailsViewController, animated: true)
        }
        else if (optionSegmentedControl.selectedSegmentIndex == 1) {
            let otherProfileViewController = OtherProfileViewController()
            let personID = tableFollowingArray[indexPath.row]
            otherProfileViewController.personID = personID
            
            self.navigationController?.pushViewController(otherProfileViewController, animated: true)
        }
        else if (optionSegmentedControl.selectedSegmentIndex == 2) {
            let otherProfileViewController = OtherProfileViewController()
            let personID = tableFollowersArray[indexPath.row]
            otherProfileViewController.personID = personID
            
            self.navigationController?.pushViewController(otherProfileViewController, animated: true)
        }
        
    }
    
    @IBAction func optionSegmentedControlChanged(sender: AnyObject) {
        tableView.reloadData()
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
                
                if (user?["profile_image"] != nil) {
                    let userImageFile = user?["profile_image"] as! PFFile
                    userImageFile.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError?) -> Void in
                        if let error = error {
                            print(error.localizedDescription)
                        }
                        else {
                            let image = UIImage(data: imageData!)
                            self.profileImageView.image = image
                        }
                    })
                }
                
                if (PFUser.currentUser()?["following"] != nil) {
                    if (self.thisUser?.objectId != nil) {
                        if (PFUser.currentUser()!["following"].containsObject((self.thisUser?.objectId)!)) {
                            self.followButton.setTitle("Unfollow", forState: .Normal)
                        }
                    }
                }
                
                if (user?["following"] != nil) {
                    self.tableFollowingArray = user?["following"] as? [String]
                }
                
            }
        }
        
        let query2 = PFQuery(className: "Events")
        query2.limit = 20
        query2.whereKey("attendee_list", equalTo: personID)
        // This needs to be the date of the event
        let calendar = NSCalendar.currentCalendar()
        // Probably should be -1
        let oneDayAgo = calendar.dateByAddingUnit(.Day, value: -0, toDate: NSDate(), options: [])
        query2.whereKey("event_date", lessThan: oneDayAgo!)
        // End of past events
        query2.whereKey("public", equalTo: true)
        query2.orderByDescending("event_date")
        
        query2.findObjectsInBackgroundWithBlock { (results: [PFObject]?, error: NSError?) -> Void in
            if let error = error {
                print("Error: \(error)")
            } else {
                if let results = results {
                    print("Successfully retrieved \(results.count) ventes")
                    self.events = results
                    self.tableView.reloadData()
                } else {
                    print("No results returned")
                }
            }
        }
        
        let query3 = PFQuery(className: "Followers")
        query3.whereKey("creatorId", equalTo: personID)
        query3.findObjectsInBackgroundWithBlock { (results: [PFObject]?, error: NSError?) -> Void in
            if let error = error {
                print("Error: \(error)")
            } else {
                if let results = results {
                    let followerObject = results[0]
                    self.tableFollowersArray = followerObject["followers"] as? [String]
                } else {
                    print("No results returned")
                }
            }
        }
    }
    
    @IBAction func onFollow(sender: AnyObject) {
        
        let me = PFUser.currentUser()
        
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
                        self.followersArray = self.follow["followers"] as? [String]
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
                        self.followersArray = self.follow["followers"] as? [String]
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
