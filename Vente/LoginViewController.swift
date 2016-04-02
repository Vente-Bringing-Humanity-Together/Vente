//
//  ViewController.swift
//  Vente
//
//  Created by Nicholas Miller on 3/8/16.
//  Copyright © 2016 nickbryanmiller. All rights reserved.
//

import UIKit
import Parse
import FBSDKCoreKit
import FBSDKLoginKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var facebookButton: FBSDKLoginButton!

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    var followers : [String] = []
    var following : [String] = []
    
    var strFirstName: String = ""
    var strLastName: String = ""
//    var strPictureURL: String = ""
    var strEmail: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        facebookButton.readPermissions = ["public_profile", "email", "user_friends"];
        facebookButton.delegate = self
    }

    @IBAction func onLogIn(sender: AnyObject) {
        PFUser.logInWithUsernameInBackground(usernameField.text!, password: passwordField.text!){
            (user: PFUser?, error: NSError?) -> Void in
            if user != nil {
                print("You're logging in")
                print(PFUser.currentUser()?.objectId)
                
                self.performSegueWithIdentifier("loginSegue", sender: nil)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields":"first_name, last_name, picture.type(large), email"]).startWithCompletionHandler { (connection, result, error) -> Void in

            if (result.objectForKey("first_name") != nil) {
                self.strFirstName = (result.objectForKey("first_name") as? String)!

            }
            if (result.objectForKey("last_name") != nil) {
                self.strLastName = (result.objectForKey("last_name") as? String)!
            }
//            if (result.objectForKey("picture")?.objectForKey("data")?.objectForKey("url") != nil) {
//                strPictureURL = (result.objectForKey("picture")?.objectForKey("data")?.objectForKey("url") as? String)!
//            }
            if (result.objectForKey("email") != nil) {
                self.strEmail = (result.objectForKey("email") as? String)!
            }
            
            let newUser = PFUser()
            
            newUser.username = self.strEmail
            newUser.password = "pass"
            newUser["first_name"] = self.strFirstName
            newUser["last_name"] = self.strLastName
            newUser["following"] = self.following
            
            newUser.signUpInBackgroundWithBlock{ (success: Bool, error: NSError?) -> Void in
                if success {
                    print("Yay, created a facebook user")
                    
                    let followerList = PFObject(className: "Followers")
                    followerList["followers"] = self.followers
                    followerList["creatorId"] = newUser.objectId
                    
                    followerList.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                        if let error = error {
                            print("Follower list add failed")
                            print(error.localizedDescription)
                            
                        } else {
                            print("Added empty follower list")
                        }
                        
                    }
                    
                    self.performSegueWithIdentifier("loginSegue", sender: nil)
                }
                else {
                    print(error?.localizedDescription)
                    
                    if (error?.code == 202) {
                        PFUser.logInWithUsernameInBackground(self.strEmail, password: newUser.password!){
                            (user: PFUser?, error: NSError?) -> Void in
                            if user != nil {
                                print("You're logging in through facebook")
                                print(PFUser.currentUser()?.objectId)
                                
                                self.performSegueWithIdentifier("loginSegue", sender: nil)
                            }
                        }
                    }
                }
            }
            
        }
    }
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
    }

    @IBAction func screenTapped(sender: AnyObject) {
        view.endEditing(true)
    }
    
}

