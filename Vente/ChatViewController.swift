//
//  ChatViewController.swift
//  Vente
//
//  Created by Nicholas Miller on 3/29/16.
//  Copyright © 2016 nickbryanmiller. All rights reserved.
//

import UIKit
import Parse
import PubNub

class ChatViewController: UIViewController, PNObjectEventListener, UITableViewDelegate, UITableViewDataSource {
    
    var event: PFObject?
    var client: PubNub?
    
    @IBOutlet weak var myMessageTextField: UITextField!
    
    var eventIDString: String = ""
    
    var messages: [String] = []
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let cellNib = UINib(nibName: "MessageTableViewCell", bundle: NSBundle.mainBundle())
        tableView.registerNib(cellNib, forCellReuseIdentifier: "MessageTableViewCell")
        
        let configuration = PNConfiguration(publishKey: "pub-c-08213b8e-ca5d-4a44-a0e8-272d6ebbff6d", subscribeKey: "sub-c-0d695744-f5e8-11e5-8cfb-0619f8945a4f")
        // Instantiate PubNub client.
        client = PubNub.clientWithConfiguration(configuration)
        
        client?.addListener(self)
        
        eventIDString = (event?.objectId)!
        
        self.client?.subscribeToChannels([eventIDString], withPresence: true)
        
        loadMessages(eventIDString)
        
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.barTintColor = UIColor(red: 0.29, green: 0.27, blue: 0.26, alpha: 1.0)
            navigationBar.backgroundColor = UIColor.whiteColor()
            navigationBar.tintColor = UIColor.whiteColor()
            
