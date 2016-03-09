//
//  HomeViewController.swift
//  NickCompleteInstagram
//
//  Created by Nicholas Miller on 2/16/16.
//  Copyright © 2016 nickmiller. All rights reserved.
//

import UIKit
import Parse
import AFNetworking
import MBProgressHUD

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var refreshControl: UIRefreshControl!
    
    var userMedia: [PFObject]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableViewAutomaticDimension
        
        callParseServerForImages()
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("HomeTableViewCell", forIndexPath: indexPath) as! HomeTableViewCell
        
        if (userMedia?[indexPath.row]["media"] != nil) {
            let userImageFile = userMedia?[indexPath.row]["media"] as! PFFile
            userImageFile.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError?) -> Void in
                if let error = error {
                    print(error.localizedDescription)
                }
                else {
                    let image = UIImage(data: imageData!)
                    cell.postImageView.image = image
                }
            })
        }
        
        if (userMedia?[indexPath.row]["caption"] != nil) {
            cell.descriptionLabel.text = userMedia![indexPath.row]["caption"] as? String
        }
        if (userMedia?[indexPath.row]["author"].username != nil) {
            cell.creatorLabel.text = userMedia![indexPath.row]["author"].username
        }
        if (userMedia?[indexPath.row].createdAt != nil) {
            var createdAt = ""
            let formatter = NSDateFormatter()
            formatter.dateStyle = .ShortStyle
            createdAt = formatter.stringFromDate(userMedia![indexPath.row].createdAt!)
            cell.timeLabel.text = createdAt
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (userMedia != nil) {
            return userMedia!.count
        }
        else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func callParseServerForImages() {
        let query = PFQuery(className: "UserMedia")
        query.orderByDescending("createdAt")
        query.includeKey("author")
        query.limit = 20
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        // fetch data asynchronously
        query.findObjectsInBackgroundWithBlock { (media: [PFObject]?, error: NSError?) -> Void in
            if let media = media {
                // do something with the data fetched
//                print(media)
                self.userMedia = media
                self.tableView.reloadData()
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                
//                print("\(media[1].createdAt)")
                
            } else {
                // handle error
            }
        }
    }
    
    func testQuery() {
        let query = PFQuery(className: "UserMedia")
        query.getObjectInBackgroundWithId("dCgHoQRsXr") {
            (userMedia: PFObject?, error: NSError?) -> Void in
            if error == nil {
                print(userMedia)
            } else {
                print(error)
            }
        }
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    func onRefresh() {
        delay(2, closure: {
            self.refreshControl.endRefreshing()
        })
        
        callParseServerForImages()
        
        self.refreshControl?.endRefreshing()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "HomeToPostDetail") {
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPathForCell(cell)
            let post = userMedia![indexPath!.row]
            
            let postDetailViewController = segue.destinationViewController as! PostDetailViewController
            postDetailViewController.post = post
        }
    }

}
