//
//  SignUpViewController.swift
//  NickCompleteInstagram
//
//  Created by Nicholas Miller on 2/17/16.
//  Copyright © 2016 nickmiller. All rights reserved.
//

import UIKit
import Parse

class SignUpViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    var username: String = ""
    var password: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTextField.text = username
        passwordTextField.text = password
        
        if usernameTextField.text == "" {
            usernameTextField.text = nil
            usernameTextField.placeholder = "Username"
        }
        if passwordTextField.text == "" {
            passwordTextField.text = nil
            passwordTextField.placeholder = "Password"
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButtonTouched(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func signUpButtonTouched(sender: AnyObject) {
                
        if (usernameTextField.text != "" && passwordTextField.text != "" && passwordTextField.text == confirmPasswordTextField.text && emailTextField.text != "") {
            // initialize a user object
            let newUser = PFUser()
            
            // set user properties
            newUser.username = usernameTextField.text
            newUser.password = passwordTextField.text
            newUser.email = emailTextField.text
            
            // call sign up function on the object
            newUser.signUpInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                if let error = error {
                    print(error.localizedDescription)
                    if (error.code == 202) {
                        let alertController = UIAlertController(title: "Username Already Exists", message: "", preferredStyle: .Alert)
                        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                        }
                        alertController.addAction(OKAction)
                        self.presentViewController(alertController, animated: true) {
                        }
                    }
                    if (error.code == 203) {
                        let alertController = UIAlertController(title: "Email Already Exists", message: "", preferredStyle: .Alert)
                        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                        }
                        alertController.addAction(OKAction)
                        self.presentViewController(alertController, animated: true) {
                        }
                    }
                    if (error.code == 125) {
                        let alertController = UIAlertController(title: "Email Address Format Is Invalid", message: "example: abc@gmail.com", preferredStyle: .Alert)
                        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                        }
                        alertController.addAction(OKAction)
                        self.presentViewController(alertController, animated: true) {
                        }
                    }
                } else {
                    print("User Registered successfully")
                    // manually segue to logged in view
                    self.performSegueWithIdentifier("SignUpToHome", sender: nil)
                }
            }
        }
        
        else if (usernameTextField.text == "") {
            let alertController = UIAlertController(title: "Missing Username", message: "", preferredStyle: .Alert)
            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            }
            alertController.addAction(OKAction)
            self.presentViewController(alertController, animated: true) {
            }
        }
        else if (passwordTextField.text == "") {
            let alertController = UIAlertController(title: "Missing Password", message: "", preferredStyle: .Alert)
            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            }
            alertController.addAction(OKAction)
            self.presentViewController(alertController, animated: true) {
            }
        }
        else if (emailTextField.text == "") {
            let alertController = UIAlertController(title: "Missing Email", message: "", preferredStyle: .Alert)
            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            }
            alertController.addAction(OKAction)
            self.presentViewController(alertController, animated: true) {
            }
        }
        else if (passwordTextField.text != confirmPasswordTextField.text) {
            let alertController = UIAlertController(title: "Passwords Do Not Match", message: "", preferredStyle: .Alert)
            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            }
            alertController.addAction(OKAction)
            self.presentViewController(alertController, animated: true) {
            }
        }

    }

    @IBAction func screenTouched(sender: AnyObject) {
        view.endEditing(true)
    }
    
    @IBAction func screenSwipedUp(sender: AnyObject) {
        view.endEditing(true)
    }
    
}
