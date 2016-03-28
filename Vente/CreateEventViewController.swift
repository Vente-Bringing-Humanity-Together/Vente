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
    
    func setAttributes() {
        //label height
//        fooddrinkLabel.frame = CGRectMake(fooddrinkLabel.frame.origin.x, 200, fooddrinkLabel.frame.width, fooddrinkLabel.frame.height)
//        fooddrinkLabel.center.y = 700
//        entertainmentLabel.frame.origin.y = 800
//        sportsLabel.frame.origin.y = 850
//        chillLabel.frame.origin.y = 900
//        academicLabel.frame.origin.y = 950
//        nightlifeLabel.frame.origin.y = 1000
//        adventureLabel.frame.origin.y = 1050
//        musicLabel.frame.origin.y = 1100
//        
//        //switch height
//        fooddrinkSwitch.frame.origin.y = 750
//        entertainmentSwitch.frame.origin.y = 800
//        sportsSwitch.frame.origin.y = 850
//        chillSwitch.frame.origin.y = 900
//        academicSwitch.frame.origin.y = 950
//        nightlifeSwitch.frame.origin.y = 1000
//        adventureSwitch.frame.origin.y = 1050
//        musicSwitch .frame.origin.y = 1100
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vc.delegate = self
        vc.allowsEditing = true
        
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: 1020)
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
    func getPFFileFromImage(image: UIImage?) -> PFFile? {
        // check if image is not nil
        if let image = image {
            // get image data and check if that is not nil
            if let imageData = UIImagePNGRepresentation(image) {
                return PFFile(name: "image.png", data: imageData)
            }
        }
        return nil
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
    func imagePickerController(picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [String : AnyObject]) {
            
            //            let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
            let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
            //            let resizedImage = resize(editedImage, newSize: CGSize(width: 100, height: 200))
            eventImageView.image = editedImage
            dismissViewControllerAnimated(true, completion: nil)
            
            
            MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            
            let user = PFUser.currentUser()
            
            if (eventImageView.image != nil) {
                user!["event_image"] = getPFFileFromImage(eventImageView.image)
            }
            user?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                if let error = error {
                    print("Update event failed")
                    print(error.localizedDescription)
                    
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    
                    let alertController = UIAlertController(title: "There Was An Error", message: "", preferredStyle: .Alert)
                    let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                    }
                    alertController.addAction(OKAction)
                    self.presentViewController(alertController, animated: true) {
                    }
                    
                } else {
                    print("Updated event successfully")
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                }
            })
    }
}
