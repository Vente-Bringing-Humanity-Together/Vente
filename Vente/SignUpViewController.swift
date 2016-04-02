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
    
    var shouldMove = false
    var moveAmount: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SignUpViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SignUpViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y -= keyboardSize.height
            print(keyboardSize.height)
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y += keyboardSize.height
        }
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
            newUser["following"] = following
            
            newUser.signUpInBackgroundWithBlock{ (success: Bool, error: NSError?) -> Void in
                if success {
                    print("Yay, created a user")
                    
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
                    
                    self.performSegueWithIdentifier("SignupToHome", sender: nil)
                } else {
                    print("error")
                    print(error?.localizedDescription)
                }
            }

        }
        else {
            print("No ufl :)")
        }
    }
    
    @IBAction func screenTapped(sender: AnyObject) {
        view.endEditing(true)
    }
    
    @IBAction func emailBeganToEdit(sender: UITextField) {
        textFieldDidBeginEditing(sender)
    }
    @IBAction func emailEndToEdit(sender: UITextField) {
        textFieldDidEndEditing(sender)
    }
    
    @IBAction func numberBeganToEdit(sender: UITextField) {
        textFieldDidBeginEditing(sender)
    }
    @IBAction func numberEndToEdit(sender: UITextField) {
        textFieldDidEndEditing(sender)
    }
    
    @IBAction func passwordBeganToEdit(sender: UITextField) {
        textFieldDidBeginEditing(sender)
    }
    @IBAction func passwordEndToEdit(sender: UITextField) {
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
