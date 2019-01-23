//
//  SubscribeViewController.swift
//  PolyPocket_1018
//
//  Created by Wonik Jang on 1/1/19.
//  Copyright © 2019 JangnKim. All rights reserved.
//

import UIKit

import Firebase
import FirebaseCore

import FirebaseDatabase
import FirebaseStorage

class SubscribeViewController: UIViewController {

    let delegate = UIApplication.shared.delegate as! AppDelegate
    let defaults = UserDefaults.standard
    var userID = String()
    
    var tableView: TableViewController?
    
    var subscribeType = String()
    
    @IBAction func Weekly(_ sender: UIButton) {
        subscribeType = sender.title(for: .normal)!
        print("subscribeType :  ", subscribeType)
        
        // MARK: - 현재는 누르면 구독한것으로 가정, 추후에는 실제 돈 지불했을 경우 함수 돌아가게 하는 것으로 !!
        subscribeUpdateInfo(subscribePressed: subscribeType)
    }
    
    @IBAction func Monthly(_ sender: UIButton) {
        subscribeType = sender.title(for: .normal)!
        print("subscribeType :  ", subscribeType)
        subscribeUpdateInfo(subscribePressed: subscribeType)
    }
    
    @IBAction func Yearly(_ sender: UIButton) {
        subscribeType = sender.title(for: .normal)!
        print("subscribeType :  ", subscribeType)
        subscribeUpdateInfo(subscribePressed: subscribeType)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userID = delegate.uidString
        
        view.backgroundColor = UIColor.white
        
        print(" Entered into SubscribeViewController !!! ")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
     
        // MARK: - Assumption1: Subscription Button is clicked & purchase : Backend
   
    }
    
    func subscribeUpdateInfo(subscribePressed: String ){
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy HH:mm:ss"
        let currentDateTime = Date()
        let currentDateTimeString = dateFormatter.string(from: currentDateTime)

        // =============== 1. Update Subscriptino info to Fireabsae & UserDefaults
        // === 1.1. Update to Firebase
        let ref = Database.database().reference()
//        let subscribeInfo: [String:String] = [subscribePressed:currentDateTimeString]
        let subscribeInfo = ["type" : subscribePressed, "time" : currentDateTimeString] as [String : Any]
        ref.child("users").child("\(userID)").child("subscribe").updateChildValues(subscribeInfo)
        
        
        // === 1.2. Update to Documents
        let subscribeInUserDefaults: [String:String] = ["type": subscribePressed,"time":currentDateTimeString]
        defaults.set(subscribeInUserDefaults, forKey: "subscribe")
        
        // Get subscribe informationi from UserDefaults
        let subscribeInUserDefaultsGet =  defaults.object(forKey: "subscribe") as? [String : Any]
        print("   subscribeInUserDefaultsGet  type : ", subscribeInUserDefaultsGet!["type"]! )
        print("   subscribeInUserDefaultsGet  time : ", subscribeInUserDefaultsGet!["time"]! )
        
        
        // =============== 2. Unlock AdCategory & Remove All Advertise
        // === 2.1. Update to Unlock all AdCategory
        // == adIndexArr 를 Empty 로 만들어주기
        delegate.adIndexArrFB.removeAll()
        print("delegate.adIndexArrFB  :  ", delegate.adIndexArrFB)

        delegate.subscribeTemp = true

        
//        tableView!.adIndexArr.removeAll()
//        print("tableView.adIndexArr  :  ", tableView!.adIndexArr)
        // === 2.2. Remove All Advertise

        
        // === dismiss current view
//        let tablevc = self.storyboard?.instantiateViewController(withIdentifier: "TableViewController") as? TableViewController
//        self.navigationController?.pushViewController(tablevc!, animated: true)
        
        dismiss(animated: true, completion: nil)
        
        
    }
    
    
    

}
