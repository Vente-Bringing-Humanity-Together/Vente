//
//  ExploreViewController.swift
//  Vente
//
//  Created by Alexandra Munoz on 3/8/16.
//  Copyright © 2016 nickbryanmiller. All rights reserved.
//

import UIKit
import Parse

class ExploreViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var eventsTableView: UITableView!
    
    var events: [PFObject]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.eventsTableView.dataSource = self
        self.eventsTableView.delegate = self
        //        self.eventsTableView.estimatedRowHeight = 150
        //        self.eventsTableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(animated: Bool) {
        
        let query = PFQuery(className: "Events")
        query.orderByDescending("createdAt")
        query.findObjectsInBackgroundWithBlock { (results: [PFObject]?, error: NSError?) -> Void in
            if let error = error {
                print("Error: \(error)")
            } else {
                if let results = results {
                    print("Successfully retrieved \(results.count) ventes")
                    self.events = results
                    self.eventsTableView.reloadData()
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if self.events == nil{
            return 0
        }
        else{
            return self.events.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = eventsTableView.dequeueReusableCellWithIdentifier("ExploreTableViewCell") as! ExploreTableViewCell
        cell.Event = events[indexPath.row]
        
        if (events[indexPath.row]["attendee_list"].containsObject((PFUser.currentUser()?.objectId)!)) {
            cell.joinButton.enabled = false
        }
        else {
            cell.joinButton.enabled = true
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let eventDetailsViewController = EventsDetailViewController()
        self.navigationController?.pushViewController(eventDetailsViewController, animated: true)
        
        let event = events![indexPath.row]
        eventDetailsViewController.event = event
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    @IBAction func addEvent(sender: AnyObject) {
        let createEventViewController = CreateEventViewController()
        self.navigationController?.pushViewController(createEventViewController, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! UITableViewCell
        let indexPath = eventsTableView.indexPathForCell(cell)
        let event = events![indexPath!.row]
        
        let detailViewController = segue.destinationViewController as! EventsDetailViewController
        detailViewController.event = event
        print(event)
    }

}
