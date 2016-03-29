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

class ChatViewController: UIViewController {
    
    var event: PFObject?
    var client: PubNub?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("in load")
        
        let configuration = PNConfiguration(publishKey: "pub-c-08213b8e-ca5d-4a44-a0e8-272d6ebbff6d", subscribeKey: "sub-c-0d695744-f5e8-11e5-8cfb-0619f8945a4f")
        // Instantiate PubNub client.
        client = PubNub.clientWithConfiguration(configuration)
        
        client!.publish("Hello from the PubNub Swift SDK", toChannel: "my_channel",
                           compressed: false, withCompletion: { (status) -> Void in
                            
                            if !status.error {
                                
                                // Message successfully published to specified channel.
                                print("why")
                            }
                            else{
                                print("i hate life")
                                // Handle message publish error. Check 'category' property
                                // to find out possible reason because of which request did fail.
                                // Review 'errorData' property (which has PNErrorData data type) of status
                                // object to get additional information about issue.
                                //
                                // Request can be resent using: status.retry()
                            }
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func getMessagesPlease(sender: AnyObject) {
        self.client?.historyForChannel("my_channel", withCompletion: { (result, status) -> Void in
            
            if status == nil {
                
                // Handle downloaded history using:
                //   result.data.start - oldest message time stamp in response
                //   result.data.end - newest message time stamp in response
                //   result.data.messages - list of messages
                print(result!.data.messages)
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
    

}
