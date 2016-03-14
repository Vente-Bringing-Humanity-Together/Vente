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
            
            var strFirstName: String = ""
            var strLastName: String = ""
//            var strPictureURL: String = ""
            var strEmail: String = ""

            if (result.objectForKey("first_name") != nil) {
                strFirstName = (result.objectForKey("first_name") as? String)!

            }
            if (result.objectForKey("last_name") != nil) {
                strLastName = (result.objectForKey("last_name") as? String)!
            }
//            if (result.objectForKey("picture")?.objectForKey("data")?.objectForKey("url") != nil) {
//                strPictureURL = (result.objectForKey("picture")?.objectForKey("data")?.objectForKey("url") as? String)!
//            }
            if (result.objectForKey("email") != nil) {
                strEmail = (result.objectForKey("email") as? String)!
            }
            
            let newUser = PFUser()
            
            newUser.username = strEmail
            newUser.password = "pass"
            
            newUser.signUpInBackgroundWithBlock{ (success: Bool, error: NSError?) -> Void in
                if success {
                    print("Yay, created a facebook user")
                    self.performSegueWithIdentifier("loginSegue", sender: nil)
                } else {
                    print(error?.localizedDescription)
                    
                    if (error?.code == 202) {
                        PFUser.logInWithUsernameInBackground(strEmail, password: newUser.password!){
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


}

