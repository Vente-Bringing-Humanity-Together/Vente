//
//  CreateEventViewController.swift
//  Vente
//
//  Created by Alexandra Munoz on 3/9/16.
//  Copyright © 2016 nickbryanmiller. All rights reserved.
//

import UIKit
import Parse
import MaterialControls
import MapKit
import HUD

let userDidPostEventNotification = "userDidPostEventNotification"

class CreateEventViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIScrollViewDelegate, MDCalendarDelegate, MDCalendarTimePickerDialogDelegate {
    
    var businesses: [Business]!
    var filteredData: [Business]?
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var lastSearched: String = ""
    var isFirstTime: Bool = true
    
    let vc = UIImagePickerController()

    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet weak var uploadImageButton: UIButton!
    @IBOutlet weak var eventNameLabel: UITextField!
    @IBOutlet weak var eventLocationLabel: UITextField!
    @IBOutlet weak var eventImageView: UIImageView!
    
    @IBOutlet weak var publicSegmentedControl: UISegmentedControl!
    
    let creator = PFUser.currentUser()!.objectId! as String
    var attendeeList: [String] = []
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var fooddrinkSwitch: UISwitch!
    @IBOutlet weak var entertainmentSwitch: UISwitch!
    @IBOutlet weak var sportsSwitch: UISwitch!
    @IBOutlet weak var chillSwitch: UISwitch!
    @IBOutlet weak var musicSwitch: UISwitch!
    @IBOutlet weak var academicSwitch: UISwitch!
    @IBOutlet weak var nightlifeSwitch: UISwitch!
    @IBOutlet weak var adventureSwitch: UISwitch!
    
    @IBOutlet weak var yelpView: UIView!
    @IBOutlet weak var yelpTableView: UITableView!
    @IBOutlet weak var yelpSearchBar: UISearchBar!
    
    var bumpEvent: PFObject?
    
    @IBOutlet weak var createEventButton: UIButton!
    
    let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
    var blurEffectView: UIVisualEffectView?
    
    let dateFrame = CGRect(x: 35, y: 115, width: 250, height: 339)
    let timeFrame = CGRect(x: 10, y: 115, width: 300, height: 400)
    
    var datePicker: MDDatePicker?
    var timePicker: MDTimePickerDialog?
    
    var myDate = NSDate()
    var myDateStr = ""
    var myTimeStr = ""
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(bumpEvent != nil){
            bumpInit()
        }
        
        createEventButton.enabled = true
        let cellNib = UINib(nibName: "YelpTableViewCell", bundle: NSBundle.mainBundle())
        yelpTableView.registerNib(cellNib, forCellReuseIdentifier: "YelpTableViewCell")
        
        self.yelpView.hidden = true
        
        searchBar.delegate = self
        yelpTableView.delegate = self
        yelpTableView.dataSource = self
        
        yelpView.backgroundColor = UIColor(red: 0.95, green: 0.6, blue: 0.6, alpha: 1.0)
        yelpView.clipsToBounds = true
        yelpView.layer.cornerRadius = 15
        
//        yelpTableView.rowHeight = UITableViewAutomaticDimension
//        yelpTableView.estimatedRowHeight = 120
        
        vc.delegate = self
        vc.allowsEditing = true
        
