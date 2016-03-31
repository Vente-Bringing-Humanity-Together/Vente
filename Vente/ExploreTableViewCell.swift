//
//  ExploreTableViewCell.swift
//  Vente
//
//  Created by Alexandra Munoz on 3/8/16.
//  Copyright © 2016 nickbryanmiller. All rights reserved.
//

import UIKit
import Parse

class ExploreTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var joinButton: UIButton!
    
    @IBOutlet weak var eventImageView: UIImageView!
    
    var attendeeList : [String]!
    
    var Event: PFObject! {
        didSet {
            self.nameLabel.text = Event["event_name"] as? String
            self.dateLabel.text = Event["event_date"] as? String
            self.locationLabel.text = Event["event_location"] as? String
            self.attendeeList = Event["attendee_list"] as! [String]
            self.eventImageView.image = Event["event_image"] as? UIImage
        }
    }
    
    @IBAction func onJoin(sender: AnyObject) {
        attendeeList.append(PFUser.currentUser()!.objectId! as String)
        //Event["attendee_list"] = attendeeList
        print(attendeeList)
        
        let query = PFQuery(className:"Events")
        query.getObjectInBackgroundWithId(Event.objectId!) {
            (event: PFObject?, error: NSError?) -> Void in
            if error != nil {
                print(error)
            } else if let event = event {
                event["attendee_list"] = self.attendeeList
                event.saveInBackground()
            }
        }
        
        joinButton.enabled = false
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
