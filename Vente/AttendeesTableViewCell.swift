//
//  AttendeesTableViewCell.swift
//  Vente
//
//  Created by Alexandra Munoz on 3/15/16.
//  Copyright © 2016 nickbryanmiller. All rights reserved.
//

import UIKit
import Parse

class AttendeesTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
//    var userId: String = "a"
    
//    var User : String! {
//        didSet {
//            self.nameLabel.text = User["username"] as? String
//        }
//    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        nameLabel.text = userId
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
