//
//  EditProfileViewController.swift
//  Vente
//
//  Created by Alexandra Munoz on 3/24/16.
//  Copyright © 2016 nickbryanmiller. All rights reserved.
//

import UIKit
import Parse
import MBProgressHUD

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var uploadImageButton: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var takePhotoButton: UIButton!
    
    let vc = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vc.delegate = self
        vc.allowsEditing = true
        
        
        if (!UIImagePickerController.isSourceTypeAvailable(.Camera)){
            takePhotoButton.enabled = false
        }
        if (!UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary)){
            uploadImageButton.enabled = false
        }

        // Do any additional setup after loading the view.
    }

    @IBAction func uploadImageButtonTouched(sender: AnyObject) {
        
        vc.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        showImagePicker()
    }
    @IBAction func takePhotoButtonTouched(sender: AnyObject) {
        
        vc.sourceType = UIImagePickerControllerSourceType.Camera
        showImagePicker()
    }
    
    @IBAction func doneButtonTouched(sender: AnyObject) {
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        let user = PFUser.currentUser()
        
        let userMedia = UserMedia()
        
        if (profileImageView.image != nil) {
            user!["profile_image"] = userMedia.getPFFileFromImage(profileImageView.image)
        }
        user?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
            if let error = error {
                print("Update user failed")
                print(error.localizedDescription)
                
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                
                let alertController = UIAlertController(title: "There Was An Error", message: "", preferredStyle: .Alert)
                let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                }
                alertController.addAction(OKAction)
                self.presentViewController(alertController, animated: true) {
                }
                
            } else {
                print("Updated user successfully")
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                self.navigationController?.popViewControllerAnimated(true)
            }
        })
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
            // let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
            let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
            // let resizedImage = resize(editedImage, newSize: CGSize(width: 100, height: 200))
            profileImageView.image = editedImage
            dismissViewControllerAnimated(true, completion: nil)
    }
    
    func showImagePicker() {
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
