//
//  EventsDetailViewController.swift
//  Vente
//
//  Created by Alexandra Munoz on 3/15/16.
//  Copyright © 2016 nickbryanmiller. All rights reserved.
//

import UIKit
import Parse

class EventsDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var creatorNameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    var event: PFObject!
    var attendeeList : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cellNib = UINib(nibName: "AttendeesTableViewCell", bundle: NSBundle.mainBundle())
        tableView.registerNib(cellNib, forCellReuseIdentifier: "AttendeesTableViewCell")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.eventNameLabel.text = event["event_name"] as? String
        self.dateLabel.text = event["event_date"] as? String
        self.locationLabel.text = event["event_location"] as? String
        self.attendeeList = event["attendee_list"] as! [String]
        
        let query : PFQuery = PFUser.query()!
        query.getObjectInBackgroundWithId(event["creator"] as! String) {
            (user: PFObject?, error: NSError?) -> Void in
            if error != nil {
                print(user)
                print(user?.objectId)
            } else if let user = user {
                self.creatorNameLabel.text = user["first_name"] as? String
            }
        }
        
//        if (attendeeList.contains((PFUser.currentUser()?.objectId)!)) {
//            let backgroundImage = UIImage(named: "ic_chat")
//            let groupMessageButton = UIBarButtonItem(image: backgroundImage, style: .Plain, target: self, action: #selector(EventsDetailViewController.chatButtonTouched))
//
//            self.navigationItem.rightBarButtonItem = groupMessageButton
//        }
//        else {
//            self.navigationItem.rightBarButtonItem = .None
//        }
        
        let backgroundImage = UIImage(named: "ic_chat")
        let groupMessageButton = UIBarButtonItem(image: backgroundImage, style: .Plain, target: self, action: #selector(EventsDetailViewController.chatButtonTouched))

        self.navigationItem.rightBarButtonItem = groupMessageButton
    }
    
    func chatButtonTouched() {
        let chatViewController = ChatViewController()
        
        chatViewController.event = event
        
        self.navigationController?.pushViewController(chatViewController, animated: true)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.attendeeList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AttendeesTableViewCell", forIndexPath: indexPath) as! AttendeesTableViewCell
        
        let query : PFQuery = PFUser.query()!
        query.getObjectInBackgroundWithId(attendeeList[indexPath.row]) {
            (user: PFObject?, error: NSError?) -> Void in
            if error != nil {
                print(error)
            } else if let user = user {
                cell.nameLabel.text = user["first_name"] as? String
                cell.lastNameLabel.text = user["last_name"] as? String
                
                if (user["profile_image"] != nil) {
                    let userImageFile = user["profile_image"] as! PFFile
                    userImageFile.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError?) -> Void in
                        if let error = error {
                            print(error.localizedDescription)
                        }
                        else {
                            if(imageData != nil){
                                let image = UIImage(data: imageData!)
                                cell.profileImageView.image = image
                            }
                        }
                    })
                }
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let otherProfileViewController = OtherProfileViewController()
        let personID = attendeeList[indexPath.row]
        otherProfileViewController.personID = personID
        
        self.navigationController?.pushViewController(otherProfileViewController, animated: true)
    
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
