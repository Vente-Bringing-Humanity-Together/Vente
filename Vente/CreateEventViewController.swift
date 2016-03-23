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

    @IBOutlet weak var eventNameLabel: UITextField!
    @IBOutlet weak var eventDateLabel: UITextField!
    @IBOutlet weak var eventLocationLabel: UITextField!
    @IBOutlet weak var eventImageView: UIImageView!
    
    @IBOutlet weak var publicSegmentedControl: UISegmentedControl!
    
    let creator = PFUser.currentUser()!.objectId! as String
    var attendeeList: [String] = []
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: 800)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func createEvent(sender: AnyObject) {
        
        let event = PFObject(className: "Events")
        
        event["creator"] = creator
        event["event_name"] = eventNameLabel.text
        event["event_date"] = eventDateLabel.text
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