        if (!UIImagePickerController.isSourceTypeAvailable(.Camera)){
            takePhotoButton.enabled = false
        }
        if (!UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary)){
            uploadImageButton.enabled = false
        }
        
        scrollView.delegate = self
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: 1000)
        //setAttributes()
        
        let createBarButton = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: #selector(CreateEventViewController.createBarButtonTouched))
        
        self.navigationItem.rightBarButtonItem = createBarButton
        
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.barTintColor = UIColor(red: 0.88, green: 0.58, blue: 0.38, alpha: 1.0)
            navigationBar.backgroundColor = UIColor.whiteColor()
            navigationBar.tintColor = UIColor.whiteColor()
            
            self.navigationItem.title = "Create"
            
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
            tabBar.tintColor = UIColor(red: 0.88, green: 0.58, blue: 0.38, alpha: 1.0)
        }
        
        datePicker = MDDatePicker(frame: dateFrame)
        datePicker!.delegate = self
        view.addSubview(datePicker!)
        datePicker?.hidden = true
        
        timePicker = MDTimePickerDialog()
        timePicker!.frame = timeFrame
        timePicker!.delegate = self
        view.addSubview(timePicker!)
        timePicker?.hidden = true
    }
    
    func bumpInit(){
        eventNameLabel.text = bumpEvent!["event_name"] as? String
        descriptionTextField.text = bumpEvent!["event_description"] as? String
        chillSwitch.on = (bumpEvent!["chill"] as? Bool)!
        fooddrinkSwitch.on = (bumpEvent!["fooddrink"] as? Bool)!
        adventureSwitch.on = (bumpEvent!["adventure"] as? Bool)!
        academicSwitch.on = (bumpEvent!["academic"] as? Bool)!
        entertainmentSwitch.on = (bumpEvent!["entertainment"] as? Bool)!
        sportsSwitch.on = (bumpEvent!["sports"] as? Bool)!
        musicSwitch.on = (bumpEvent!["music"] as? Bool)!
        nightlifeSwitch.on = (bumpEvent!["nightlife"] as? Bool)!
        if(!(bumpEvent!["public"] as! Bool)){
            publicSegmentedControl.selectedSegmentIndex = 1
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        //print(businesses!.count)
        
        if businesses != nil {
            return filteredData!.count;
        }
        else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("YelpTableViewCell", forIndexPath: indexPath) as! YelpTableViewCell
        
        cell.business = filteredData![indexPath.row]
        cell.backgroundColor = UIColor(red: 0.7, green: 0.2, blue: 0.2, alpha: 0.05)
        
        return cell
    }
    
    @IBAction func onClickYelp(sender: AnyObject) {
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        let blurEffectViewSize = CGSize(width: scrollView.frame.width, height: 1180)
        let start = CGPoint(x: 0.0, y: 0.0)
        blurEffectView?.frame = CGRect(origin: start, size: blurEffectViewSize)
        blurEffectView?.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        scrollView.addSubview(blurEffectView!)
        
        self.yelpView?.hidden = false
        self.view.bringSubviewToFront(yelpView)
//        yelpView.center.y = scrollView.contentOffset.y + 305
//        yelpView.center.x = scrollView.contentOffset.x + 160
        
        self.yelpView.center.y = scrollView.contentOffset.y + 915
        
        UIView.animateWithDuration(0.5, animations: {
            
            self.yelpView.center.y = self.scrollView.contentOffset.y + 305
            self.yelpView.center.x = self.scrollView.contentOffset.x + 160
            
            self.view.bringSubviewToFront(self.yelpView)
            }, completion: { animationFinished in
        })
    }
    
    @IBAction func onClickDone(sender: AnyObject) {
        
        UIView.animateWithDuration(0.5, animations: {
            
            self.yelpView.center.y = self.scrollView.contentOffset.y + 915
            self.yelpView.center.x = self.scrollView.contentOffset.x + 160
            
            self.view.bringSubviewToFront(self.yelpView)
            }, completion: { animationFinished in
                self.blurEffectView?.removeFromSuperview()
                self.yelpView.hidden = true
        })
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        UIView.animateWithDuration(0.5, animations: {
            
            self.yelpView.center.y = self.scrollView.contentOffset.y + 915
            self.yelpView.center.x = self.scrollView.contentOffset.x + 160
            
            self.view.bringSubviewToFront(self.yelpView)
            }, completion: { animationFinished in
                self.blurEffectView?.removeFromSuperview()
                self.eventLocationLabel.text = self.filteredData![indexPath.row].address
                if (self.filteredData![indexPath.row].imageURL != nil) {
                    self.eventImageView.setImageWithURL(self.filteredData![indexPath.row].imageURL!)
                }
                self.yelpView.hidden = true
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createBarButtonTouched() {
        createEvent("")
    }
    
    @IBAction func createEvent(sender: AnyObject) {
        if(eventNameLabel.text != nil && eventLocationLabel.text != nil && eventLocationLabel.text != nil && eventNameLabel.text != "" && eventLocationLabel.text != "" && descriptionTextField.text != "" && dateLabel.text != "Event Date" && timeLabel.text != "Event Time" && eventImageView != nil) {
            
            HUD.show(.loading, text: "Saving...")
            
            self.createEventButton.enabled = false
            let event = PFObject(className: "Events")
        
            let formatter2 = NSDateFormatter()
            formatter2.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
            let finalDateStr = myDateStr + " " + myTimeStr
            let finalDate = formatter2.dateFromString(finalDateStr)
            if(finalDate != nil) {
                event["event_date"] = finalDate!
            }
            
            event["creator"] = creator
            event["event_name"] = eventNameLabel.text
            event["event_location"] = eventLocationLabel.text
            event["event_description"] = descriptionTextField.text
        
            //Event tags
            event["fooddrink"] = fooddrinkSwitch.on
            event["entertainment"] = entertainmentSwitch.on
            event["sports"] = sportsSwitch.on
            event["chill"] = chillSwitch.on
            event["academic"] = academicSwitch.on
            event["music"] = musicSwitch.on
            event["nightlife"] = nightlifeSwitch.on
            event["adventure"] = adventureSwitch.on
        
            if (eventImageView.image != nil) {
            let userMedia = UserMedia()
                event["event_image"] = userMedia.getPFFileFromImage(eventImageView.image)
            }
        
            // Want creator first
            attendeeList.insert(creator, atIndex: 0)
            event["attendee_list"] = attendeeList
        
            if (publicSegmentedControl.selectedSegmentIndex == 0) {
                event["public"] = true
            }
            else {
                event["public"] = false
            }
        
            let location = eventLocationLabel.text
            let geocoder: CLGeocoder = CLGeocoder()
            
            
            geocoder.geocodeAddressString(location!, completionHandler: {(placemarks: [CLPlacemark]?, error: NSError?) -> Void in
                if (error == nil) {
            
                    if (placemarks != nil) {
                        let topResult = (placemarks![0])
                
                        let lat = "\(topResult.location!.coordinate.latitude)"
                        let lon = "\(topResult.location!.coordinate.longitude)"
                    
                        event["latitude"] = lat
                        event["longitude"] = lon
                        
                        event.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                            
                            HUD.dismiss()
                            
                            if let error = error {
                                print("Event Add Failed")
                                print(error.localizedDescription)
                                self.createEventButton.enabled = true
                                
                            } else {
                                print("Added Event Successfully")
                                self.navigationController?.popViewControllerAnimated(true)
                            }
                            
                        }
                        
                    }
                }
                else {
                    print(error?.localizedDescription)
                    
                    // save with no latitude or longitude
                    event.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                        if let error = error {
                            print("Event Add Failed")
                            print(error.localizedDescription)
                            self.createEventButton.enabled = true
                            
                        } else {
                            print("Added Event Successfully")
                            //NSNotificationCenter.defaultCenter().postNotificationName(userDidPostEventNotification, object: nil)
                            self.navigationController?.popViewControllerAnimated(true)
                        }
                        
                    }
                }
            })
        }
        else if(eventNameLabel.text == "" || eventNameLabel.text == nil){
            let alertController = UIAlertController(title: "Missing Event Name", message: "", preferredStyle: .Alert)
            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            }
            alertController.addAction(OKAction)
            self.presentViewController(alertController, animated: true) {
            }
        }
        else if(eventLocationLabel.text == "" || eventLocationLabel.text == nil){
            let alertController = UIAlertController(title: "Missing Event Location", message: "", preferredStyle: .Alert)
            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            }
            alertController.addAction(OKAction)
            self.presentViewController(alertController, animated: true) {
            }
        }
        else if(descriptionTextField.text == "" || descriptionTextField.text == nil){
            let alertController = UIAlertController(title: "Missing Event Description", message: "", preferredStyle: .Alert)
            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            }
            alertController.addAction(OKAction)
            self.presentViewController(alertController, animated: true) {
            }
        }
        else if(dateLabel.text == "Event Date"){
            let alertController = UIAlertController(title: "Missing Event Date", message: "", preferredStyle: .Alert)
            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            }
            alertController.addAction(OKAction)
            self.presentViewController(alertController, animated: true) {
            }
        }
        else if(timeLabel.text == "Event Time"){
            let alertController = UIAlertController(title: "Missing Event Time", message: "", preferredStyle: .Alert)
            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            }
            alertController.addAction(OKAction)
            self.presentViewController(alertController, animated: true) {
            }
        }
        else if(eventImageView == nil){
            let alertController = UIAlertController(title: "Missing Event Picture", message: "", preferredStyle: .Alert)
            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            }
            alertController.addAction(OKAction)
            self.presentViewController(alertController, animated: true) {
            }
        }
    }
    
    func callYelpAPI(input: String) {
        if(self.eventLocationLabel.text != nil){
            self.eventLocationLabel.text = input
        }
        Business.searchWithTerm(input, completion: { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            self.filteredData = businesses
            self.yelpTableView.reloadData()
        })
    
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        callYelpAPI(searchBar.text!)
        yelpTableView.reloadData()
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        filteredData = businesses
        self.yelpTableView.reloadData()
    }
    
    @IBAction func onEditingChanged(sender: AnyObject) {
        //callYelpAPI(eventLocationLabel.text!)
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String){
//        callYelpAPI(searchBar.text!)
    }
    
    @IBAction func InviteFriendsButtonTouched(sender: AnyObject) {
        let inviteFriendsViewController = InviteFriendsViewController()
        
        // Closures :)
        inviteFriendsViewController.onDataAvailable = {[weak self]
            (data: [String]) in
            self!.attendeeList = data
            print(self!.attendeeList)
        }
        
        self.navigationController?.pushViewController(inviteFriendsViewController, animated: true)
        
        inviteFriendsViewController.friendsToInvite = self.attendeeList
        
    }
    
    func showImagePicker() {
        self.presentViewController(vc, animated: true, completion: nil)
    }

    @IBAction func takePhotoButtonTouched(sender: AnyObject) {
        vc.sourceType = UIImagePickerControllerSourceType.Camera
        showImagePicker()
    }
    @IBAction func uploadImageButtonTouched(sender: AnyObject) {
        vc.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        showImagePicker()
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
            
            //            let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
            let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
            //            let resizedImage = resize(editedImage, newSize: CGSize(width: 100, height: 200))
            eventImageView.image = editedImage
            dismissViewControllerAnimated(true, completion: nil)
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    @IBAction func eventDateButtonTouched(sender: AnyObject) {
        
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        let blurEffectViewSize = CGSize(width: scrollView.frame.width, height: 1180)
        let start = CGPoint(x: 0.0, y: 0.0)
        blurEffectView?.frame = CGRect(origin: start, size: blurEffectViewSize)
        blurEffectView?.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        scrollView.addSubview(blurEffectView!)
        
        self.datePicker?.hidden = false
        self.view.bringSubviewToFront(datePicker!)
        
        self.datePicker?.center.y = scrollView.contentOffset.y + 915
        
        UIView.animateWithDuration(0.5, animations: {
            
            self.datePicker?.center.y = 290
            self.datePicker?.center.x = 160
            
            self.view.bringSubviewToFront(self.datePicker!)
            }, completion: { animationFinished in
        })

    }
    
    @IBAction func eventTimeButtonTouched(sender: AnyObject) {
        
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        let blurEffectViewSize = CGSize(width: scrollView.frame.width, height: 1180)
        let start = CGPoint(x: 0.0, y: 0.0)
        blurEffectView?.frame = CGRect(origin: start, size: blurEffectViewSize)
        blurEffectView?.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        scrollView.addSubview(blurEffectView!)
        
        self.timePicker?.hidden = false
        self.view.bringSubviewToFront(timePicker!)
        
        self.timePicker?.center.y = scrollView.contentOffset.y + 915
        
        UIView.animateWithDuration(0.5, animations: {
            
            self.timePicker?.center.y = 290
            self.timePicker?.center.x = 160
            
            self.view.bringSubviewToFront(self.timePicker!)
            }, completion: { animationFinished in
        })
    }
    
    func calendar(calendar: MDCalendar!, didSelectDate date: NSDate!) {
        
        UIView.animateWithDuration(0.5, animations: {
            
            self.datePicker?.center.y = self.scrollView.contentOffset.y + 915
            self.datePicker?.center.x = self.scrollView.contentOffset.x + 160
            
            }, completion: { animationFinished in
                self.blurEffectView?.removeFromSuperview()
                self.datePicker?.hidden = true
                
                self.myDate = date
                
                self.myDateStr = ""
                self.myDateStr = self.myDateStr + "\(self.myDate.mdYear)"
                if (self.myDate.mdMonth > 9) {
                    self.myDateStr = self.myDateStr + "-" + "\(self.myDate.mdMonth)"
                }
                else {
                    self.myDateStr = self.myDateStr + "-" + "0\(self.myDate.mdMonth)"
                }
                if (self.myDate.mdDay > 9) {
                    self.myDateStr = self.myDateStr + "-" + "\(self.myDate.mdDay)"
                }
                else {
                    self.myDateStr = self.myDateStr + "-" + "0\(self.myDate.mdDay)"
                }
                
                self.dateLabel.text = "\(self.myDate.mdMonth)/\(self.myDate.mdDay)/\(self.myDate.mdYear)"
                self.dateLabel.textAlignment = .Center
        })
    }
    
    func timePickerDialog(timePickerDialog: MDTimePickerDialog!, didSelectHour hour: Int, andMinute minute: Int) {
        
        let timePicker = MDTimePickerDialog(hour: hour, andWithMinute: minute)
        timePicker.frame = timeFrame
        timePicker.delegate = self
        timePicker.hidden = false
        timePicker.center.y = 290
        timePicker.center.x = 160
        view.addSubview(timePicker)
        
        UIView.animateWithDuration(0.5, animations: {
            
            timePicker.center.y = self.scrollView.contentOffset.y + 915
            timePicker.center.x = self.scrollView.contentOffset.x + 160
            
            }, completion: { animationFinished in
                self.blurEffectView?.removeFromSuperview()
                timePicker.hidden = true
                
                self.myTimeStr = ""
                
                if (hour > 9) {
                    self.myTimeStr = self.myTimeStr + "\(hour)"
                }
                else {
                    self.myTimeStr = self.myTimeStr + "0\(hour)"
                }
                if (minute > 9) {
                    self.myTimeStr = self.myTimeStr + ":" + "\(minute)"
                }
                else {
                    self.myTimeStr = self.myTimeStr + ":" + "0\(minute)"
                }

                self.myTimeStr = self.myTimeStr + ":00"
                
                if (hour > 12) {
                    self.timeLabel.text = "\(hour - 12):\(minute) PM"
                }
                else {
                    self.timeLabel.text = "\(hour):\(minute) AM"
                }
                self.timeLabel.textAlignment = .Center
        })
    }
    
}
