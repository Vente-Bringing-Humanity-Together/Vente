//
//  LoginViewController.swift
//  NickCompleteInstagram
//
//  Created by Nicholas Miller on 2/16/16.
//  Copyright © 2016 nickmiller. All rights reserved.
//

import UIKit
import Parse
import FBSDKCoreKit
import FBSDKLoginKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {

    @IBOutlet weak var facebookButton: FBSDKLoginButton!
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginImageView: UIImageView!
    var imageArray = [UIImage(named: "signin1"), UIImage(named: "signin2"), UIImage(named: "signin3"), UIImage(named: "signin4")]
    var imageIndex = 0
    var timer = NSTimer()
    var deltaFade: CGFloat = 0.02
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        facebookButton.readPermissions = ["public_profile", "email", "user_friends"];
        facebookButton.delegate = self
        
        loginImageView.image = imageArray[imageIndex]

        timer = NSTimer.scheduledTimerWithTimeInterval(0.05, target:self, selector: Selector("updateImages"), userInfo: nil, repeats: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields":"first_name, last_name, picture.type(large)"]).startWithCompletionHandler { (connection, result, error) -> Void in
            
            let strFirstName: String = (result.objectForKey("first_name") as? String)!
            let strLastName: String = (result.objectForKey("last_name") as? String)!
            let strPictureURL: String = (result.objectForKey("picture")?.objectForKey("data")?.objectForKey("url") as? String)!
            
            print(strFirstName)
            
            self.performSegueWithIdentifier("loginToHome", sender: nil)
        }
    }
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
    }
    
    func signUp() {
        
    }
    
    func updateImages() {
        loginImageView.alpha = loginImageView.alpha - deltaFade
        
        if (loginImageView.alpha <= 0) {
            deltaFade = -deltaFade
            imageIndex++
            
            if (imageIndex >= imageArray.count) {
                imageIndex = 0
            }
            
            loginImageView.image = imageArray[imageIndex]

        }
        
        if (loginImageView.alpha >= 1) {
            deltaFade = -deltaFade
        }
        
    }
    
    @IBAction func onSignIn(sender: AnyObject) {
        // let username = usernameTextField.text ?? ""
        // let password = passwordTextField.text ?? ""
        let username = usernameTextField.text!
        let password = passwordTextField.text!
        
        PFUser.logInWithUsernameInBackground(username, password: password) { (user: PFUser?, error: NSError?) -> Void in
            if let error = error {
                print("User login failed.")
                print(error.localizedDescription)
                if (error.code == 101) {
                    let alertController = UIAlertController(title: "Username or Password\nInvalid", message: "", preferredStyle: .Alert)
                    let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                    }
                    alertController.addAction(OKAction)
                    self.presentViewController(alertController, animated: true) {
                    }
                }
            } else {
                print("User logged in successfully")
                // display view controller that needs to shown after successful login
                self.performSegueWithIdentifier("loginToHome", sender: nil)
            }
        }
    }
    
    @IBAction func onSignUp(sender: AnyObject) {
    }
    
    @IBAction func facebookButtonClicked(sender: AnyObject) {
//        loginWithFacebook()
    }
    
    @IBAction func screenTouched(sender: AnyObject) {
        view.endEditing(true)
    }
    
    @IBAction func screenSwipedUp(sender: AnyObject) {
        view.endEditing(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "loginToSignUp") {
            
            let signUpViewController = segue.destinationViewController as! SignUpViewController
            if (usernameTextField.text != nil) {
                signUpViewController.username = usernameTextField.text!
            }
            if (passwordTextField.text != nil) {
                signUpViewController.password = passwordTextField.text!
            }
        
        }
    }
    
}
