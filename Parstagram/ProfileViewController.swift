//
//  ProfileViewController.swift
//  Parstagram
//
//  Created by Hermain Hanif on 2/18/19.
//  Copyright © 2019 Hermain Hanif. All rights reserved.
//

import UIKit
import AlamofireImage
import Parse

class ProfileViewController: UIViewController {

    @IBOutlet weak var profileTabImageView: UIImageView!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageFile = post["image"] as! PFFileObject
        let urlString = imageFile.url!
        let url = URL(string: urlString)!
        
        profileTabImageView.af_setImage(withURL: url)

        // Do any additional setup after loading the view.
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
