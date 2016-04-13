//
//  PastEventsTableViewCell.swift
//  Vente
//
//  Created by Nicholas Miller on 3/31/16.
//  Copyright © 2016 nickbryanmiller. All rights reserved.
//

import UIKit
import Parse

class PastEventsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var wentCountLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!

    var Event: PFObject! {
        didSet {
            self.nameLabel.text = Event["event_name"] as? String
            self.dateLabel.text = Event["event_date"] as? String
            self.locationLabel.text = Event["event_location"] as? String
            self.eventImageView.image = Event["event_image"] as? UIImage
            if (Event?["attendee_list"] != nil) {
                let goingCount = Event!["attendee_list"].count
                if (wentCountLabel != nil) {
                    if (goingCount == 1) {
                        self.wentCountLabel.text = "\(goingCount) person went"
                    }
                    else {
                        self.wentCountLabel.text = "\(goingCount) people went"
                    }
                }
                
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
