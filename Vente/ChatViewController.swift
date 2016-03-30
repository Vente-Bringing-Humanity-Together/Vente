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

class ChatViewController: UIViewController, PNObjectEventListener {
    
    var event: PFObject?
    var client: PubNub?
    
    @IBOutlet weak var myMessageTextField: UITextField!
    @IBOutlet weak var messageTextView: UITextView!
    
    var eventIDString: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageTextView.text = ""
        
        let configuration = PNConfiguration(publishKey: "pub-c-08213b8e-ca5d-4a44-a0e8-272d6ebbff6d", subscribeKey: "sub-c-0d695744-f5e8-11e5-8cfb-0619f8945a4f")
        // Instantiate PubNub client.
        client = PubNub.clientWithConfiguration(configuration)
        
        client?.addListener(self)
        
        eventIDString = (event?.objectId)!
        
        self.client?.subscribeToChannels([eventIDString], withPresence: true)
        
        loadMessages(eventIDString)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendButtonTouched(sender: AnyObject) {
        if myMessageTextField.text != nil {
            let me = PFUser.currentUser()!
            let myMessage = (me["first_name"] as! String) + " " + (me["last_name"] as! String) + ": " + myMessageTextField.text!
            sendMessageTo(myMessage, channel: eventIDString)
        }
    }
    
    func sendMessageTo(message: String, channel: String) {
        self.client?.publish(message, toChannel: channel, compressed: false, withCompletion: { (status) -> Void in
                                
            if !status.error {
                                    
                // Message successfully published to specified channel.
                print("successful post")
//                if (self.messageTextView.text != nil && self.messageTextView.text != "") {
//                    self.messageTextView.text = self.messageTextView.text + "\n" + message
//                }
//                else {
//                    self.messageTextView.text = message
//                }
//                
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
                
                for ele in result!.data.messages {
                    if (self.messageTextView.text != nil && self.messageTextView.text != "") {
                        self.messageTextView.text = self.messageTextView.text + "\n" + (ele as! String)
                    }
                    else {
                        self.messageTextView.text = ele as! String
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
        
        self.messageTextView.text = self.messageTextView.text + "\n" + (message.data.message as? String)!
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

}
