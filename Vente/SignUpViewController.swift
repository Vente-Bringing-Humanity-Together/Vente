//
//  SignUpViewController.swift
//  Vente
//
//  Created by Alexandra Munoz on 3/8/16.
//  Copyright © 2016 nickbryanmiller. All rights reserved.
//

import UIKit
import Parse
import Material

class SignUpViewController: UIViewController {

    let firstNameField: TextField = TextField(frame: CGRectMake(20, 127, 275, 30))
    let lastNameField: TextField = TextField(frame: CGRectMake(20, 200, 275, 30))
    let usernameField: TextField = TextField(frame: CGRectMake(20, 273, 275, 30))
    let passwordField: TextField = TextField(frame: CGRectMake(20, 420, 275, 30))
    let phoneNumberField: TextField = TextField(frame: CGRectMake(20, 347, 275, 30))
    
    let cancelbutton: FlatButton = FlatButton(frame: CGRectMake(3, 520, 90, 40))
    let signupbutton: FlatButton = FlatButton(frame: CGRectMake(220, 520, 100, 40))
    
    var followers : [String] = []
    var following : [String] = []
    
    var shouldMove = false
    var moveAmount: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        firstNameField.placeholder = "First Name"
        textMaker(firstNameField)
        
        lastNameField.placeholder = "Last Name"
        textMaker(lastNameField)
        
        usernameField.placeholder = "Username (Email)"
        textMaker(usernameField)
        usernameField.addTarget(self, action: #selector(SignUpViewController.usernameBeganToEdit), forControlEvents: .EditingDidBegin)
        usernameField.addTarget(self, action: #selector(SignUpViewController.usernameEndToEdit), forControlEvents: .EditingDidEnd)
        
        passwordField.placeholder = "Password"
        passwordField.secureTextEntry = true
        textMaker(passwordField)
        passwordField.addTarget(self, action: #selector(SignUpViewController.passwordBeganToEdit), forControlEvents: .EditingDidBegin)
        passwordField.addTarget(self, action: #selector(SignUpViewController.passwordEndToEdit), forControlEvents: .EditingDidEnd)
        
        phoneNumberField.placeholder = "Phone Number"
        textMaker(phoneNumberField)
        phoneNumberField.addTarget(self, action: #selector(SignUpViewController.numberBeganToEdit), forControlEvents: .EditingDidBegin)
        phoneNumberField.addTarget(self, action: #selector(SignUpViewController.numberEndToEdit), forControlEvents: .EditingDidEnd)
        
        cancelbutton.setTitle("Cancel", forState: .Normal)
        buttonMaker(cancelbutton)
        cancelbutton.addTarget(self, action: #selector(SignUpViewController.cancelButtonTouched), forControlEvents: .TouchUpInside)
        
        signupbutton.setTitle("Sign Up", forState: .Normal)
        buttonMaker(signupbutton)
        signupbutton.addTarget(self, action: #selector(SignUpViewController.signupButtonTouched), forControlEvents: .TouchUpInside)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

    func cancelButtonTouched() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func signupButtonTouched() {
        
        self.view.endEditing(true)
        
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
                    
                    let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc: UIViewController = storyboard.instantiateViewControllerWithIdentifier("tabBarController") as UIViewController
                    vc.modalTransitionStyle = .FlipHorizontal
                    self.presentViewController(vc, animated: true, completion: nil)
                    
                } else {
                    print("error")
                    print(error?.localizedDescription)
                }
            }

        }
        else {
            print("No ufl :)")
            let actionSheetController: UIAlertController = UIAlertController(title: "Alert", message: "Must have a .ufl email.", preferredStyle: .Alert)
            
            //Create and add the Cancel action
            let cancelAction: UIAlertAction = UIAlertAction(title: "Okay", style: .Cancel) { action -> Void in
            }
            actionSheetController.addAction(cancelAction)
            self.presentViewController(actionSheetController, animated: true, completion: nil)
        }
    }
    
    @IBAction func screenTapped(sender: AnyObject) {
        view.endEditing(true)
    }
    
    func usernameBeganToEdit() {
        textFieldDidBeginEditing(usernameField)
    }
    func usernameEndToEdit() {
        textFieldDidEndEditing(usernameField)
    }
    
    func numberBeganToEdit() {
        textFieldDidBeginEditing(phoneNumberField)
    }
    func numberEndToEdit() {
        textFieldDidEndEditing(phoneNumberField)
    }
    
    func passwordBeganToEdit() {
        textFieldDidBeginEditing(passwordField)
    }
    func passwordEndToEdit() {
        textFieldDidEndEditing(passwordField)
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
