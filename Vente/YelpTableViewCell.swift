//
//  YelpTableViewCell.swift
//  Vente
//
//  Created by Nikhil Thota on 3/29/16.
//  Copyright © 2016 nickbryanmiller. All rights reserved.
//

import UIKit

class YelpTableViewCell: UITableViewCell {

    @IBOutlet weak var yelpImageView: UIImageView!
    @IBOutlet weak var yelpNameLabel: UILabel!
    
    var business: Business! {
        didSet {
            if (business.imageURL != nil) {
                yelpImageView.setImageWithURL(business.imageURL!)
            }
            if (business.name != nil) {
                yelpNameLabel.text = business.name!
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
