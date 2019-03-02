//
//  ProfileCameraViewController.swift
//  Parstagram
//
//  Created by Hermain Hanif on 2/24/19.
//  Copyright © 2019 Hermain Hanif. All rights reserved.
//

import UIKit
import AlamofireImage
import Parse

class ProfileCameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var profileImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func submitProfilePic(_ sender: Any) {
        let profile = PFObject(className: "Profile")
        
        profile["profile_user_name"] = PFUser.current()!
        let imageProfileData = profileImageView.image!.pngData()
        let profileFile = PFFileObject(data: imageProfileData!)

        profile["profile_image"] = profileFile
        
        profile.saveInBackground { (success, error) in
            if success {
                self.dismiss(animated: true, completion: nil)
                print("saved post!")
            } else {
                print("error!")
            }
        }
        
        
    }
    
    @IBAction func clickCameraButton(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        // when user done picking photo, let me know what they took, and call me back on function that has photo
        picker.allowsEditing = true
        // allows second screen to come up to allow editing on photo
        
        // if camera available
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        } else {
            picker.sourceType = .photoLibrary
        }
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as! UIImage
        
        let size = CGSize(width: 300, height: 300)
        let scaledImage = image.af_imageAspectScaled(toFill: size)
        
        profileImageView.image = scaledImage
        
        dismiss(animated: true, completion: nil)
        // dismiss that camera view
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
