//
//  ExploreViewController.swift
//  Vente
//
//  Created by Alexandra Munoz on 3/8/16.
//  Copyright © 2016 nickbryanmiller. All rights reserved.
//

import UIKit
import Parse
import CoreLocation

class ExploreViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, CLLocationManagerDelegate {

    var locationManager : CLLocationManager!
    
    @IBOutlet weak var eventsTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var events: [PFObject]!
    var filteredEvents: [PFObject]?
    
<<<<<<< HEAD
    var locationManager = CLLocationManager()
    var location: CLLocation!
    
    let defaults = NSUserDefaults.standardUserDefaults()
=======
    var attendeeList : [String]!
>>>>>>> 85fb001b0bb8cce3dfa0f2d531e1877b29a68412
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.eventsTableView.dataSource = self
        self.eventsTableView.delegate = self
        // self.eventsTableView.estimatedRowHeight = 150
        // self.eventsTableView.rowHeight = UITableViewAutomaticDimension
        
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
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 200
        locationManager.requestWhenInUseAuthorization()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        doDatabaseQuery()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            
            
            let latitude = location.coordinate.latitude
            let latitudeString = "\(latitude)"
            
            let longitude = location.coordinate.longitude
            let longitudeString = "\(longitude)"
            
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(latitudeString, forKey: "user_latitude")
            defaults.setObject(longitudeString, forKey: "user_longitude")
            defaults.synchronize()
        }
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
                        
                        if(distanceFromEvent > radius && radiusVal != 10){
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
        
        if (events[indexPath.row]["attendee_list"].containsObject((PFUser.currentUser()?.objectId)!)) {
            cell.backgroundColor = UIColor.greenColor()
        }
        else {
            cell.backgroundColor = UIColor.whiteColor()
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // for editing style
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
    
        self.attendeeList = self.filteredEvents![indexPath.row]["attendee_list"] as! [String]
        
        let join = UITableViewRowAction(style: .Normal, title: "  Join  ") { action, index in
            print("join button tapped")
            
            let query = PFQuery(className: "Events")
            let eventID = self.filteredEvents![indexPath.row].objectId
            query.whereKey("objectId", equalTo: eventID!)

            query.findObjectsInBackgroundWithBlock { (results: [PFObject]?, error: NSError?) -> Void in
                if let error = error {
                    print("Error: \(error)")
                } else {
                    if let results = results {
                        print("Successfully retrieved \(results.count) ventes")
                        self.events[indexPath.row] = results[0]
                        self.filteredEvents = self.events
        
                        // print(results)
                        
                        self.attendeeList = self.filteredEvents![indexPath.row]["attendee_list"] as! [String]
                        
                        if self.attendeeList.contains((PFUser.currentUser()?.objectId)!) {
                            print("already joined")
                            tableView.setEditing(false, animated: true)
                        }
                        else {
                            
                            self.attendeeList.append(PFUser.currentUser()!.objectId! as String)
                            
                            let query = PFQuery(className:"Events")
                            query.getObjectInBackgroundWithId(self.filteredEvents![indexPath.row].objectId!) {
                                (event: PFObject?, error: NSError?) -> Void in
                                if error != nil {
                                    print(error)
                                } else if let event = event {
                                    event["attendee_list"] = self.attendeeList
                                    event.saveInBackground()
                                    tableView.setEditing(false, animated: true)
                                    let cell = tableView.cellForRowAtIndexPath(indexPath) as? ExploreTableViewCell
                                    cell?.backgroundColor = UIColor.greenColor()
                                }
                            }
                        }
                        
                    } else {
                        print("No results returned")
                    }
                }
            }
        }
        join.backgroundColor = UIColor.greenColor()
        
        return[join]
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
