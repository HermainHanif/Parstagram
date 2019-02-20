//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Hermain Hanif on 2/17/19.
//  Copyright © 2019 Hermain Hanif. All rights reserved.
//

import UIKit
import Parse
import AlamofireImage

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var posts = [PFObject]()
    var numPosts: Int! = 20
    
    let myRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        myRefreshControl.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        tableView.refreshControl = myRefreshControl

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // refreshes table view so pulls that post you just created
        super.viewDidAppear(animated)
        getPosts()

    }
    
    
    func getPosts() {
        let query = PFQuery(className:"Posts")
        query.addDescendingOrder("createdAt")
        query.includeKey("author")
        query.limit = numPosts
        //once configured, go do it
        
        // get query, store data, reload table view
        //fetch the posts/find the posts/get the posts
        query.findObjectsInBackground { (posts, error) in
            // if posts find something
            if posts != nil {
                // when find posts, put in self.posts
                self.posts = posts!
                //tell table view to reload for posts found by calling functions below
                self.tableView.reloadData()
                //                self.myRefreshControl.endRefreshing()
            }
        }
    }
    
    
    
    @objc func onRefresh() {
        getPosts()
        myRefreshControl.endRefreshing()
        
    }
    
    func loadMorePosts(){
        
        numPosts = numPosts + 2
        getPosts()
    }

     func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == posts.count {
            loadMorePosts()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
        
        let post = posts[indexPath.row]
        
        let user = post["author"] as! PFUser
        cell.usernameLabel.text = user.username
        
        if cell.captionLabel.text != nil {
            cell.captionLabel.text = post["caption"] as! String
        } else {
            cell.captionLabel.text = ""
            cell.usernameLabel.text = ""
        }
        
        let imageFile = post["image"] as! PFFileObject
        let urlString = imageFile.url!
        let url = URL(string: urlString)!
        
        cell.photoView.af_setImage(withURL: url)
        
        return cell
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
