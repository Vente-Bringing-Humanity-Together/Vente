//
//  CreateEventViewController.swift
//  Vente
//
//  Created by Alexandra Munoz on 3/9/16.
//  Copyright © 2016 nickbryanmiller. All rights reserved.
//

import UIKit
import Parse
import MBProgressHUD

let userDidPostEventNotification = "userDidPostEventNotification"

class CreateEventViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIScrollViewDelegate {
    
    var businesses: [Business]!
    var filteredData: [Business]?
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var lastSearched: String = ""
    var isFirstTime: Bool = true
    
    let vc = UIImagePickerController()

    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet weak var uploadImageButton: UIButton!
    @IBOutlet weak var eventNameLabel: UITextField!
    @IBOutlet weak var eventLocationLabel: UITextField!
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var datePickerView: UIDatePicker? = nil
    var dateString = ""
    
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
    
    @IBOutlet weak var createEventButton: UIButton!
    
    let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
    var blurEffectView: UIVisualEffectView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createEventButton.enabled = true
        let cellNib = UINib(nibName: "YelpTableViewCell", bundle: NSBundle.mainBundle())
        yelpTableView.registerNib(cellNib, forCellReuseIdentifier: "YelpTableViewCell")
        
        self.yelpView.hidden = true
        
        searchBar.delegate = self
        yelpTableView.delegate = self
        yelpTableView.dataSource = self
        
        yelpView.backgroundColor = UIColor(red: 0.95, green: 0.6, blue: 0.6, alpha: 1.0)

        
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
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: 1180)
        //setAttributes()
        
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.barTintColor = UIColor(red: 132/255, green: 87/255, blue: 48/255, alpha: 1.0)
            navigationBar.backgroundColor = UIColor.whiteColor()
            navigationBar.tintColor = UIColor.whiteColor()
            
            self.navigationItem.title = "Create Event"
            
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
    
    @IBAction func onEditingDidBegin(sender: UITextField) {
        datePickerView = UIDatePicker()
        
        let inputView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, 240))
        
        datePickerView!.datePickerMode = UIDatePickerMode.Date
        inputView.addSubview(datePickerView!) // add date picker to UIView
        
        let green = UIColor(red: 122/255, green: 203/255, blue: 110/255, alpha: 1)
        let darkGreen = UIColor(red: 60/255, green: 139/255, blue: 48/255, alpha: 1)
        
        let doneButton = UIButton(frame: CGRectMake((self.view.frame.size.width) - (90), 0, 100, 50))
        doneButton.setTitle("Done", forState: UIControlState.Normal)
        doneButton.setTitle("Done", forState: UIControlState.Highlighted)
        doneButton.setTitleColor(green, forState: UIControlState.Normal)
        doneButton.setTitleColor(darkGreen, forState: UIControlState.Highlighted)
        
        inputView.addSubview(doneButton) // add Button to UIView
        
        doneButton.addTarget(self, action: #selector(CreateEventViewController.doneButton(_:)), forControlEvents: UIControlEvents.TouchUpInside) // set button click event
        
        sender.inputView = inputView

        
        datePickerView!.datePickerMode = UIDatePickerMode.DateAndTime
    
        
        datePickerView!.addTarget(self, action: #selector(CreateEventViewController.datePickerValueChanged), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func datePickerValueChanged(sender:UIDatePicker) {
        
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        
        dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle
        
        dateTextField.text = dateFormatter.stringFromDate(sender.date)
        
    }
    func doneButton(sender:UIButton) {
        dateTextField.resignFirstResponder() // To resign the inputView on clicking done.
    }
    @IBAction func onClickYelp(sender: AnyObject) {
         // Was thinking we could do a blur
//        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView?.frame = scrollView.bounds
        blurEffectView?.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        scrollView.addSubview(blurEffectView!)
        
        self.yelpView?.hidden = false
        self.view.bringSubviewToFront(yelpView)
        yelpView.center.y = scrollView.contentOffset.y + 305
        yelpView.center.x = scrollView.contentOffset.x + 160
    }
    
    @IBAction func onClickDone(sender: AnyObject) {
        blurEffectView?.removeFromSuperview()
        self.yelpView.hidden = true
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        eventLocationLabel.text = filteredData![indexPath.row].address
        if (filteredData![indexPath.row].imageURL != nil) {
            eventImageView.setImageWithURL(filteredData![indexPath.row].imageURL!)
        }
        self.yelpView.hidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func createEvent(sender: AnyObject) {
        self.createEventButton.enabled = false
        let event = PFObject(className: "Events")
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .MediumStyle
        
        if (datePickerView?.date != nil) {
            dateString = formatter.stringFromDate(datePickerView!.date)
            event["event_date"] = datePickerView!.date
        }
        
        event["creator"] = creator
        event["event_name"] = eventNameLabel.text
        event["event_location"] = eventLocationLabel.text
        event["event_description"] = descriptionTextField.text
        
        // Grab our current location from the defaults
        let defaults = NSUserDefaults.standardUserDefaults()
        
        let latitude = defaults.objectForKey("user_latitude") as? String
        let longitude = defaults.objectForKey("user_longitude") as? String
        
        if (latitude != nil) {
            event["latitude"] = latitude
        }
        if (longitude != nil) {
            event["longitude"] = longitude
        }
        
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
    
    func callYelpAPI(input: String) {
        if(self.eventLocationLabel.text != nil){
            self.eventLocationLabel.text = input
        }
        Business.searchWithTerm(input, completion: { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            self.filteredData = businesses
            self.yelpTableView.reloadData()
            
//            for business in businesses{
//                print(business.name!)
//                print(business.address!)
//            }
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
}
