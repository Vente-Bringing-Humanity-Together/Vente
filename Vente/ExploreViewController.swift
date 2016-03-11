//
//  ExploreViewController.swift
//  Vente
//
//  Created by Alexandra Munoz on 3/8/16.
//  Copyright © 2016 nickbryanmiller. All rights reserved.
//

import UIKit
import Parse

class ExploreViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var eventsTableView: UITableView!
    
    var events: [PFObject]!
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if self.events == nil{
            return 0
        }
        else{
            return self.events.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = eventsTableView.dequeueReusableCellWithIdentifier("ExploreTableViewCell") as! ExploreTableViewCell
        cell.Event = events[indexPath.row]
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.eventsTableView.dataSource = self
        self.eventsTableView.delegate = self
//        self.eventsTableView.estimatedRowHeight = 150
//        self.eventsTableView.rowHeight = UITableViewAutomaticDimension
    }
    
    @IBAction func addEvent(sender: AnyObject) {
        let createEventViewController = CreateEventViewController()
        self.navigationController?.pushViewController(createEventViewController, animated: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        print("Retrieving Ventes from Parse...")
        
        let query = PFQuery(className: "Events")
        query.orderByDescending("createdAt")
        query.findObjectsInBackgroundWithBlock { (results: [PFObject]?, error: NSError?) -> Void in
            if let error = error {
                print("Error: \(error)")
            } else {
                if let results = results {
                    print("Successfully retrieved \(results.count) ventes")
                    self.events = results
                    self.eventsTableView.reloadData()
                } else {
                    print("No results returned")
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
