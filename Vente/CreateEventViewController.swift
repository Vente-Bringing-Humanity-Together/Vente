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

class CreateEventViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var businesses: [Business]!
    var filteredData: [Business]?
    
    let vc = UIImagePickerController()

    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet weak var uploadImageButton: UIButton!
    @IBOutlet weak var eventNameLabel: UITextField!
    @IBOutlet weak var eventLocationLabel: UITextField!
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vc.delegate = self
        vc.allowsEditing = true
        
        if (!UIImagePickerController.isSourceTypeAvailable(.Camera)){
            takePhotoButton.enabled = false
        }
        if (!UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary)){
            uploadImageButton.enabled = false
        }
        
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: 1270)
        //setAttributes()
    }

    override func viewWillAppear(animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func createEvent(sender: AnyObject) {
        
        let event = PFObject(className: "Events")
        
        var dateString = ""
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .MediumStyle
        dateString = formatter.stringFromDate(datePicker.date)
        
        event["creator"] = creator
        event["event_name"] = eventNameLabel.text
        event["event_date"] = dateString
        event["event_location"] = eventLocationLabel.text
        
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
            
            for business in businesses{
                print(business.name!)
                print(business.address!)
            }
        })
    
    }
        

    
    @IBAction func onEditingChanged(sender: AnyObject) {
        callYelpAPI(eventLocationLabel.text!)
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
}
