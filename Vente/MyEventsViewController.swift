//
//  MyEventsViewController.swift
//  Vente
//
//  Created by Alexandra Munoz on 3/8/16.
//  Copyright © 2016 nickbryanmiller. All rights reserved.
//

import UIKit
import Parse

class MyEventsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var myEvents: [PFObject]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        navigationItem.leftBarButtonItem = editButtonItem()

    }
    
    override func viewWillAppear(animated: Bool) {
        getEventsFromDatabase()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if (self.myEvents == nil) {
            return 0
        }
        else {
            return self.myEvents.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("MyEventsTableViewCell") as! MyEventsTableViewCell
        cell.Event = myEvents[indexPath.row]
        return cell
    }
    
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            let userId = PFUser.currentUser()?.objectId
            
            let query = PFQuery(className:"Events")
            query.getObjectInBackgroundWithId(myEvents[indexPath.row].objectId!) {
                (event: PFObject?, error: NSError?) -> Void in
                if error != nil {
                    print(error)
                } else if let event = event {
                    event.removeObject(userId!, forKey: "attendee_list")
                    event.saveInBackground()
                    self.myEvents.removeAtIndex(indexPath.row)
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
                }
            }
        }
    }
    
    func getEventsFromDatabase() {
        print("Retrieving My Ventes from Parse...")
        
        let userId = PFUser.currentUser()?.objectId
        let query = PFQuery(className: "Events")
        
        query.whereKey("attendee_list", equalTo: userId!)
        query.orderByDescending("createdAt")
        query.findObjectsInBackgroundWithBlock { (results: [PFObject]?, error: NSError?) -> Void in
            if let error = error {
                print("Error: \(error)")
            } else {
                if let results = results {
                    print("Successfully retrieved \(results.count) ventes")
                    self.myEvents = results
                    self.tableView.reloadData()
                } else {
                    print("No results returned")
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
