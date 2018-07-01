//
//  DrawViewController.swift
//  InstagramLike
//
//  Created by Wonik Jang on 7/1/18.
//  Copyright © 2018 Jang&Kim. All rights reserved.
//

import UIKit
import Firebase

class DrawViewController: UIViewController {

    var picArray = [UIImage]()
    
    @IBOutlet weak var drawImage: UIImageView!
    

    let ref = Database.database().reference()
    let storage = Storage.storage().reference(forURL: "gs://instagram-7b20c.appspot.com")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
//        // Upload image to 1. Storage & 2. Database with 1 image
//
//        let key = ref.child("draws").childByAutoId().key
//        let tempImageRef = storage.child("draws/animal/tree.jpeg")
//
//        let image = UIImage(named: "tree.jpeg")
//        let metadata = StorageMetadata()
//        metadata.contentType = "image/jpeg"
//
//        let uploadTask = tempImageRef.putData(UIImageJPEGRepresentation(image!, 0.8)!, metadata: metadata, completion: { (data, error) in
//
//            // 1. Save in storage
//            if error != nil {
//                print(error?.localizedDescription)
//
//            }
//            tempImageRef.downloadURL(completion: { (url, error) in
//
//                if let url = url {
//
//                    let drawsInfo = ["fileName" : "tree.jpeg",
//                                     "pathToImage" : url.absoluteString]
//
//
////                    let drawsImage = ["elephant.jpeg" : url.absoluteString ]
//                    let drawsImage = ["\(key)" : drawsInfo ]
//
//                    ref.child("draws").child("animal").updateChildValues(drawsImage)
//
//                    self.dismiss(animated: true, completion: nil)
//                } else {
//                    print("url retrieve failed!")
//                }
//
//            })
//
//
//        })
//        uploadTask.resume()
        

            fetchDraws()
        
        }
    
    
    
    func fetchDraws() {
        
        let ref = Database.database().reference()
        
        ref.child("draws").child("animal").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            
            let draws = snapshot.value as! [String : AnyObject]
            
            for (_, value) in draws { // value == AnyObject
                if let pathToImage = value["pathToImage"] as? String{
                    
                    // Create a storage reference from the URL
//                    let imageRef = storage.child("posts").child(uid).child("\(key).jpg")
                    
                    let storageRef = Storage.storage().reference(forURL: pathToImage)
//                    let storageRef = storage.referenceFromURL(pathToImage)
        
                    storageRef.getData(maxSize: 1*1024*1024) { (data, error) in
                    if error != nil {
                        print(error?.localizedDescription)
                    } else {
                        print(data)
                        self.drawImage.image = UIImage(data: data!)
                    }
                        
                        
//                    // Download the data, assuming a max size of 1MB (you can change this as necessary)
//                    storageRef.getData(maxSize: 1 * 1024 * 1024) { (data, error) -> Void in
//
//                    // Create a UIImage, add it to the array
//                    let pic = UIImage(data: data!)
//                    self.picArray.append(pic!)
                    
                    
                    }
                    
                }
                
            }
            
        })
        ref.removeAllObservers()
     
        
    }
        
            
                    
                    
        
//        // *** Retreive multiple image from a folder in storage *** //
//
//        let dbRef = ref.child("draws/animal/")
//        dbRef.observe(.childAdded, with: { (snapshot) in
//            // Get download URL from snapshot
//            let downloadURL = snapshot.value as! String
//
//            // Create a storage reference from the URL
//            let storageRef = storage.referenceFromURL(downloadURL)
//            // Download the data, assuming a max size of 1MB (you can change this as necessary)
//            storageRef.dataWithMaxSize(1 * 1024 * 1024) { (data, error) -> Void in
//                // Create a UIImage, add it to the array
//                let pic = UIImage(data: data)
//                picArray.append(pic)
//            };)
//        })
        
        
        
        // *** Retrieve one image from storage when data is stored in Firebase **** //
        
//        let tempImageRef = storage.child("draws/animal/elephant.jpeg")
//
//        tempImageRef.getData(maxSize: 1*1000*1000) { (data, error) in
//            if error != nil {
//                print(error?.localizedDescription)
//            } else {
//                self.imageViewer.image = UIImage(data: data!)
//
//
//                print(data)
//            }
//        }
        
        
//    }



}
