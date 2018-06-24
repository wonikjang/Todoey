//
//  FeedViewController.swift
//  InstagramLike
//
//  Created by Wonik Jang on 6/23/18.
//  Copyright © 2018 Jang&Kim. All rights reserved.
//

import UIKit
import Firebase

class FeedViewController: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionview: UICollectionView!
    
    var posts = [Post]()
    var following = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchPosts()

    }

    func fetchPosts(){
        
        let ref = Database.database().reference()
        
        ref.child("users").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            
            let users = snapshot.value as! [String : AnyObject]
            
            for (_, value) in users { // value == AnyObject
                if let uid = value["uid"] as? String {
                    if uid == Auth.auth().currentUser?.uid {
                        if let followingUsers = value["following"] as? [String : String]{
                            for (_, user) in followingUsers {
                                self.following.append(user)
                            }
                            
                            
                        }
                        // Want to see myself posts
                        self.following.append(Auth.auth().currentUser!.uid)
                        
                        ref.child("posts").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snap) in
                            
                            let postsSanp = snap.value as! [String : AnyObject]
                            
                            for (_, post) in postsSanp {
                                if let userID = post["userID"] as? String {
                                    for each in self.following {
                                        if each == userID {
                                            let posst = Post()
                                            if let author = post["author"] as? String, let likes = post["likes"] as? Int, let postToImage = post["pathToImage"] as? String,
                                                let postID = post["postID"] as? String {
                                                
                                                posst.author = author
                                                posst.likes = likes
                                                posst.pathToImage = postToImage
                                                posst.postID = postID
                                                posst.userID = userID
                                                
                                                if let people = post["peopleWhoLike"] as? [String : AnyObject] {
                                                    for (_,person) in people {
                                                        posst.peopleWhoLike.append(person as! String)
                                                        
                                                        
                                                    }
                                                    
                                                }
                                                
                                                self.posts.append(posst)
                                            }
                                            
                                            
                                        }
                                        
                                        
                                    }
                                    // After for loop is ended
                                    self.collectionview.reloadData()
                                    
                                    
                                }
                                
                            }
                            
                            
                        })
                        
                    }
                
                }
            }
            
        })
        ref.removeAllObservers()
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1 // Section of Post
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "postCell", for: indexPath) as! PostCell
        
        // Write a code for creating the cell
        
        cell.postImage.downloadImage(from: self.posts[indexPath.row].pathToImage)
        cell.authorLabel.text = self.posts[indexPath.row].author
        cell.likeLabel.text = "\(self.posts[indexPath.row].likes!) Likes"
        
        cell.postID = self.posts[indexPath.row].postID
        
        return cell
    }
    
    

}
