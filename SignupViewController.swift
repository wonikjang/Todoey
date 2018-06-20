//
//  SignupViewController.swift
//  InstagramLike
//
//  Created by Wonik Jang on 6/20/18.
//  Copyright © 2018 Jang&Kim. All rights reserved.
//

import UIKit
import Firebase

class SignupViewController: UIViewController,  UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPwField: UITextField!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nextBtn: UIButton!

    
    // Variable for picker
    let picker = UIImagePickerController()
    
    // Firebase Storage & Database - Step 1: Create Reference
    var userStorage: StorageReference!
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.delegate = self
        
        // Firebase Storage & Database - Step 2: Set up
        let storage = Storage.storage().reference(forURL: "gs://instagram-7b20c.appspot.com")
        userStorage = storage.child("users") // Create a folder in Storage
        
        ref = Database.database().reference()
        
        
    }
    
    
    @IBAction func selectimagePressed(_ sender: Any) {
        
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        
        present(picker, animated: true, completion: nil)
        
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.imageView.image = image
            nextBtn.isHidden = false
        }
        // After done, dismiss image picker window
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func nextPressed(_ sender: Any) {
        
        guard nameField.text != "", emailField.text != "", password.text != "", confirmPwField.text != "" else { return }
        
        if password.text == confirmPwField.text {
            Auth.auth().createUser(withEmail: emailField.text!, password: password.text!) { (user, error) in
                
                // if let v --> if v exists
                if let error = error {
                    print(error.localizedDescription)
                }
                
                if let user = user {
                    
                    // Change REquest
                    let changeRequest = Auth.auth().currentUser!.createProfileChangeRequest()
                    changeRequest.displayName = self.nameField.text!
                    changeRequest.commitChanges(completion: nil)
                    
                    
                    // *** Save image into Firebase ***
                    
                    // Step 1 : Get image file name
                    let imageRef = self.userStorage.child("\(user.user.uid).jpg")
                    
                    // Step 2 : Transfer image to data
                    let data = UIImageJPEGRepresentation(self.imageView.image!,  0.5)
                    
                    // Step 3 : Put data into Firebase
                    let uploadTask = imageRef.putData( data!, metadata: nil, completion: { (metadata, error) in
                        
                        if error != nil {
                            print(error!.localizedDescription)
                        }
                        
                        // Step 4 : Get the URL of uploaded picture
                        imageRef.downloadURL(completion: { (url, er) in
                            if er != nil {
                                print(error!.localizedDescription)
                            }
                            
                            if let url = url {
                                
                                let userInfo: [String : Any] = ["uid" : user.user.uid,
                                                                "full name" : self.nameField.text!,
                                                                "urlToImage" : url.absoluteString] // Firebase doesn't accept NSURL, so convert it
                                
                                self.ref.child("users").child(user.user.uid).setValue(userInfo)
                                
                                // Create User view
                                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "usersVC")
                                self.present(vc, animated: true, completion: nil)
                                
                                
                                
                            }
                            
                        })
                        
                        
                    })
                    
                    // Resume upload Task
                    uploadTask.resume()
                    
                }
                
                
            }
            
        } else {
            print("Password does not match!")
        }
        
        
    }
    
    



}
