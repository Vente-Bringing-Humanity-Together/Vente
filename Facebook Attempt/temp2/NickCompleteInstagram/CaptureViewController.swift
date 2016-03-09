//
//  CaptureViewController.swift
//  NickCompleteInstagram
//
//  Created by Nicholas Miller on 2/16/16.
//  Copyright © 2016 nickmiller. All rights reserved.
//

import UIKit
import Parse

let userDidPostPhotoNotification = "userDidPostPhotoNotification"

class CaptureViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var chooseImageButton: UIButton!
    @IBOutlet weak var takeImageButton: UIButton!
    @IBOutlet weak var captionTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var takeAPhotoLabel: UILabel!
    @IBOutlet weak var uploadAPhotoLabel: UILabel!
    @IBOutlet weak var whatToDoLabel: UILabel!
    
    @IBOutlet weak var postingImageView: UIImageView!
    
    let vc = UIImagePickerController()
    
    let userMedia = UserMedia()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        vc.delegate = self
        vc.allowsEditing = true
        
        whatToDoLabel.hidden = false
        uploadAPhotoLabel.hidden = false
        takeAPhotoLabel.hidden = false
        postingImageView.hidden = true
        captionTextField.hidden = true
        submitButton.hidden = true
        
        if (!UIImagePickerController.isSourceTypeAvailable(.Camera)){
            takeImageButton.enabled = false
        }
        if (!UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary)){
            chooseImageButton.enabled = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func chooseImageButtonTouched(sender: AnyObject) {
        
        vc.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        showImagePicker()
    }
    
    @IBAction func takeImageButtonTouched(sender: AnyObject) {
        vc.sourceType = UIImagePickerControllerSourceType.Camera
        showImagePicker()
    }

    func imagePickerController(picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [String : AnyObject]) {
            whatToDoLabel.hidden = true
            uploadAPhotoLabel.hidden = false
            takeAPhotoLabel.hidden = false
            postingImageView.hidden = false
            captionTextField.hidden = false
            submitButton.hidden = false
            
//            let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
            let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
//            let resizedImage = resize(editedImage, newSize: CGSize(width: 100, height: 200))
            postingImageView.image = editedImage
            dismissViewControllerAnimated(true, completion: nil)
    }
    
    func showImagePicker() {
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func resize(image: UIImage, newSize: CGSize) -> UIImage {
        let resizeImageView = UIImageView(frame: CGRectMake(0, 0, newSize.width, newSize.height))
        resizeImageView.contentMode = UIViewContentMode.ScaleAspectFill
        resizeImageView.image = image
        
        UIGraphicsBeginImageContext(resizeImageView.frame.size)
        resizeImageView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    @IBAction func submitButtonTouched(sender: AnyObject) {
        
        if (postingImageView.image != nil && captionTextField.text != "") {
            submitButton.enabled = false
            captionTextField.enabled = false
            chooseImageButton.enabled = false
            takeImageButton.enabled = false
            
            userMedia.postUserImage(postingImageView.image!, withCaption: captionTextField.text!, withCompletion: { (success: Bool, error: NSError?) -> Void in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    print("Posted Image Successfully")
                    NSNotificationCenter.defaultCenter().postNotificationName(userDidPostPhotoNotification, object: nil)
                }
            })
        }
        
        else if (captionTextField.text == "") {
            let alertController = UIAlertController(title: "Please Write a Caption", message: "", preferredStyle: .Alert)
            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            }
            alertController.addAction(OKAction)
            self.presentViewController(alertController, animated: true) {
            }
        }
        else if (postingImageView.image == nil) {
            let alertController = UIAlertController(title: "Please Put an Image", message: "", preferredStyle: .Alert)
            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            }
            alertController.addAction(OKAction)
            self.presentViewController(alertController, animated: true) {
            }
        }
        
    }
    
    func otherWayToSaveImage() {
        //        userMedia.postUserImage(UIImage(named: "test"), withCaption: "test") { (success: Bool, error: NSError?) -> Void in
        //            if let error = error {
        //                print(error.localizedDescription)
        //            } else {
        //                print("Posted Image Successfully")
        //            }
        //        }
        
        //        let imageData = UIImagePNGRepresentation(UIImage(named: "test")!)
        //        let imageFile:PFFile = PFFile(data: imageData!)!
        //        let userImage = PFObject(className: "UserMedia")
        //        userImage.setObject(imageFile, forKey: "image")
        //        userImage.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
        //            if success {
        //                print("Object created with id: \(userImage.objectId)")
        //            } else {
        //                print("\(error)")
        //            }
        //        }
    }

    @IBAction func screenTouched(sender: AnyObject) {
        view.endEditing(true)
    }
    
    @IBAction func screenSwipedUp(sender: AnyObject) {
        view.endEditing(true)
    }
    
}
