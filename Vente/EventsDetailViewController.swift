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
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var event: PFObject!
    var attendeeList : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cellNib = UINib(nibName: "AttendeesTableViewCell", bundle: NSBundle.mainBundle())
        tableView.registerNib(cellNib, forCellReuseIdentifier: "AttendeesTableViewCell")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.eventNameLabel.text = event["event_name"] as? String
        self.locationLabel.text = event["event_location"] as? String
        self.attendeeList = event["attendee_list"] as! [String]
        self.descriptionLabel.text = event["event_description"] as? String
        
        if (event["event_image"] != nil) {
            let userImageFile = event["event_image"] as! PFFile
            userImageFile.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError?) -> Void in
                if let error = error {
                    print(error.localizedDescription)
                }
                else {
                    if(imageData != nil){
                        let image = UIImage(data: imageData!)
                        
                        self.coverImageView.image = image
                    }
                }
            })
        }

        
        var eventDateString = ""
        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .ShortStyle
        eventDateString = formatter.stringFromDate((event["event_date"] as? NSDate)!)
        self.dateLabel.text = eventDateString
        
        let query : PFQuery = PFUser.query()!
        query.getObjectInBackgroundWithId(event["creator"] as! String) {
            (user: PFObject?, error: NSError?) -> Void in
            if error != nil {
                print(user)
                print(user?.objectId)
            } else if let user = user {
                let first = user["first_name"] as? String
                let last = user["last_name"] as? String
                self.creatorNameLabel.text = "by: " + first! + " " + last!
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
        
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.barTintColor = UIColor(red: 0.88, green: 0.58, blue: 0.38, alpha: 1.0)
            navigationBar.backgroundColor = UIColor.whiteColor()
            navigationBar.tintColor = UIColor.whiteColor()
            
            self.navigationItem.title = "Details"
            
            let shadow = NSShadow()
            shadow.shadowColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
            shadow.shadowOffset = CGSizeMake(1, 1);
            shadow.shadowBlurRadius = 1;
            navigationBar.titleTextAttributes = [
                NSFontAttributeName : UIFont.boldSystemFontOfSize(22),
                NSForegroundColorAttributeName : UIColor.whiteColor(),
                NSShadowAttributeName : shadow
            ]
        }
        
        if let tabBar = tabBarController?.tabBar {
            tabBar.barTintColor = UIColor.whiteColor()
            tabBar.backgroundColor = UIColor.whiteColor()
            tabBar.tintColor = UIColor(red: 0.88, green: 0.58, blue: 0.38, alpha: 1.0)
        }
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
        
        cell.backgroundColor = UIColor(red: 161/255, green: 164/255, blue: 153/255, alpha: 0.8)
        
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
