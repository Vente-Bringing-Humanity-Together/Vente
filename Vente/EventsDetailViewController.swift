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
                let creator = event["creator"] as? String
                
                let query2 : PFQuery = PFUser.query()!
                query2.getObjectInBackgroundWithId(creator!) {
                    (user: PFObject?, error: NSError?) -> Void in
                    if error != nil {
                        print(user)
                        print(user?.objectId)
                    } else if let user = user {
                        self.creatorNameLabel.text = user["username"] as? String
                    }
                
                self.eventNameLabel.text = event["event_name"] as? String
                self.dateLabel.text = event["event_date"] as? String
                self.locationLabel.text = event["event_location"] as? String
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