            self.navigationItem.title = "Messages"
            
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
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendButtonTouched(sender: AnyObject) {
        if myMessageTextField.text != nil {
            let me = PFUser.currentUser()!
            let myID = me.objectId
            let myMessage = (me["first_name"] as! String) + " " + (me["last_name"] as! String) + "@" + myMessageTextField.text!
            
            let IDMessage = myID! + "@" + myMessage
            
            sendMessageTo(IDMessage, channel: eventIDString)
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if messages != [] {
            return messages.count
        }
        else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MessageTableViewCell", forIndexPath: indexPath) as! MessageTableViewCell
        
        let messageWhole = messages[indexPath.row]
        let firstAt = messageWhole.characters.indexOf("@")
        let userID = messageWhole.substringToIndex(firstAt!)
        let oneAfterFirstAt = firstAt?.advancedBy(1)
        let messageNameAndText = messageWhole.substringFromIndex(oneAfterFirstAt!)
        let secondAt = messageNameAndText.characters.indexOf("@")
//        let name = messageNameAndText.substringToIndex(secondAt!)
        let oneAfterSecondAt = secondAt?.advancedBy(1)
        let messageText = messageNameAndText.substringFromIndex(oneAfterSecondAt!)
        
        if (PFUser.currentUser()?.objectId! == userID) {
            cell.leftView.backgroundColor = UIColor.whiteColor()
            cell.leftLabel.text = ""
            cell.rightView.backgroundColor = UIColor.blueColor()
            cell.rightLabel.text = messageText
            cell.rightLabel.textColor = UIColor.whiteColor()
        }
        else {
            cell.rightView.backgroundColor = UIColor.whiteColor()
            cell.rightLabel.text = ""
            cell.leftView.backgroundColor = UIColor.greenColor()
            cell.leftLabel.text = messageText
            cell.leftLabel.textColor = UIColor.whiteColor()
        }
        
        return cell
    }
    
    func sendMessageTo(message: String, channel: String) {
        self.client?.publish(message, toChannel: channel, compressed: false, withCompletion: { (status) -> Void in
                                
            if !status.error {
                                    
                // Message successfully published to specified channel.
                print("successful post")
               
                self.myMessageTextField.text = ""
                
            }
            else {
                print("message failed")
                // Handle message publish error. Check 'category' property
                // to find out possible reason because of which request did fail.
                // Review 'errorData' property (which has PNErrorData data type) of status
                // object to get additional information about issue.
                //
                // Request can be resent using: status.retry()
            }
        })
    }
    
    func loadMessages(channel: String) {
        self.client?.historyForChannel(channel, withCompletion: { (result, status) -> Void in
            
            if status == nil {
                
                // Handle downloaded history using:
                //   result.data.start - oldest message time stamp in response
                //   result.data.end - newest message time stamp in response
                //   result.data.messages - list of messages
                
                if (result?.data.messages != nil) {
                    self.messages = result!.data.messages as! [String]
                    self.tableView.reloadData()
                    
                    if (self.messages.count > 0) {
                        let lastSpot = self.messages.count - 1
                        let position = NSIndexPath(forRow: lastSpot, inSection: 0)
                        self.tableView.scrollToRowAtIndexPath(position, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
                    }
                }
                
            }
            else {
                
                // Handle message history download error. Check 'category' property
                // to find out possible reason because of which request did fail.
                // Review 'errorData' property (which has PNErrorData data type) of status
                // object to get additional information about issue.
                //
                // Request can be resent using: status.retry()
            }
        })
    }
    
    // Handle new message from one of channels on which client has been subscribed.
    func client(client: PubNub, didReceiveMessage message: PNMessageResult) {
        
        // Handle new message stored in message.data.message
        if message.data.actualChannel != nil {
            
            // Message has been received on channel group stored in
            // message.data.subscribedChannel
        }
        else {
            
            // Message has been received on channel stored in
            // message.data.subscribedChannel
        }
        
        print("Received message: \(message.data.message) on channel " +
            "\((message.data.actualChannel ?? message.data.subscribedChannel)!) at " +
            "\(message.data.timetoken)")
        
        messages.append((message.data.message as? String)!)
        
        self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: messages.count-1, inSection: 0)], withRowAnimation: .Bottom)
        
        
    }
    
    // New presence event handling.
    func client(client: PubNub, didReceivePresenceEvent event: PNPresenceEventResult) {
        
        // Handle presence event event.data.presenceEvent (one of: join, leave, timeout,
        // state-change).
        if event.data.actualChannel != nil {
            
            // Presence event has been received on channel group stored in
            // event.data.subscribedChannel
        }
        else {
            
            // Presence event has been received on channel stored in
            // event.data.subscribedChannel
        }
        
        if event.data.presenceEvent != "state-change" {
            
            print("\(event.data.presence.uuid) \"\(event.data.presenceEvent)'ed\"\n" +
                "at: \(event.data.presence.timetoken) " +
                "on \((event.data.actualChannel ?? event.data.subscribedChannel)!) " +
                "(Occupancy: \(event.data.presence.occupancy))");
        }
        else {
            
            print("\(event.data.presence.uuid) changed state at: " +
                "\(event.data.presence.timetoken) " +
                "on \((event.data.actualChannel ?? event.data.subscribedChannel)!) to:\n" +
                "\(event.data.presence.state)");
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    @IBAction func myMessageFieldBegan(sender: UITextField) {
        textFieldDidBeginEditing(sender)
    }
    
    @IBAction func myMessageFieldEnd(sender: UITextField) {
        textFieldDidEndEditing(sender)
    }
    
    struct MoveKeyboard {
        static let KEYBOARD_ANIMATION_DURATION : CGFloat = 0.3
        static let MINIMUM_SCROLL_FRACTION : CGFloat = 0.2;
        static let MAXIMUM_SCROLL_FRACTION : CGFloat = 0.8;
        static let PORTRAIT_KEYBOARD_HEIGHT : CGFloat = 216;
        static let LANDSCAPE_KEYBOARD_HEIGHT : CGFloat = 162;
    }
    
    var animateDistance: CGFloat = 0
    
    func textFieldDidBeginEditing(textField: UITextField) {
        let textFieldRect : CGRect = self.view.window!.convertRect(textField.bounds, fromView: textField)
        let viewRect : CGRect = self.view.window!.convertRect(self.view.bounds, fromView: self.view)
        
        let midline : CGFloat = textFieldRect.origin.y + 0.5 * textFieldRect.size.height
        let numerator : CGFloat = midline - viewRect.origin.y - MoveKeyboard.MINIMUM_SCROLL_FRACTION * viewRect.size.height
        let denominator : CGFloat = (MoveKeyboard.MAXIMUM_SCROLL_FRACTION - MoveKeyboard.MINIMUM_SCROLL_FRACTION) * viewRect.size.height
        var heightFraction : CGFloat = numerator / denominator
        
        if heightFraction < 0.0 {
            heightFraction = 0.0
        } else if heightFraction > 1.0 {
            heightFraction = 1.0
        }
        
        let orientation : UIInterfaceOrientation = UIApplication.sharedApplication().statusBarOrientation
        if (orientation == UIInterfaceOrientation.Portrait || orientation == UIInterfaceOrientation.PortraitUpsideDown) {
            animateDistance = floor(MoveKeyboard.PORTRAIT_KEYBOARD_HEIGHT * heightFraction)
        } else {
            animateDistance = floor(MoveKeyboard.LANDSCAPE_KEYBOARD_HEIGHT * heightFraction)
        }
        
        var viewFrame : CGRect = self.view.frame
        viewFrame.origin.y -= animateDistance
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(NSTimeInterval(MoveKeyboard.KEYBOARD_ANIMATION_DURATION))
        
        self.view.frame = viewFrame
        
        UIView.commitAnimations()
    }
    
    
    func textFieldDidEndEditing(textField: UITextField) {
        var viewFrame : CGRect = self.view.frame
        viewFrame.origin.y += animateDistance
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        
        UIView.setAnimationDuration(NSTimeInterval(MoveKeyboard.KEYBOARD_ANIMATION_DURATION))
        
        self.view.frame = viewFrame
        
        UIView.commitAnimations()
        
    }

}
