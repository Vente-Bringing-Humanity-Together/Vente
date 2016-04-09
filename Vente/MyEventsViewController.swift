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
    
    @IBOutlet weak var subView1: UIView!
    
    @IBOutlet weak var tagsSwitch: UISwitch!
    
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
    
    @IBOutlet weak var doneButton: UIButton!
    
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        searchBar.delegate = self
        
        scrollView.contentSize = CGSize(width: 2 * scrollView.frame.width, height: scrollView.frame.height)
        scrollView.hidden = true
        
        subView1.hidden = true
                
        setSwitches()
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(MyEventsViewController.onRefresh), forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
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
            tabBar.tintColor = UIColor(red: 132/255, green: 87/255, blue: 48/255, alpha: 1.0)
        }

        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        tableView.hidden = true
        tableView.alpha = 0.0
        
        getEventsFromDatabase()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    func onRefresh() {
        delay(2, closure: {
            self.refreshControl.endRefreshing()
        })
        
        getEventsFromDatabase()
        
        self.refreshControl?.endRefreshing()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if (self.filteredEvents != nil) {
            return self.filteredEvents!.count
        }
        else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
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
//                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
                    let path = NSIndexSet(index: indexPath.section)
                    tableView.deleteSections(path, withRowAnimation: UITableViewRowAnimation.Fade)
                }
            }

        }
        leave.backgroundColor = UIColor.redColor()
        
        return [leave]
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        subView1.hidden = true
        self.scrollView.hidden = true
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
                    
                    self.tableView.hidden = false
                    self.tableView.alpha = 0.0
                    
                    UIView.animateWithDuration(0.2, animations: {
                        
                        self.tableView.alpha = 1.0
                        
                        }, completion: { animationFinished in
                    })

                    
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
    
//    @IBAction func settingsButtonTouched(sender: AnyObject) {
//        let settingsViewController = SettingsViewController()
//        
//        settingsViewController.fromExplore = false
//
//        self.navigationController?.pushViewController(settingsViewController, animated: true)
//    }
    
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
                
                self.tagsSwitch.on = false
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
    
    @IBAction func clearTagsTouched(sender: AnyObject) {
        foodDrinkSwitch.on = false
        entertainmentSwitch.on = false
        sportsSwitch.on = false
        chillSwitch.on = false
        academicSwitch.on = false
        musicSwitch.on = false
        nightlifeSwitch.on = false
        adventureSwitch.on = false
        
        tagsSwitch.on = false
        scrollView.hidden = true
        
        setUserDefaults()
        
        filteredEvents = myEvents
        
        if tagsSwitch.on {
            UIView.animateWithDuration(0.5, animations: {
                
                self.scrollView.alpha = 0.0
                
                }, completion: { animationFinished in
                    self.scrollView.hidden = false
                    
                    UIView.animateWithDuration(0.5, animations: {
                        
                        self.subView1.alpha = 0.0
                        
                        }, completion: { animationFinished in
                            self.subView1.hidden = true
                            
                            self.tagsSwitch.on = false
                            
                            self.searchBar.resignFirstResponder()
                            
                            self.tableView.reloadData()
                    })
            })
            
        }
        else {
            UIView.animateWithDuration(0.5, animations: {
                
                self.subView1.alpha = 0.0
                
                }, completion: { animationFinished in
                    self.subView1.hidden = true
                    
                    self.tagsSwitch.on = false
                    
                    self.searchBar.resignFirstResponder()
                    
                    self.tableView.reloadData()
            })
        }
    }
    
    func setSwitches() {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
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
            filteredEvents = myEvents!.filter {
                $0["fooddrink"]!.isEqual(true)
            }
        }
        if (defaults.integerForKey("entertainmentSwitch") == 1) {
            filteredEvents = myEvents!.filter {
                $0["entertainment"]!.isEqual(true)
            }
        }
        if (defaults.integerForKey("sportsSwitch") == 1) {
            filteredEvents = myEvents!.filter {
                $0["sports"]!.isEqual(true)
            }
        }
        if (defaults.integerForKey("chillSwitch") == 1) {
            filteredEvents = myEvents!.filter {
                $0["chill"]!.isEqual(true)
            }
        }
        if (defaults.integerForKey("academicSwitch") == 1) {
            filteredEvents = myEvents!.filter {
                $0["academic"]!.isEqual(true)
            }
        }
        if (defaults.integerForKey("musicSwitch") == 1) {
            filteredEvents = myEvents!.filter {
                $0["music"]!.isEqual(true)
            }
        }
        if (defaults.integerForKey("nightlifeSwitch") == 1) {
            filteredEvents = myEvents!.filter {
                $0["nightlife"]!.isEqual(true)
            }
        }
        if (defaults.integerForKey("adventureSwitch") == 1) {
            filteredEvents = myEvents!.filter {
                $0["adventure"]!.isEqual(true)
            }
        }
        
        if (defaults.integerForKey("foodDrinkSwitch") == 0 && defaults.integerForKey("entertainmentSwitch") == 0 && defaults.integerForKey("sportsSwitch") == 0 && defaults.integerForKey("chillSwitch") == 0 && defaults.integerForKey("academicSwitch") == 0 && defaults.integerForKey("musicSwitch") == 0 && defaults.integerForKey("nightlifeSwitch") == 0 && defaults.integerForKey("adventureSwitch") == 0) {
            
            filteredEvents = myEvents
        }
        
        
        tableView.reloadData()
        
        
    }
}
