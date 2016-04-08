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
import Material

class ExploreViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var eventsTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var events: [PFObject]!
    var filteredEvents: [PFObject]?
    
    var locationManager = CLLocationManager()
    var myGlobalLocation: CLLocation!
    
    var attendeeList : [String]!
    
    @IBOutlet weak var subView1: UIView!
    
    @IBOutlet weak var tagsSwitch: UISwitch!
    @IBOutlet weak var distanceSwitch: UISwitch!
    
    @IBOutlet weak var distanceView: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    // Tag Switches
    @IBOutlet weak var foodDrinkSwitch: UISwitch!
    @IBOutlet weak var entertainmentSwitch: UISwitch!
    @IBOutlet weak var sportsSwitch: UISwitch!
    @IBOutlet weak var chillSwitch: UISwitch!
    @IBOutlet weak var musicSwitch: UISwitch!
    @IBOutlet weak var academicSwitch: UISwitch!
    @IBOutlet weak var nightlifeSwitch: UISwitch!
    @IBOutlet weak var adventureSwitch: UISwitch!
    
    @IBOutlet weak var distanceSlider: UISlider!
    
    @IBOutlet weak var doneButton: UIButton!
    
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
        } else {
            print("No location")
        }
        
        searchBar.delegate = self
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 200
        locationManager.requestWhenInUseAuthorization()
        
        scrollView.contentSize = CGSize(width: 2 * scrollView.frame.width, height: scrollView.frame.height)
        scrollView.hidden = true
        
        subView1.hidden = true
        distanceView.hidden = true
        
        setSwitches()
                
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.barTintColor = UIColor(red: 132/255, green: 87/255, blue: 48/255, alpha: 1.0)
            navigationBar.backgroundColor = UIColor.whiteColor()
            navigationBar.tintColor = UIColor.whiteColor()
            
            self.navigationItem.title = "Explore"
            
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
        super.viewWillAppear(true)
        
        // Grab our current location from the defaults
        let defaults = NSUserDefaults.standardUserDefaults()
        
        let latitude = defaults.objectForKey("user_latitude") as? String
        let longitude = defaults.objectForKey("user_longitude") as? String
        
        if (latitude != nil && longitude != nil) {
            myGlobalLocation = CLLocation(latitude: Double(latitude!)!, longitude: Double(longitude!)!)
            doDatabaseQuery()
        }

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
            
            myGlobalLocation = location
            
            defaults.synchronize()
            doDatabaseQuery()
        }
    }
    
    func doDatabaseQuery() {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        let radiusVal = defaults.integerForKey("distanceSlider")
        let radius: CLLocationDistance = Double(radiusVal)
        
        let query = PFQuery(className: "Events")
        query.limit = 20
        query.whereKey("public", notEqualTo: false)
        // This needs to be the date of the event
        let calendar = NSCalendar.currentCalendar()
        // Probably should be -0
        let today = calendar.dateByAddingUnit(.Day, value: -0, toDate: NSDate(), options: [])
        query.whereKey("event_date", greaterThanOrEqualTo: today!)
        
//        if (defaults.integerForKey("fooddrinkSwitch") == 1) {
//            query.whereKey("fooddrink", equalTo: true)
//        }
        if (defaults.integerForKey("foodDrinkSwitch") == 1) {
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
                    self.events = results
                    self.filteredEvents = self.events
                    
                    for event in self.filteredEvents!{
                        var eventLat = 37.785771 as CLLocationDegrees
                        var eventLong = -122.406165 as CLLocationDegrees
                        if (event["latitude"] != nil && event["longitude"] != nil){
                            eventLat = event["latitude"].doubleValue as CLLocationDegrees
                            eventLong = event["longitude"].doubleValue as CLLocationDegrees
                        }
                        let userLocation = self.myGlobalLocation
                        
                        let eventLocation = CLLocation(latitude: eventLat, longitude: eventLong)
                        let distanceFromEvent: CLLocationDistance = userLocation!.distanceFromLocation(eventLocation)
                        
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
        return 1
        
//        if (self.filteredEvents != nil) {
//            return self.filteredEvents!.count
//        }
//        else {
//            return 0
//        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = eventsTableView.dequeueReusableCellWithIdentifier("ExploreTableViewCell") as! ExploreTableViewCell
        
        cell.Event = filteredEvents![indexPath.section]
        
        if (events?[indexPath.section]["event_image"] != nil) {
            let userImageFile = events?[indexPath.section]["event_image"] as! PFFile
            userImageFile.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError?) -> Void in
                if let error = error {
                    print(error.localizedDescription)
                }
                else {
                    if(imageData != nil){
                        let image = UIImage(data: imageData!)
                        
//                        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
//                        let blurEffectView = UIVisualEffectView(effect: blurEffect)
//                        blurEffectView.frame = cell.eventImageView.bounds
//                        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
//                        cell.eventImageView.addSubview(blurEffectView)

                        cell.eventImageView.image = image
//                        cell.eventImageView.image = self.applyBlurEffect2(image!)
                    }
                }
            })
        }
        
        cell.backgroundColor = UIColor(red: 121/255, green: 183/255, blue: 145/255, alpha: 1.0)
        
        if (events[indexPath.section]["attendee_list"].containsObject((PFUser.currentUser()?.objectId)!)) {
            cell.joinButton.select()
        }
        else {
            cell.joinButton.deselect()
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
    
        self.attendeeList = self.filteredEvents![indexPath.section]["attendee_list"] as! [String]
        
        let join = UITableViewRowAction(style: .Normal, title: "  Join  ") { action, index in
            print("join button tapped")
            
            let query = PFQuery(className: "Events")
            let eventID = self.filteredEvents![indexPath.section].objectId
            query.whereKey("objectId", equalTo: eventID!)

            query.findObjectsInBackgroundWithBlock { (results: [PFObject]?, error: NSError?) -> Void in
                if let error = error {
                    print("Error: \(error)")
                } else {
                    if let results = results {
                        print("Successfully retrieved \(results.count) ventes")
                        self.events[indexPath.section] = results[0]
                        self.filteredEvents = self.events
                        
                        self.attendeeList = self.filteredEvents![indexPath.section]["attendee_list"] as! [String]
                        
                        if self.attendeeList.contains((PFUser.currentUser()?.objectId)!) {
                            print("already joined")
                            tableView.setEditing(false, animated: true)
                        }
                        else {
                            
                            self.attendeeList.append(PFUser.currentUser()!.objectId! as String)
                            
                            let query = PFQuery(className:"Events")
                            query.getObjectInBackgroundWithId(self.filteredEvents![indexPath.section].objectId!) {
                                (event: PFObject?, error: NSError?) -> Void in
                                if error != nil {
                                    print(error)
                                } else if let event = event {
                                    event["attendee_list"] = self.attendeeList
                                    event.saveInBackground()
                                    tableView.setEditing(false, animated: true)
                                    let cell = tableView.cellForRowAtIndexPath(indexPath) as? ExploreTableViewCell
                                    cell!.animateJoin()
                                }
                            }
                        }
                        
                    } else {
                        print("No results returned")
                    }
                }
            }
        }
        join.backgroundColor = UIColor(red: 121/255, green: 183/255, blue: 145/255, alpha: 1.0)
        
        return[join]
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        subView1.hidden = true
        distanceView.hidden = true
        self.scrollView.hidden = true
        view.endEditing(true)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        view.endEditing(true)
        
        let eventDetailsViewController = EventsDetailViewController()
        
//        let event = events![indexPath.section]
        let event = filteredEvents![indexPath.section]
        
        eventDetailsViewController.event = event
        
        self.navigationController?.pushViewController(eventDetailsViewController, animated: true)
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func applyBlurEffect(image: UIImage) -> UIImage {
        let imageToBlur = CIImage(image: image)
        let blurfilter = CIFilter(name: "CIGaussianBlur")
        blurfilter!.setValue(imageToBlur, forKey: "inputImage")
        let resultImage = blurfilter!.valueForKey("outputImage") as! CIImage
        let blurredImage = UIImage(CIImage: resultImage)
        return blurredImage
    }
    
    func applyBlurEffect2(image: UIImage) -> UIImage {
        let imageToBlur = CIImage(image: image)
        let blurfilter = CIFilter(name: "CIGaussianBlur")
        blurfilter!.setValue(5, forKey: kCIInputRadiusKey)
        blurfilter!.setValue(imageToBlur, forKey: "inputImage")
        let resultImage = blurfilter!.valueForKey("outputImage") as! CIImage
        var blurredImage = UIImage(CIImage: resultImage)
        let cropped:CIImage=resultImage.imageByCroppingToRect(CGRectMake(0, 0,imageToBlur!.extent.size.width, imageToBlur!.extent.size.height))
        blurredImage = UIImage(CIImage: cropped)
        return blurredImage
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
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    @IBAction func addEvent(sender: AnyObject) {
        let createEventViewController = CreateEventViewController()
        self.navigationController?.pushViewController(createEventViewController, animated: true)
    }
    
//    @IBAction func settingsButtonTouched(sender: AnyObject) {
//        let settingsViewController = SettingsViewController()
//        
//        settingsViewController.fromExplore = true
//        self.navigationController?.pushViewController(settingsViewController, animated: true)
//    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! UITableViewCell
        let indexPath = eventsTableView.indexPathForCell(cell)
        let event = events![indexPath!.row]
        
        let detailViewController = segue.destinationViewController as! EventsDetailViewController
        detailViewController.event = event
        print(event)
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        
        subView1.hidden = false
        subView1.alpha = 0.0
        
        self.view.bringSubviewToFront(subView1)
        
        UIView.animateWithDuration(0.5, animations: {
            
            self.subView1.alpha = 1.0
            
            }, completion: { animationFinished in
        })
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        
        UIView.animateWithDuration(0.5, animations: {
            
            self.subView1.alpha = 0.0
            
            }, completion: { animationFinished in
                self.subView1.hidden = true
                self.scrollView.hidden = true
                self.distanceView.hidden = true
                
                self.tagsSwitch.on = false
                self.distanceSwitch.on = false
        })
        
    }
    
    @IBAction func doneButtonTouched(sender: AnyObject) {
        // animate the views back
        
        if tagsSwitch.on {
            UIView.animateWithDuration(0.5, animations: {
                
                self.scrollView.alpha = 0.0
                
                }, completion: { animationFinished in
                    self.scrollView.hidden = false
                    
                    UIView.animateWithDuration(0.5, animations: {
                        
                        self.subView1.alpha = 0.0
                        
                        }, completion: { animationFinished in
                            self.subView1.hidden = true
                            
                            self.distanceSwitch.on = false
                            self.tagsSwitch.on = false
                            
                            self.searchBar.resignFirstResponder()
                    })
            })
            
        }
        else if distanceSwitch.on {
            UIView.animateWithDuration(0.5, animations: {
                
                self.distanceView.alpha = 0.0
                
                }, completion: { animationFinished in
                    self.distanceView.hidden = true
                    
                    UIView.animateWithDuration(0.5, animations: {
                        
                        self.subView1.alpha = 0.0
                        
                        }, completion: { animationFinished in
                            self.subView1.hidden = true
                            
                            self.distanceSwitch.on = false
                            self.tagsSwitch.on = false
                            
                            self.searchBar.resignFirstResponder()
                    })
                    
            })
            
        }
            
        else {
            UIView.animateWithDuration(0.5, animations: {
                
                self.subView1.alpha = 0.0
                
                }, completion: { animationFinished in
                    self.subView1.hidden = true
                    
                    self.distanceSwitch.on = false
                    self.tagsSwitch.on = false
                    
                    self.searchBar.resignFirstResponder()
            })
        }
        
        // save to defaults everything
        setUserDefaults()
        // reload the table
        searchTags()
    }
    
    
    @IBAction func tagsSwitchToggled(sender: AnyObject) {
        if (tagsSwitch.on) {
            
            UIView.animateWithDuration(0.5, animations: {
                
                self.distanceView.alpha = 0.0
                self.distanceSwitch.on = false
                
                }, completion: { animationFinished in
                    self.distanceView.hidden = true
            })
            
            scrollView.hidden = false
            scrollView.alpha = 0.0
            
            UIView.animateWithDuration(0.5, animations: {
                
                self.scrollView.alpha = 1.0
                
                }, completion: { animationFinished in
            })
        }
            
        else {
            UIView.animateWithDuration(0.5, animations: {
                
                self.scrollView.alpha = 0.0
                
                }, completion: { animationFinished in
                    self.scrollView.hidden = false
            })
        }
    }
    
    @IBAction func distanceSwitchToggled(sender: AnyObject) {
        if (distanceSwitch.on) {
            
            UIView.animateWithDuration(0.5, animations: {
                
                self.scrollView.alpha = 0.0
                
                self.tagsSwitch.on = false
                
                }, completion: { animationFinished in
                    self.scrollView.hidden = true
            })
            
            distanceView.hidden = false
            distanceView.alpha = 0.0
            
            self.view.bringSubviewToFront(distanceView)
            
            UIView.animateWithDuration(0.5, animations: {
                
                self.distanceView.alpha = 1.0
                
                }, completion: { animationFinished in
            })
        }
            
        else {
            UIView.animateWithDuration(0.5, animations: {
                
                self.distanceView.alpha = 0.0
                
                }, completion: { animationFinished in
                    self.distanceView.hidden = true
            })
        }
    }
    
    @IBAction func clearTagsTouched(sender: AnyObject) {
        foodDrinkSwitch.on = false
        entertainmentSwitch.on = false
        sportsSwitch.on = false
        chillSwitch.on = false
        academicSwitch.on = false
        musicSwitch.on = false
        nightlifeSwitch.on = false
        adventureSwitch.on = false
        distanceSlider.value = 10
        
        tagsSwitch.on = false
        scrollView.hidden = true
        distanceSwitch.on = false
        distanceView.hidden = true
        setUserDefaults()
        
        filteredEvents = events
        eventsTableView.reloadData()
    }
    
    func setSwitches() {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        distanceSlider.value = defaults.floatForKey("distanceSlider")
        
        if (defaults.integerForKey("foodDrinkSwitch") == 1) {
            foodDrinkSwitch.on = true
        }
        if (defaults.integerForKey("entertainmentSwitch") == 1) {
            entertainmentSwitch.on = true
        }
        if (defaults.integerForKey("sportsSwitch") == 1) {
            sportsSwitch.on = true
        }
        if (defaults.integerForKey("chillSwitch") == 1) {
            chillSwitch.on = true
        }
        if (defaults.integerForKey("academicSwitch") == 1) {
            academicSwitch.on = true
        }
        if (defaults.integerForKey("musicSwitch") == 1) {
            musicSwitch.on = true
        }
        if (defaults.integerForKey("nightlifeSwitch") == 1) {
            nightlifeSwitch.on = true
        }
        if (defaults.integerForKey("adventureSwitch") == 1) {
            adventureSwitch.on = true
        }
    }
    
    func setUserDefaults() {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        defaults.setFloat(distanceSlider.value, forKey: "distanceSlider")
        
        if (foodDrinkSwitch.on) {
            defaults.setInteger(1, forKey: "foodDrinkSwitch")
        }
        else if (!foodDrinkSwitch.on) {
            defaults.setInteger(0, forKey: "foodDrinkSwitch")
        }
        
        if (entertainmentSwitch.on) {
            defaults.setInteger(1, forKey: "entertainmentSwitch")
        }
        else if (!entertainmentSwitch.on) {
            defaults.setInteger(0, forKey: "entertainmentSwitch")
        }
        
        if (sportsSwitch.on) {
            defaults.setInteger(1, forKey: "sportsSwitch")
        }
        else if (!sportsSwitch.on) {
            defaults.setInteger(0, forKey: "sportsSwitch")
        }
        
        if (chillSwitch.on) {
            defaults.setInteger(1, forKey: "chillSwitch")
        }
        else if (!chillSwitch.on) {
            defaults.setInteger(0, forKey: "chillSwitch")
        }
        
        if (academicSwitch.on) {
            defaults.setInteger(1, forKey: "academicSwitch")
        }
        else if (!academicSwitch.on) {
            defaults.setInteger(0, forKey: "academicSwitch")
        }
        
        if (musicSwitch.on) {
            defaults.setInteger(1, forKey: "musicSwitch")
        }
        else if (!musicSwitch.on) {
            defaults.setInteger(0, forKey: "musicSwitch")
        }
        
        if (nightlifeSwitch.on) {
            defaults.setInteger(1, forKey: "nightlifeSwitch")
        }
        else if (!nightlifeSwitch.on) {
            defaults.setInteger(0, forKey: "nightlifeSwitch")
        }
        
        if (adventureSwitch.on) {
            defaults.setInteger(1, forKey: "adventureSwitch")
        }
        else if (!adventureSwitch.on) {
            defaults.setInteger(0, forKey: "adventureSwitch")
        }
        
        defaults.synchronize()
    }
    
    func searchTags() {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if (defaults.integerForKey("foodDrinkSwitch") == 1) {
            filteredEvents = events!.filter {
                $0["fooddrink"]!.isEqual(true)
            }
        }
        if (defaults.integerForKey("entertainmentSwitch") == 1) {
            filteredEvents = events!.filter {
                $0["entertainment"]!.isEqual(true)
            }
        }
        if (defaults.integerForKey("sportsSwitch") == 1) {
            filteredEvents = events!.filter {
                $0["sports"]!.isEqual(true)
            }
        }
        if (defaults.integerForKey("chillSwitch") == 1) {
            filteredEvents = events!.filter {
                $0["chill"]!.isEqual(true)
            }
        }
        if (defaults.integerForKey("academicSwitch") == 1) {
            filteredEvents = events!.filter {
                $0["academic"]!.isEqual(true)
            }
        }
        if (defaults.integerForKey("musicSwitch") == 1) {
            filteredEvents = events!.filter {
                $0["music"]!.isEqual(true)
            }
        }
        if (defaults.integerForKey("nightlifeSwitch") == 1) {
            filteredEvents = events!.filter {
                $0["nightlife"]!.isEqual(true)
            }
        }
        if (defaults.integerForKey("adventureSwitch") == 1) {
            filteredEvents = events!.filter {
                $0["adventure"]!.isEqual(true)
            }
        }
        
        if (defaults.integerForKey("foodDrinkSwitch") == 0 && defaults.integerForKey("entertainmentSwitch") == 0 && defaults.integerForKey("sportsSwitch") == 0 && defaults.integerForKey("chillSwitch") == 0 && defaults.integerForKey("academicSwitch") == 0 && defaults.integerForKey("musicSwitch") == 0 && defaults.integerForKey("nightlifeSwitch") == 0 && defaults.integerForKey("adventureSwitch") == 0 && defaults.integerForKey("distanceSlider") == 10) {
            
            filteredEvents = events
        }
        else if (defaults.integerForKey("distanceSlider") != 10) {
            doDatabaseQuery()
        }
        
        print(defaults.integerForKey("distanceSlider"))
        
        eventsTableView.reloadData()
        
        
    }


}
