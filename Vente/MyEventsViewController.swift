//
//  MyEventsViewController.swift
//  Vente
//
//  Created by Alexandra Munoz on 3/8/16.
//  Copyright © 2016 nickbryanmiller. All rights reserved.
//

import UIKit
import Parse

class MyEventsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var myEvents: [PFObject]!
    var filteredEvents: [PFObject]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        searchBar.delegate = self
        
//        navigationItem.leftBarButtonItem = editButtonItem()
        
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.barTintColor = UIColor(red: 132/255, green: 87/255, blue: 48/255, alpha: 1.0)
            navigationBar.backgroundColor = UIColor.whiteColor()
            navigationBar.tintColor = UIColor.whiteColor()
            
            self.navigationItem.title = "My Events"
            
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
            tabBar.tintColor = UIColor(red: 200/255, green: 159/255, blue: 124/255, alpha: 1.0)
        }

        
    }
    
    override func viewWillAppear(animated: Bool) {
//        if let navigationBar = navigationController?.navigationBar {
//            navigationBar.backgroundColor = UIColor(red: 125/255, green: 221/255, blue: 176/255, alpha: 1.0)
//            navigationBar.tintColor = UIColor(red: 132/255, green: 87/255, blue: 48/255, alpha: 0.78)
//            
//            let shadow = NSShadow()
//            shadow.shadowColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
//            shadow.shadowOffset = CGSizeMake(2, 2);
//            shadow.shadowBlurRadius = 4;
//            navigationBar.titleTextAttributes = [
//                NSFontAttributeName : UIFont.boldSystemFontOfSize(22),
//                NSForegroundColorAttributeName : UIColor(red: 132/255, green: 87/255, blue: 48/255, alpha: 0.78),
//                NSShadowAttributeName : shadow
//            ]
//        }
//        
//        if let tabBar = tabBarController?.tabBar {
//            tabBar.barTintColor = UIColor(red: 125/255, green: 221/255, blue: 176/255, alpha: 0.2)
//            tabBar.tintColor = UIColor.whiteColor()
//        }
        
        getEventsFromDatabase()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return 1
        
        if (self.filteredEvents != nil) {
            return self.filteredEvents!.count
        }
        else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
//        if (self.filteredEvents != nil) {
//            return self.filteredEvents!.count
//        }
//        else {
//            return 0
//        }
        
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("MyEventsTableViewCell") as! MyEventsTableViewCell
        
//        cell.Event = myEvents[indexPath.section]
        cell.Event = filteredEvents![indexPath.section]
        
        if (myEvents?[indexPath.section]["event_image"] != nil) {
            let userImageFile = myEvents?[indexPath.section]["event_image"] as! PFFile
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
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // Edit stuff
        
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        let leave = UITableViewRowAction(style: .Normal, title: "Leave") { action, index in
            print("leave button tapped")
            // handle delete (by removing the data from your array and updating the tableview)
            let userId = PFUser.currentUser()?.objectId
            
            let query = PFQuery(className:"Events")
            query.getObjectInBackgroundWithId(self.myEvents[indexPath.section].objectId!) {
                (event: PFObject?, error: NSError?) -> Void in
                if error != nil {
                    print(error)
                } else if let event = event {
                    event.removeObject(userId!, forKey: "attendee_list")
                    event.saveInBackground()
                    self.myEvents.removeAtIndex(indexPath.section)
                    self.filteredEvents?.removeAtIndex(indexPath.section)
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
                }
            }

        }
        leave.backgroundColor = UIColor.redColor()
        
        return [leave]
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    func getEventsFromDatabase() {
        print("Retrieving My Ventes from Parse...")
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        let userId = PFUser.currentUser()?.objectId
        let query = PFQuery(className: "Events")
        query.limit = 20
        query.whereKey("attendee_list", equalTo: userId!)
        // This needs to be the date of the event
        let calendar = NSCalendar.currentCalendar()
        // Probably should be -0
        let today = calendar.dateByAddingUnit(.Day, value: -0, toDate: NSDate(), options: [])
        query.whereKey("event_date", greaterThanOrEqualTo: today!)
        
        if (defaults.integerForKey("fooddrinkSwitch") == 1) {
            query.whereKey("fooddrink", equalTo: true)
        }
        if (defaults.integerForKey("entertainmentSwitch") == 1) {
            query.whereKey("entertainment", equalTo: true)
        }
        if (defaults.integerForKey("sportsSwitch") == 1) {
            query.whereKey("sports", equalTo: true)
        }
        if (defaults.integerForKey("chillSwitch") == 1) {
            query.whereKey("chill", equalTo: true)
        }
        if (defaults.integerForKey("academicSwitch") == 1) {
            query.whereKey("academic", equalTo: true)
        }
        if (defaults.integerForKey("musicSwitch") == 1) {
            query.whereKey("music", equalTo: true)
        }
        if (defaults.integerForKey("nightlifeSwitch") == 1) {
            query.whereKey("nightlife", equalTo: true)
        }
        if (defaults.integerForKey("adventureSwitch") == 1) {
            query.whereKey("adventure", equalTo: true)
        }
        
        query.orderByAscending("event_date")
        
        query.findObjectsInBackgroundWithBlock { (results: [PFObject]?, error: NSError?) -> Void in
            if let error = error {
                print("Error: \(error)")
            } else {
                if let results = results {
                    print("Successfully retrieved \(results.count) ventes")
                    self.myEvents = results
                    self.filteredEvents = self.myEvents
                    self.tableView.reloadData()
                } else {
                    print("No results returned")
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        view.endEditing(true)
        
        let eventDetailsViewController = EventsDetailViewController()
        
        //        let event = myEvents![indexPath.section]
        let event = filteredEvents![indexPath.section]
        
        eventDetailsViewController.event = event
        
        self.navigationController?.pushViewController(eventDetailsViewController, animated: true)
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    @IBAction func settingsButtonTouched(sender: AnyObject) {
        let settingsViewController = SettingsViewController()
        
        settingsViewController.fromExplore = false

        self.navigationController?.pushViewController(settingsViewController, animated: true)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        filteredEvents = myEvents
        self.tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        view.endEditing(true)
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        //let resultPredicate = NSPredicate(format: "name contains[c] %@", searchText)
        filteredEvents = searchText.isEmpty ? myEvents : myEvents!.filter {
            $0["event_name"]!.containsString(searchText)
        }
        
        tableView.reloadData()
    }
}
