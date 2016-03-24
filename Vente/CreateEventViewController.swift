//
//  CreateEventViewController.swift
//  Vente
//
//  Created by Alexandra Munoz on 3/9/16.
//  Copyright © 2016 nickbryanmiller. All rights reserved.
//

import UIKit
import Parse

let userDidPostEventNotification = "userDidPostEventNotification"

class CreateEventViewController: UIViewController {
    
    var businesses: [Business]!
    var filteredData: [Business]?

    @IBOutlet weak var eventNameLabel: UITextField!
    @IBOutlet weak var eventLocationLabel: UITextField!
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var publicSegmentedControl: UISegmentedControl!
    
    let creator = PFUser.currentUser()!.objectId! as String
    var attendeeList: [String] = []
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var fooddrinkLabel: UILabel!
    @IBOutlet weak var entertainmentLabel: UILabel!
    @IBOutlet weak var sportsLabel: UILabel!
    @IBOutlet weak var chillLabel: UILabel!
    @IBOutlet weak var musicLabel: UILabel!
    @IBOutlet weak var academicLabel: UILabel!
    @IBOutlet weak var nightlifeLabel: UILabel!
    @IBOutlet weak var adventureLabel: UILabel!
    
    @IBOutlet weak var fooddrinkSwitch: UISwitch!
    @IBOutlet weak var entertainmentSwitch: UISwitch!
    @IBOutlet weak var sportsSwitch: UISwitch!
    @IBOutlet weak var chillSwitch: UISwitch!
    @IBOutlet weak var musicSwitch: UISwitch!
    @IBOutlet weak var academicSwitch: UISwitch!
    @IBOutlet weak var nightlifeSwitch: UISwitch!
    @IBOutlet weak var adventureSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: 800)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setAttributes() {
        
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
    

}
