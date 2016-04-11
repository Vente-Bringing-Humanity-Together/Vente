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
import Material

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var facebookButton: FBSDKLoginButton!
    
    let usernameField: TextField! = TextField(frame: CGRectMake(20, 110, 275, 30))
    let passwordField: TextField! = TextField(frame: CGRectMake(20, 180, 275, 30))
    let loginbutton: FlatButton = FlatButton(frame: CGRectMake(114, 265, 80, 40))
    let signupbutton: FlatButton = FlatButton(frame: CGRectMake(105, 310, 100, 40))
    
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
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setFloat(10, forKey: "distanceSlider")
        defaults.synchronize()
        
        usernameField.placeholder = "Username (email)"
        textMaker(usernameField)
        
        passwordField.placeholder = "Password"
        passwordField.secureTextEntry = true
        textMaker(passwordField)
        
        loginbutton.setTitle("Log In", forState: .Normal)
        buttonMaker(loginbutton)
        loginbutton.addTarget(self, action: #selector(LoginViewController.loginButtonTouched), forControlEvents: .TouchUpInside)
        
        signupbutton.setTitle("Sign Up", forState: .Normal)
        buttonMaker(signupbutton)
        signupbutton.addTarget(self, action: #selector(LoginViewController.signupButtonTouched), forControlEvents: .TouchUpInside)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func signupButtonTouched() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: UIViewController = storyboard.instantiateViewControllerWithIdentifier("signupvc") as UIViewController
        self.presentViewController(vc, animated: true, completion: nil)
    }

    func loginButtonTouched() {
        PFUser.logInWithUsernameInBackground(usernameField.text!, password: passwordField.text!){
            (user: PFUser?, error: NSError?) -> Void in
            if user != nil {
                print("You're logging in")
                print(PFUser.currentUser()?.objectId)
                
                self.performSegueWithIdentifier("loginSegue", sender: nil)
            }
        }
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
    
    func textMaker(field: TextField) {
        
        field.placeholderTextColor = MaterialColor.grey.base
        field.font = UIFont (name: "District Pro Thin", size: 17)
        field.textColor = MaterialColor.black
        
//        field.titleLabel = UILabel()
        field.titleLabel!.font = UIFont (name: "District Pro Thin", size: 17)
        field.titleLabelColor = MaterialColor.grey.base
        field.titleLabelActiveColor = MaterialColor.blue.darken1
        
        let image = UIImage(named: "ic_close")?.imageWithRenderingMode(.AlwaysTemplate)
        
        let clearButton: FlatButton = FlatButton()
        clearButton.pulseColor = MaterialColor.red.lighten1
        clearButton.pulseScale = false
        clearButton.tintColor = MaterialColor.red.lighten1
        clearButton.setImage(image, forState: .Normal)
        clearButton.setImage(image, forState: .Highlighted)
        
//        field.clearButton = clearButton
        view.addSubview(field)
    }
    
    func buttonMaker(button: FlatButton) {
        button.titleLabel!.font = UIFont (name: "District Pro Thin", size: 13)
        button.tintColor = MaterialColor.blue.darken1
        
        // Add button to UIViewController.
        view.addSubview(button)
    }
}

