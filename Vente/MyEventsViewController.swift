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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if self.myEvents == nil{
            return 0
        }
        else{
            return self.myEvents.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("MyEventsTableViewCell") as! MyEventsTableViewCell
        cell.Event = myEvents[indexPath.row]
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        getEventsFromDatabase()
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

    @IBAction func onRemove(sender: AnyObject) {
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
