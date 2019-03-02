//
//  ProfileViewController.swift
//  Parstagram
//
//  Created by Hermain Hanif on 2/19/19.
//  Copyright © 2019 Hermain Hanif. All rights reserved.
//

import UIKit
import Parse
import AlamofireImage



class ProfileViewController: UIViewController {

//    @IBOutlet var profileTableView: UITableView!
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userProfLanbel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        

        // Do any additional setup after loading the view.
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadProfile()
    }
    
    func loadProfile() {
        let query = PFQuery(className:"Profile")
        
        query.includeKey("profile_user_name")
        query.includeKey("createdAt")
        query.whereKey("profile_user_name", equalTo:
            PFUser.current()!)
        query.addDescendingOrder("createdAt")
        //once configured, go do it
//        userProfLanbel.text = PFUser.current()! as? String
        userProfLanbel.text = PFUser.current()!.username
        // get query, store data, reload table view
        //fetch the posts/find the posts/get the posts
        query.findObjectsInBackground { (profile, error) in
            // if posts find something
            if profile != nil {
                
                for p in profile! {
                    print(p["created_at"])
                }
                
                self.setProfileImage(profile: profile!)
            }
        }
    }
    
    func setProfileImage(profile: [PFObject]) {
        let profile = profile[0]["profile_image"] as! PFFileObject
        let urlString = profile.url!
        let url = URL(string: urlString)!
        
        profileImage.af_setImage(withURL: url)
        
    }

//    func setProfileName( profile: [PFObject] ){
//        userProfLanbel.text = profile[0]["pprofile_user_name"]![0].username
//    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
