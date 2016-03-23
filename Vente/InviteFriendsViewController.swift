//
//  InviteFriendsViewController.swift
//  Vente
//
//  Created by Nicholas Miller on 3/23/16.
//  Copyright © 2016 nickbryanmiller. All rights reserved.
//

import UIKit
import Parse

class InviteFriendsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var followingArray: [String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        let cellNib = UINib(nibName: "AttendeesTableViewCell", bundle: NSBundle.mainBundle())
        tableView.registerNib(cellNib, forCellReuseIdentifier: "AttendeesTableViewCell")
        
        let me = PFUser.currentUser()
        followingArray = me!["following"] as? [String]
//        tableView.reloadData()

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
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            if cell.accessoryType == .None {
                cell.accessoryType = .Checkmark
            }
            else {
                cell.accessoryType = .None
            }
        }
    }
    
    @IBAction func doneButtonTouched(sender: AnyObject) {
        
        navigationController?.popViewControllerAnimated(true)
    }
    

}
