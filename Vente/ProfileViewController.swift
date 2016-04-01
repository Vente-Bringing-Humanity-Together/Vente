//
//  ProfileViewController.swift
//  Vente
//
//  Created by Alexandra Munoz on 3/8/16.
//  Copyright © 2016 nickbryanmiller. All rights reserved.
//

import UIKit
import Parse
import FBSDKCoreKit
import FBSDKLoginKit

let userDidLogoutNotification = "userDidLogoutNotification"

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    
    @IBOutlet weak var optionSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var tableView: UITableView!
    
    var events: [PFObject]!
    var followingArray: [String]! = []
    var followerArray: [String]! = []
    var followerObject: PFObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        doDatabaseQuery()
        getUserData();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            if (self.followingArray != nil && self.followingArray != []) {
                return self.followingArray!.count
            }
            else {
                return 0
            }
        }
        else if (optionSegmentedControl.selectedSegmentIndex == 2) {
            if (self.followerArray != nil && self.followerArray != []) {
                return self.followerArray!.count
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
            let cell = tableView.dequeueReusableCellWithIdentifier("MyEventsTableViewCell") as! MyEventsTableViewCell
            
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
            let cell = tableView.dequeueReusableCellWithIdentifier("PeopleTableViewCell") as! PeopleTableViewCell
            
            let query : PFQuery = PFUser.query()!
            query.getObjectInBackgroundWithId(followingArray[indexPath.row]) {
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
            let cell = tableView.dequeueReusableCellWithIdentifier("PeopleTableViewCell") as! PeopleTableViewCell
            
            let query : PFQuery = PFUser.query()!
            query.getObjectInBackgroundWithId(followerArray[indexPath.row]) {
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
            let personID = followingArray[indexPath.row]
            otherProfileViewController.personID = personID
            
            self.navigationController?.pushViewController(otherProfileViewController, animated: true)
        }
        else if (optionSegmentedControl.selectedSegmentIndex == 2) {
            let otherProfileViewController = OtherProfileViewController()
            let personID = followingArray[indexPath.row]
            otherProfileViewController.personID = personID
            
            self.navigationController?.pushViewController(otherProfileViewController, animated: true)
        }

    }
    
    func doDatabaseQuery() {
        let userId = PFUser.currentUser()?.objectId
        let query = PFQuery(className: "Events")
        query.limit = 20
        query.whereKey("attendee_list", equalTo: userId!)
        // This needs to be the date of the event
        let calendar = NSCalendar.currentCalendar()
        // Probably should be -1
        let oneDayAgo = calendar.dateByAddingUnit(.Day, value: -0, toDate: NSDate(), options: [])
        query.whereKey("createdAt", lessThan: oneDayAgo!)
        // End of past events
        query.orderByDescending("createdAt")
        
        query.findObjectsInBackgroundWithBlock { (results: [PFObject]?, error: NSError?) -> Void in
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
        
        // Grab the followers and set it to the follower array
        let query2 = PFQuery(className: "Followers")
        query2.whereKey("creatorId", equalTo: userId!)
        query2.findObjectsInBackgroundWithBlock { (results: [PFObject]?, error: NSError?) -> Void in
            if let error = error {
                print("Error: \(error)")
            } else {
                if let results = results {
                    self.followerObject = results[0]
                    self.followerArray = self.followerObject!["followers"] as? [String]
                } else {
                    print("No results returned")
                }
            }
        }
    }
    
    @IBAction func editButtonTouched(sender: AnyObject) {
        
        let editProfileViewController = EditProfileViewController()
        self.navigationController?.pushViewController(editProfileViewController, animated: true)
        
    }
    
    @IBAction func signOutButtonTouched(sender: AnyObject) {
        
        PFUser.logOutInBackgroundWithBlock { (error: NSError?) -> Void in
            
            if let error = error {
                print(error.localizedDescription)
            }
            else {
                print("Successfuly logged out")
                let loginManager: FBSDKLoginManager = FBSDKLoginManager()
                loginManager.logOut()
                NSNotificationCenter.defaultCenter().postNotificationName(userDidLogoutNotification, object: nil)
            }
        }
    }
    
    func getUserData() {
        
        let user = PFUser.currentUser()
        
        if (user?["first_name"] != nil && user?["last_name"] != nil) {
            nameLabel.text = (user?["first_name"] as! String) + " " + ((user?["last_name"])! as! String)
        }
        if (user?.username != nil) {
            emailLabel.text = user?.username
        }
        if(user?["number"] != nil){
            numberLabel.text = user?["number"] as? String
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
        
        if (user?["following"] != nil) {
            followingArray = user?["following"] as? [String]
        }
        
    }
    
    @IBAction func optionSegmentedControlChanged(sender: AnyObject) {
        tableView.reloadData()
    }
    

}
