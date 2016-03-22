//
//  SignUpViewController.swift
//  Vente
//
//  Created by Alexandra Munoz on 3/8/16.
//  Copyright © 2016 nickbryanmiller. All rights reserved.
//

import UIKit
import Parse

class SignUpViewController: UIViewController {

    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var phoneNumberField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    var followers : [String] = []
    var following : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func onCancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onSignUp(sender: AnyObject) {
        
        if ((usernameField.text?.containsString("ufl.edu")) == true) {
            
            let newUser = PFUser()
            
            newUser.username = usernameField.text
            newUser.password = passwordField.text
            newUser["number"] = phoneNumberField.text
            newUser["first_name"] = firstNameField.text
            newUser["last_name"] = lastNameField.text
            newUser["followers"] = followers
            newUser["following"] = following
            
            newUser.signUpInBackgroundWithBlock{ (success: Bool, error: NSError?) -> Void in
                if success {
                    print("Yay, created a user")
                    self.performSegueWithIdentifier("SignupToHome", sender: nil)
                } else {
                    print(error?.localizedDescription)
                }
            }

        }
        else {
            print("No ufl :)")
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
