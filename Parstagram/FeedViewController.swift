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
import MessageInputBar

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    let commentBar = MessageInputBar() 
    var showsCommentBar = false
    
    var posts = [PFObject]()
    var selectedPost: PFObject!
    var numPosts: Int! = 20
    
    let myRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentBar.inputTextView.placeholder = "Add a comment..."
        commentBar.sendButton.title = "Post"
        commentBar.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.keyboardDismissMode = .interactive
        // dismiss keyboard by just dragging on table view
        
        myRefreshControl.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        tableView.refreshControl = myRefreshControl

        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name:
            UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillBeHidden( note: Notification ) {
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
    }
    
    // these two functions make the comment bar
    override var inputAccessoryView: UIView? {
        return commentBar
    }
    
    override var canBecomeFirstResponder: Bool {
        // has ability to show this, but not all the time by default
        return showsCommentBar
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // refreshes table view so pulls that post you just created
        super.viewDidAppear(animated)
        getPosts()

    }
    
    
    func getPosts() {
        let query = PFQuery(className:"Posts")
        query.addDescendingOrder("createdAt")
        // need these so can find objects being pointed at when referring them, post realte to user-author, post realte to comments,
            // comments relate to user-author
        // need for relationship references
        query.includeKeys(["author", "comments", "comments.author"])
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
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        // Create the comment
        let comment = PFObject(className: "Comments")
            // attributes of comments:
        comment["text"] = text
        //know which post comment belongs to:
        comment["post"] = selectedPost
        // know who created comment:
        comment["author"] = PFUser.current()!

        // Relationship Magic:
        selectedPost.add(comment, forKey: "comments")
        // comments: every post should have an array called comments, and like to add this comment to array

        //once added comment,to post, save post
        // when Parse saves post, realizes needs to save comment, so saves comment too
        selectedPost.saveInBackground { (success, error) in
            if success {
                print( "Comment saved!" )
            }
            else {
                print( "Error saving comment" )
            }
        }
        
        tableView.reloadData()
        
        // Clear and dismiss the input bar
        commentBar.inputTextView.text = nil
        
        showsCommentBar = false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
    }
    
    // number of rows in each section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //number of comments + 1 ( for actual post row)
        // for the actual post is just 1
        
        //to get post
        let post = posts[section]
        // get comments
        // so ?? saying if thing on left is nil, set it to [], so ? when comments clicked gone cause now for sure array
        // ??: convinient way of expressing default values
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        return comments.count + 2
    }
    
    // each post has own section, and each section can have different number of rows
    // as many sections as posts, number of posts = number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        // how tell post cell:
        // always for each cell using each row, post is always first
        if indexPath.row == 0 {
        
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
            
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
        } else if indexPath.row <= comments.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            // -1 because after find post row is at 1, but need first thing in array, starting with 0, and then going through
            let comment = comments[indexPath.row - 1]
            cell.commentLabel.text = comment["text"] as? String
                // always cast when coming from dictionary
            
            let user = comment["author"] as! PFUser
            cell.nameLabel.text = user.username
            
            return cell
        } else {
            // dont need custom cell cause not modifying
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!
            
            return cell
        }
    }
    
    // every time user taps and cell/row selected, this function called back here
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // choose a post to add a comment
        // this is the row that was selected
        // they gave indexPath, and u know/say the post
        let post = posts[indexPath.section]
        
        // will create table for Comments in Parse so now can have Comment objects
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        if indexPath.row == comments.count + 1 {
            showsCommentBar = true
            becomeFirstResponder()
            // call this again, cause functions to be reveluated and value gets changed to true
                // so comment bar shows
            commentBar.inputTextView.becomeFirstResponder()
            // raise keyboard
            
            selectedPost = post
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func onLogoutButton(_ sender: Any) {
       // clears parse cache, so in parse's perspective, not logged in anymore
        PFUser.logOut()
        
        //so now switch user back into login screen
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController")
        
        //one object that is shared for each application
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.window?.rootViewController = loginViewController
        
    }
    

}
