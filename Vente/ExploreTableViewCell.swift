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
    
    @IBOutlet weak var eventImageView: UIImageView!
    
    var attendeeList : [String]!
    
    var Event: PFObject! {
        didSet {
            self.nameLabel.text = Event["event_name"] as? String
            self.locationLabel.text = Event["event_location"] as? String
            self.attendeeList = Event["attendee_list"] as! [String]
            self.eventImageView.image = Event["event_image"] as? UIImage
            
            var eventDateString = ""
            let formatter = NSDateFormatter()
            formatter.dateStyle = .ShortStyle
            formatter.timeStyle = .ShortStyle
            eventDateString = formatter.stringFromDate((Event["event_date"] as? NSDate)!)
            self.dateLabel.text = eventDateString
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
