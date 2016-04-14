//
//  InviteFriendsViewController.swift
//  Vente
//
//  Created by Nicholas Miller on 3/23/16.
//  Copyright © 2016 nickbryanmiller. All rights reserved.
//

import UIKit
import Parse
import Material

// So we can delete from an array based on a value
extension Array where Element: Equatable {
    mutating func removeObject(object: Element) {
        if let index = self.indexOf(object) {
            self.removeAtIndex(index)
        }
    }
    
    mutating func removeObjectsInArray(array: [Element]) {
        for object in array {
            self.removeObject(object)
        }
    }
}

class InviteFriendsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let donebutton: FlatButton = FlatButton(frame: CGRectMake(122, 474, 80, 30))
    
    @IBOutlet weak var tableView: UITableView!
    
    var followingArray: [String]?
    var friendsToInvite: [String] = []
    
    // Closures!
    var onDataAvailable : ((data: [String]) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        donebutton.setTitle("Done", forState: .Normal)
        buttonMaker(donebutton)
        donebutton.addTarget(self, action: #selector(InviteFriendsViewController.doneButtonTouched), forControlEvents: .TouchUpInside)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        let cellNib = UINib(nibName: "AttendeesTableViewCell", bundle: NSBundle.mainBundle())
        tableView.registerNib(cellNib, forCellReuseIdentifier: "AttendeesTableViewCell")
        
        let me = PFUser.currentUser()
        followingArray = me!["following"] as? [String]
//        tableView.reloadData()
        
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.barTintColor = UIColor(red: 0.88, green: 0.58, blue: 0.38, alpha: 1.0)
            navigationBar.backgroundColor = UIColor.whiteColor()
            navigationBar.tintColor = UIColor.whiteColor()
            
            self.navigationItem.title = "Invite"
            
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
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (followingArray != nil) {
            return followingArray!.count
        }
        else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AttendeesTableViewCell", forIndexPath: indexPath) as! AttendeesTableViewCell
        
        cell.accessoryType = .None
        
        let query : PFQuery = PFUser.query()!
        query.getObjectInBackgroundWithId(followingArray![indexPath.row]) {
            (user: PFObject?, error: NSError?) -> Void in
            if error != nil {
                print(error)
            } else if let user = user {
                cell.nameLabel.text = user["first_name"] as? String
                cell.lastNameLabel.text = user["last_name"] as? String
                
                if (user["profile_image"] != nil) {
                    let userImageFile = user["profile_image"] as! PFFile
                    userImageFile.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError?) -> Void in
                        if let error = error {
                            print(error.localizedDescription)
                        }
                        else {
                            let image = UIImage(data: imageData!)
                            cell.profileImageView.image = image
                        }
                    })
                }

            }
        }
        
        if (friendsToInvite.contains(followingArray![indexPath.row])) {
            cell.accessoryType = .Checkmark
        }
        
        cell.backgroundColor = UIColor(red: 0.99, green: 0.98, blue: 0.89, alpha: 1.0)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            if cell.accessoryType == .None {
                cell.accessoryType = .Checkmark
                
                if (!friendsToInvite.contains(followingArray![indexPath.row])) {
                    friendsToInvite.append(followingArray![indexPath.row])
                }
            }
            else {
                cell.accessoryType = .None
                
                if (friendsToInvite.contains(followingArray![indexPath.row])) {
                    friendsToInvite.removeObject(followingArray![indexPath.row])
                }
            }
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func buttonMaker(button: FlatButton) {
        button.titleLabel!.font = UIFont (name: "District Pro Thin", size: 13)
        button.tintColor = UIColor(red: 226/255, green: 162/255, blue: 118/225, alpha: 1.0)
        
        // Add button to UIViewController.
        view.addSubview(button)
    }
    
    func sendData(data: [String]) {
        // Send that thing back
        self.onDataAvailable?(data: data)
    }
    
    func doneButtonTouched() {
        sendData(self.friendsToInvite)
        navigationController?.popViewControllerAnimated(true)
    }
    

}
