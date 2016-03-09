//
//  PostDetailViewController.swift
//  NickCompleteInstagram
//
//  Created by Nicholas Miller on 2/17/16.
//  Copyright © 2016 nickmiller. All rights reserved.
//

import UIKit
import Parse

class PostDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var creatorLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var post: PFObject!
    
    var comments: [String] = []
    var users: [String] = []
    var times: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        if (post["media"] != nil) {
            let userImageFile = post["media"] as! PFFile
            userImageFile.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError?) -> Void in
                if let error = error {
                    print(error.localizedDescription)
                }
                else {
                    let image = UIImage(data: imageData!)
                    self.postImageView.image = image
                }
            })
        }
        
        if (post["caption"] != nil) {
            descriptionLabel.text = post["caption"] as? String
        }
        if (post["author"].username != nil) {
            creatorLabel.text = post["author"].username
        }
        if (post.createdAt != nil) {
            var createdAt = ""
            let formatter = NSDateFormatter()
            formatter.dateStyle = .ShortStyle
            createdAt = formatter.stringFromDate(post.createdAt!)
            timeLabel.text = createdAt
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (comments != []) {
            return comments.count
        }
        else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PostDetailTableViewCell", forIndexPath: indexPath) as! PostDetailTableViewCell
        
        cell.commentLabel.text = comments[indexPath.row]
        cell.creatorLabel.text = users[indexPath.row]
        cell.timeLabel.text = times[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        if segue.identifier == "PostDetailToComment" {
            
            if let viewController = segue.destinationViewController as? NewCommentViewController {
                // this funky syntax below is a swift closure
                viewController.onDataAvailable = {[weak self]
                    (data: String) in
                    self?.comments.insert(data, atIndex: 0)
                    self?.users.insert(PFUser.currentUser()!.username!, atIndex: 0)
                    
                    let date = NSDate()
                    let formatter = NSDateFormatter()
                    formatter.dateStyle = .ShortStyle
                    let time = formatter.stringFromDate(date)
                    self?.times.insert(time, atIndex: 0)
                    self?.tableView.reloadData()
                }
            }
        }
    }
    
}
