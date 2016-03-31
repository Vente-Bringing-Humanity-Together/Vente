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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        doDatabaseQuery()

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
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
            return UITableViewCell()
        }
        else if (optionSegmentedControl.selectedSegmentIndex == 2) {
            return UITableViewCell()
        }
        else {
            return UITableViewCell()
        }
        
    }
    
    func doDatabaseQuery() {
        let userId = PFUser.currentUser()?.objectId
        let query = PFQuery(className: "Events")
        query.limit = 20
        query.whereKey("attendee_list", equalTo: userId!)
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
        
    }
    
    @IBAction func optionSegmentedControlChanged(sender: AnyObject) {
        tableView.reloadData()
    }
    

}
