//
//  EditProfileViewController.swift
//  Vente
//
//  Created by Alexandra Munoz on 3/24/16.
//  Copyright © 2016 nickbryanmiller. All rights reserved.
//

import UIKit
import Parse
import HUD
import Material

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let uploadImageButton: FlatButton = FlatButton(frame: CGRectMake(50, 372, 90, 30))
    let takePhotoButton: FlatButton = FlatButton(frame: CGRectMake(160, 372, 130, 30))
    let uploadCoverImageButton: FlatButton = FlatButton(frame: CGRectMake(50, 197, 90, 30))
    let takeCoverPhotoButton: FlatButton = FlatButton(frame: CGRectMake(160, 197, 130, 30))
    let closeButton: FlatButton = FlatButton(frame: CGRectMake(50, 477, 90, 30))
    let doneButton: FlatButton = FlatButton(frame: CGRectMake(180, 477, 90, 30))
    
    let myBioTextField: TextField! = TextField(frame: CGRectMake(8, 439, 304, 30))


    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var coverImageView: UIImageView!

    
    var isCover = false
    
    let vc = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uploadImageButton.setTitle("Upload", forState: .Normal)
        buttonMaker(uploadImageButton)
        uploadImageButton.addTarget(self, action: #selector(EditProfileViewController.uploadImageButtonTouched), forControlEvents: .TouchUpInside)
        
        takePhotoButton.setTitle("Take Photo", forState: .Normal)
        buttonMaker(takePhotoButton)
        takePhotoButton.addTarget(self, action: #selector(EditProfileViewController.takePhotoButtonTouched), forControlEvents: .TouchUpInside)
        
        uploadCoverImageButton.setTitle("Upload", forState: .Normal)
        buttonMaker(uploadCoverImageButton)
        uploadCoverImageButton.addTarget(self, action: #selector(EditProfileViewController.uploadCoverImageButtonTouched), forControlEvents: .TouchUpInside)
        
        takeCoverPhotoButton.setTitle("Take Photo", forState: .Normal)
        buttonMaker(takeCoverPhotoButton)
        takeCoverPhotoButton.addTarget(self, action: #selector(EditProfileViewController.takeCoverPhotoButtonTouched), forControlEvents: .TouchUpInside)
        
        doneButton.setTitle("Done", forState: .Normal)
        buttonMaker(doneButton)
        doneButton.addTarget(self, action: #selector(EditProfileViewController.doneButtonTouched), forControlEvents: .TouchUpInside)
        
        closeButton.setTitle("Close", forState: .Normal)
        buttonMaker(closeButton)
        closeButton.addTarget(self, action: #selector(EditProfileViewController.closeButtonTouched), forControlEvents: .TouchUpInside)
        
        myBioTextField.placeholder = "Your Bio"
        textMaker(myBioTextField)
        myBioTextField.addTarget(self, action: #selector(EditProfileViewController.textFieldDidBeginEditing), forControlEvents: .EditingDidBegin)
        myBioTextField.addTarget(self, action: #selector(EditProfileViewController.textFieldDidEndEditing), forControlEvents: .EditingDidEnd)
        
        vc.delegate = self
        vc.allowsEditing = true
        
        
        if (!UIImagePickerController.isSourceTypeAvailable(.Camera)){
            takePhotoButton.enabled = false
            takeCoverPhotoButton.enabled = false
        }
        if (!UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary)){
            uploadImageButton.enabled = false
            uploadCoverImageButton.enabled = false
        }

        if let navigationBar = navigationController?.navigationBar {
            navigationBar.barTintColor = UIColor(red: 0.88, green: 0.58, blue: 0.38, alpha: 1.0)
            navigationBar.backgroundColor = UIColor.whiteColor()
            navigationBar.tintColor = UIColor.whiteColor()
            
            self.navigationItem.title = "Edit Profile"
            
            let shadow = NSShadow()
            shadow.shadowColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
            shadow.shadowOffset = CGSizeMake(1, 1);
            shadow.shadowBlurRadius = 1;
            navigationBar.titleTextAttributes = [
                NSFontAttributeName : UIFont.boldSystemFontOfSize(22),
                NSForegroundColorAttributeName : UIColor.whiteColor(),
                NSShadowAttributeName : shadow
            ]
        }
        
        if let tabBar = tabBarController?.tabBar {
            tabBar.barTintColor = UIColor.whiteColor()
            tabBar.backgroundColor = UIColor.whiteColor()
        }
    }
    

    func uploadImageButtonTouched() {
        isCover = false
        vc.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        showImagePicker()
    }
    func takePhotoButtonTouched() {
        isCover = false
        vc.sourceType = UIImagePickerControllerSourceType.Camera
        showImagePicker()
    }
    
    func uploadCoverImageButtonTouched() {
        isCover = true
        vc.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        showImagePicker()
    }
    func takeCoverPhotoButtonTouched() {
        isCover = true
        vc.sourceType = UIImagePickerControllerSourceType.Camera
        showImagePicker()
    }
    
    func doneButtonTouched() {
        self.view.endEditing(true)
        
        HUD.show(.loading, text: "Loading...")
        
        let user = PFUser.currentUser()
        
        let userMedia = UserMedia()
        
        if (profileImageView.image != nil) {
            user!["profile_image"] = userMedia.getPFFileFromImage(profileImageView.image)
        }
        if (coverImageView.image != nil) {
            user!["cover_image"] = userMedia.getPFFileFromImage(coverImageView.image)
        }
        if (myBioTextField.text != nil || myBioTextField.text != "") {
            user!["bio"] = myBioTextField.text
        }
        
        user?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
            if let error = error {
                print("Update user failed")
                print(error.localizedDescription)
                
                HUD.dismiss()
                
                let alertController = UIAlertController(title: "There Was An Error", message: "", preferredStyle: .Alert)
                let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                }
                alertController.addAction(OKAction)
                self.presentViewController(alertController, animated: true) {
                }
                
            } else {
                print("Updated user successfully")
                
                HUD.show(.success, text: "Success")
                
//                self.navigationController?.popViewControllerAnimated(true)
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        })
    }
    
    func buttonMaker(button: FlatButton) {
        button.titleLabel!.font = UIFont (name: "District Pro Thin", size: 13)
        button.tintColor = UIColor(red: 226/255, green: 162/255, blue: 118/225, alpha: 1.0)
        
        // Add button to UIViewController.
        view.addSubview(button)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        // let resizedImage = resize(editedImage, newSize: CGSize(width: 100, height: 200))
        if isCover {
            coverImageView.image = editedImage
        }
        else {
            profileImageView.image = editedImage
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func showImagePicker() {
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func bioBeganToEdit(sender: UITextField) {
        textFieldDidBeginEditing(sender)
    }
    @IBAction func bioEndToEdit(sender: UITextField) {
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
    
    func textMaker(field: TextField) {
        
        field.placeholderTextColor = MaterialColor.grey.base
        field.font = UIFont (name: "District Pro Thin", size: 17)
        field.textColor = MaterialColor.black
        
        //        field.titleLabel = UILabel()
        field.titleLabel!.font = UIFont (name: "District Pro Thin", size: 17)
        field.titleLabelColor = UIColor(red: 226/255, green: 162/255, blue: 118/225, alpha: 1.0)
        field.titleLabelActiveColor = UIColor(red: 226/255, green: 162/255, blue: 118/225, alpha: 1.0)
        
        field.autocapitalizationType = .None
        
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

    
    
    func textFieldDidEndEditing(textField: UITextField) {
        var viewFrame : CGRect = self.view.frame
        viewFrame.origin.y += animateDistance
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        
        UIView.setAnimationDuration(NSTimeInterval(MoveKeyboard.KEYBOARD_ANIMATION_DURATION))
        
        self.view.frame = viewFrame
        
        UIView.commitAnimations()
        
    }
    
    @IBAction func screenTapped(sender: AnyObject) {
        view.endEditing(true)
    }
    
    func closeButtonTouched() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    

}
