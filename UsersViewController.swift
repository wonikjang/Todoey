//
//  UsersViewController.swift
//  InstagramLike
//
//  Created by Wonik Jang on 6/20/18.
//  Copyright © 2018 Jang&Kim. All rights reserved.
//

import UIKit
import Firebase

class UsersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableview: UITableView!
    
    var user = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        retrieveUsers()
    }
    
    func retrieveUsers() {
        let ref = Database.database().reference()
        ref.child("users").queryOrderedByKey().observeSingleEvent(of: .value) { ( snapshot ) in
            
            let users = snapshot.value as! [String : AnyObject]
            self.user.removeAll()
            
            for (_, value) in users {
                
                if let uid = value["uid"] as? String {
                    if uid != Auth.auth().currentUser!.uid{
                        let userToShow = User()
                        if let fullName = value["full name"] as? String, let imagePath = value["urlToImage"] as? String{
                            userToShow.fullName = fullName
                            userToShow.imagePath = imagePath
                            userToShow.userID = uid
                            self.user.append(userToShow)
                        }
                        
                    }
                }
                
            }
            
            self.tableview.reloadData()
            
        }
        ref.removeAllObservers()
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserCell
        
        cell.nameLabel.text = self.user[indexPath.row].fullName
        cell.userID = self.user[indexPath.row].userID
        cell.userImage.downloadImage(from: self.user[indexPath.row].imagePath!)
        checkFollowing(indexPath: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return user.count ?? 0
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let uid = Auth.auth().currentUser!.uid
        let ref = Database.database().reference()
        let key = ref.child("users").childByAutoId().key
        
        var isFollower = false
        ref.child("users").child(uid).child("following").queryOrderedByKey().observeSingleEvent(of: .value) { (snapshot) in
            
            if let following = snapshot.value as? [String : AnyObject] {
                
                for (ke, value) in following {
                    if value as! String == self.user[indexPath.row].userID { // following in database == selected user
                        // Unfollow
                        isFollower = true
                        ref.child("users").child(uid).child("following/\(ke)").removeValue()
                        ref.child("users").child(self.user[indexPath.row].userID).child("followers/\(ke)").removeValue()
                        
                        self.tableview.cellForRow(at: indexPath)?.accessoryType = .none
                    }
                    
                }
                
            }
            
            // Follow as user has no followers
            if !isFollower {
                let following = ["following/\(key)" : self.user[indexPath.row].userID]
                let followers = ["followers/\(key)" : uid ]
                
                ref.child("users").child(uid).updateChildValues(following)
                ref.child("users").child(self.user[indexPath.row].userID).updateChildValues(followers)
                
                self.tableview.cellForRow(at: indexPath)?.accessoryType = .checkmark
            }
            
            
            
            
        }
        
        ref.removeAllObservers()
        
    }
    
    func checkFollowing(indexPath: IndexPath) {
        let uid = Auth.auth().currentUser!.uid
        let ref = Database.database().reference()
        
        ref.child("users").child(uid).child("following").queryOrderedByKey().observeSingleEvent(of: .value) { (snapshot) in
            
            if let following = snapshot.value as? [String : AnyObject] {
                
                for (ke, value) in following {
                    if value as! String == self.user[indexPath.row].userID { // following in database == selected user
                        self.tableview.cellForRow(at: indexPath)?.accessoryType = .checkmark
                        
                }
            }
        }
        ref.removeAllObservers()
                    
                    
    }
        
    }
    
    @IBAction func logOutPressed(_ sender: Any) {
    }
    
    
}

extension UIImageView {
    
    func downloadImage(from imgURL: String!){
        let url = URLRequest(url: URL(string: imgURL)!)
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!)
                return
            }
            
            // Run in MainQue
            DispatchQueue.main.async{
                self.image = UIImage(data: data!)
            }
            
        }

        task.resume()
        
    }
}


