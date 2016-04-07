//
//  ExploreTableViewCell.swift
//  Vente
//
//  Created by Alexandra Munoz on 3/8/16.
//  Copyright © 2016 nickbryanmiller. All rights reserved.
//

import UIKit
import Parse
import DOFavoriteButton

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
        
        let button = DOFavoriteButton(frame: CGRectMake(250, 0, 60, 60), image: UIImage(named: "ic_done"))
        button.imageColorOff = UIColor.whiteColor()
        button.imageColorOn = UIColor.greenColor()
        button.circleColor = UIColor.whiteColor()
        button.lineColor = UIColor.greenColor()
        button.duration = 2.0
        self.addSubview(button)
        button.addTarget(self, action: #selector(ExploreTableViewCell.tapped(_:)), forControlEvents: .TouchUpInside)
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func tapped(sender: DOFavoriteButton) {
        if sender.selected {
            // deselect
            sender.deselect()
        } else {
            // select with animation
            sender.select()
        }
    }

}
