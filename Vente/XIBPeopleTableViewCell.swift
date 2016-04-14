//
//  XIBPeopleTableViewCell.swift
//  Vente
//
//  Created by Nicholas Miller on 3/31/16.
//  Copyright © 2016 nickbryanmiller. All rights reserved.
//

import UIKit

class XIBPeopleTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var firstNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
