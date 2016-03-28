//
//  ProfileViewController.swift
//  Vente
//
//  Created by Alexandra Munoz on 3/8/16.
//  Copyright © 2016 nickbryanmiller. All rights reserved.
//

import UIKit
import Parse
import FBSDKCoreKit
import FBSDKLoginKit

let userDidLogoutNotification = "userDidLogoutNotification"

class ProfileViewController: UIViewController {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getUserData();
    }
    
    override func viewWillAppear(animated: Bool) {
        
        let user = PFUser.currentUser()
        
        if (user?["profile_image"] != nil) {
            let userImageFile = user?["profile_image"] as! PFFile
            userImageFile.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError?) -> Void in
                if let error = error {
                    print(error.localizedDescription)
                }
                else {
                    let image = UIImage(data: imageData!)
                    self.profileImageView.image = image
                }
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func editButtonTouched(sender: AnyObject) {
        
        let editProfileViewController = EditProfileViewController()
        self.navigationController?.pushViewController(editProfileViewController, animated: true)
        
    }
    
    @IBAction func signOutButtonTouched(sender: AnyObject) {
        
        PFUser.logOutInBackgroundWithBlock { (error: NSError?) -> Void in
            
            if let error = error {
                print(error.localizedDescription)
            }
            else {
                print("Successfuly logged out")
                let loginManager: FBSDKLoginManager = FBSDKLoginManager()
                loginManager.logOut()
                NSNotificationCenter.defaultCenter().postNotificationName(userDidLogoutNotification, object: nil)
            }
        }
    }
    
    func getUserData() {
        
        let user = PFUser.currentUser()
        
        if (user?["first_name"] != nil && user?["last_name"] != nil) {
            nameLabel.text = (user?["first_name"] as! String) + " " + ((user?["last_name"])! as! String)
        }
        if (user?.username != nil) {
            emailLabel.text = user?.username
        }
        if(user?["number"] != nil){
            numberLabel.text = user?["number"] as? String
        }
        
        if (user?["profile_image"] != nil) {
            let userImageFile = user?["profile_image"] as! PFFile
            userImageFile.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError?) -> Void in
                if let error = error {
                    print(error.localizedDescription)
                }
                else {
                    let image = UIImage(data: imageData!)
                    self.profileImageView.image = image
                }
            })
        }
        
    }
    

}
