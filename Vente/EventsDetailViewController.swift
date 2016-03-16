//
//  EventsDetailViewController.swift
//  Vente
//
//  Created by Alexandra Munoz on 3/15/16.
//  Copyright © 2016 nickbryanmiller. All rights reserved.
//

import UIKit
import Parse

class EventsDetailViewController: UIViewController {

    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var creatorNameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    var event: PFObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cellNib = UINib(nibName: "AttendeesTableViewCell", bundle: NSBundle.mainBundle())
        tableView.registerNib(cellNib, forCellReuseIdentifier: "AttendeesTableViewCell")

        let query = PFQuery(className:"Events")
        query.getObjectInBackgroundWithId(event.objectId!) {
            (event: PFObject?, error: NSError?) -> Void in
            if error != nil {
                print(error)
            } else if let event = event {
                self.creatorNameLabel.text = event["creator"] as? String
                event.saveInBackground()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
