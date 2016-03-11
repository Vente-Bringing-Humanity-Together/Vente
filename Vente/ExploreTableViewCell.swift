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
    
    var Event: PFObject! {
        didSet {
            self.nameLabel.text = Event["event_name"] as? String
            self.dateLabel.text = Event["event_date"] as? String
            self.locationLabel.text = Event["event_location"] as? String
        }
    }
    
    @IBAction func onJoin(sender: AnyObject) {
        
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
