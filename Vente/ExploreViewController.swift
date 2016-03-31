//
//  ExploreViewController.swift
//  Vente
//
//  Created by Alexandra Munoz on 3/8/16.
//  Copyright © 2016 nickbryanmiller. All rights reserved.
//

import UIKit
import Parse

class ExploreViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var eventsTableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var events: [PFObject]!
    var filteredEvents: [PFObject]?
    
    var locationManager = CLLocationManager()
    var location: CLLocation!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.eventsTableView.dataSource = self
        self.eventsTableView.delegate = self
        //        self.eventsTableView.estimatedRowHeight = 150
        //        self.eventsTableView.rowHeight = UITableViewAutomaticDimension
        
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            print("Location Successful")
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            location = nil
        } else {
            print("No location")
        }
        
        searchBar.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        doDatabaseQuery()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func doDatabaseQuery() {
        let radiusVal = defaults.integerForKey("distanceSlider")
        let radius: CLLocationDistance = Double(radiusVal)
        
        let query = PFQuery(className: "Events")
        query.orderByDescending("createdAt")
        query.limit = 20
        query.whereKey("public", notEqualTo: false)
        
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
        
        query.findObjectsInBackgroundWithBlock { (results: [PFObject]?, error: NSError?) -> Void in
            if let error = error {
                print("Error: \(error)")
            } else {
                if let results = results {
                    print("Successfully retrieved \(results.count) ventes")
                    self.events = results
                    self.filteredEvents = self.events
                    
                    for event in self.filteredEvents!{
                        let eventLat = event["latitude"].doubleValue as CLLocationDegrees
                        let eventLong = event["longitude"].doubleValue as CLLocationDegrees
                        
                        let eventLocation = CLLocation(latitude: eventLat, longitude: eventLong)
                        let distanceFromEvent: CLLocationDistance = self.location.distanceFromLocation(eventLocation)
                        
                        if(distanceFromEvent > radius){
                            self.filteredEvents?.removeObject(event)
                        }
                    }
                    
                    self.eventsTableView.reloadData()
                } else {
                    print("No results returned")
                }
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let latestLocation: AnyObject = locations[locations.count - 1]
        
        if location == nil {
            location = latestLocation as! CLLocation
        }
    }

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        if (self.filteredEvents != nil) {
            return self.filteredEvents!.count
        }
        else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = eventsTableView.dequeueReusableCellWithIdentifier("ExploreTableViewCell") as! ExploreTableViewCell
        
        cell.Event = filteredEvents![indexPath.row]
        
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
        
//        let event = events![indexPath.row]
        let event = filteredEvents![indexPath.row]
        
        eventDetailsViewController.event = event
        
        self.navigationController?.pushViewController(eventDetailsViewController, animated: true)
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        filteredEvents = events
        self.eventsTableView.reloadData()
    }
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        //let resultPredicate = NSPredicate(format: "name contains[c] %@", searchText)
        filteredEvents = searchText.isEmpty ? events : events!.filter {
            $0["event_name"]!.containsString(searchText)
        }
        
        eventsTableView.reloadData()
    }
    
    @IBAction func addEvent(sender: AnyObject) {
        let createEventViewController = CreateEventViewController()
        self.navigationController?.pushViewController(createEventViewController, animated: true)
    }
    
    @IBAction func settingsButtonTouched(sender: AnyObject) {
        let settingsViewController = SettingsViewController()
//        self.navigationController?.presentViewController(settingsViewController, animated: true, completion: { 
//            print("success")
//        })
        self.navigationController?.pushViewController(settingsViewController, animated: true)
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
