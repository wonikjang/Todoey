//
//  PostCell.swift
//  InstagramLike
//
//  Created by Wonik Jang on 6/23/18.
//  Copyright © 2018 Jang&Kim. All rights reserved.
//

import UIKit
import Firebase

class PostCell: UICollectionViewCell {
    
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var likeLabel: UILabel!
    
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var unlikeBtn: UIButton!
    
    var postID: String!
    
    @IBAction func likePressed(_ sender: Any) {
        self.likeBtn.isEnabled = false
        
        let ref = Database.database().reference()
        let keyToPost = ref.child("posts").childByAutoId().key
        
        ref.child("posts").child(self.postID).observeSingleEvent(of: .value) { (snapshot) in
            
            if let post = snapshot.value as? [String : AnyObject] {
                let updateLikes: [String : Any] = ["peopleWhoLike/\(keyToPost)" : Auth.auth().currentUser!.uid]    // unique ID for that , Id of current user
                ref.child("posts").child(self.postID).updateChildValues(updateLikes, withCompletionBlock: { (error, reff) in
                    
                    if error == nil {
                        ref.child("posts").child(self.postID).observeSingleEvent(of: .value, with: { (snap) in
                        if let properties = snap.value as? [String : AnyObject] {
                        
                            // check how many peple likes
                            if let likes = properties["peopleWhoLike"] as? [String : AnyObject] {
                                let count = likes.count
                                self.likeLabel.text = "\(count) Likes"
                                
                                let update = ["likes" : count]
                                ref.child("posts").child(self.postID).updateChildValues(update)
                                
                                self.likeBtn.isHidden = true
                                self.unlikeBtn.isHidden = false
                                self.likeBtn.isEnabled = true
                                
                                }
                                
                            
                            }
                        })
                    }
                    
                })
                
            }
        }
        
        ref.removeAllObservers()
        
    }
    
    @IBAction func unlikePressed(_ sender: Any) {
        
        let ref = Database.database().reference()
        ref.child("posts").child(self.postID).observeSingleEvent(of: .value) { (snapshot) in
            
            if let properties = snapshot.value as? [String : AnyObject] {
                if let peopleWhoLike = properties["peopleWhoLike"] as? [String : AnyObject] {
                    for (id, person) in peopleWhoLike {
                        if person as? String == Auth.auth().currentUser!.uid {
                            
                            ref.child("posts").child(self.postID).child("peopleWhoLike").child(id).removeValue(completionBlock: { (error, reff) in
                                if error == nil {
                                    
                                    // Give new property and update like
                                    ref.child("posts").child(self.postID).observeSingleEvent(of: .value, with: { (snap) in
                                        if let prop = snap.value as? [String : AnyObject] {
                                            if let likes = prop["peopleWhoLike"] as? [String : AnyObject] {
                                                let count = likes.count
                                                self.likeLabel.text = "\(count) Likes"
                                                ref.child("posts").child(self.postID).updateChildValues(["likes" : count])
                                                
                                            } else {
                                                self.likeLabel.text = "0 Likes"
                                                ref.child("posts").child(self.postID).updateChildValues( ["likes" : 0] )
                                            }
                                            
                                        }
                                    })
                                    
                                    
                                }
                            })
                            // Stop after find persons
                            self.likeBtn.isHidden = false
                            self.unlikeBtn.isHidden = true
                            self.unlikeBtn.isEnabled = true
                            
                            break
                            
                            
                        }
                        
                        
                    }
                    
                    
                }
                
                
            }
            
        }
        
        ref.removeAllObservers()
        
    }
    
}
