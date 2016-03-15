//
//  MyEventsTableViewCell.swift
//  Vente
//
//  Created by Alexandra Munoz on 3/8/16.
//  Copyright © 2016 nickbryanmiller. All rights reserved.
//

import UIKit
import Parse

let userDidClickRemove = "userDidClickRemove"

class MyEventsTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    var Event: PFObject! {
        didSet {
            self.nameLabel.text = Event["event_name"] as? String
            self.dateLabel.text = Event["event_date"] as? String
            self.locationLabel.text = Event["event_location"] as? String
            //self.attendeeList = Event["attendee_list"] as! [String]
        }
    }
    
    @IBAction func onRemove(sender: AnyObject) {
        let userId = PFUser.currentUser()?.objectId
        
        let query = PFQuery(className:"Events")
        query.getObjectInBackgroundWithId(Event.objectId!) {
            (event: PFObject?, error: NSError?) -> Void in
            if error != nil {
                print(error)
            } else if let event = event {
                event.removeObject(userId!, forKey: "attendee_list")
                event.saveInBackground()
                NSNotificationCenter.defaultCenter().postNotificationName(userDidClickRemove, object: nil)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
