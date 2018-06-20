//
//  LoginViewController.swift
//  InstagramLike
//
//  Created by Wonik Jang on 6/20/18.
//  Copyright © 2018 Jang&Kim. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {


    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var pwField: UITextField!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        
        guard emailField.text != "", pwField.text != "" else { return }
        
        Auth.auth().signIn(withEmail: emailField.text!, password: pwField.text!) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            
            if let user = user {
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "usersVC")
                self.present(vc, animated: true, completion: nil)
            }
            
            
        }
        
    }
    
    


  

}
