//
//  AppDelegate.swift
//  PolyPocket_1018
//
//
//  Created by HayoungKim on 18/10/2018.
//  Copyright © 2018 JangnKim. All rights reserved.
//

// Firebase related To-Do-List
// 1. User ID --> 작업중인 fName있는지
// 2. CategoryName, Index, fileName, CollectionName

import UIKit

import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    // UID 1 : To save uid into UserDefaults
    let defaults = UserDefaults.standard
    var uidString = String()
    var userFnameArrFB = [String]()
    
    // Database 1.1 Category : To save Firebase related items in advance
    var categoryNamesArrFB = [String]()
    var categoryIndexArrFB = [Int]()
    var adIndexArrFB = [Int]()
    var categoryImageNameArrFB = [[String]]()

    // Database 1.2 Cllection
    var collectionNamesArrFB = [String]()
    var collectionIndexArrFB = [Int]()
    var collectionImageNameArrFB = [[String]]()
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Firebase Authentication
        FirebaseApp.configure()
        
        // Local File Saving Path
        print("=== Local Path URL === ")
//        let pathComponent = "test.mp4"
//        let directoryURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//        let folderPath: URL = directoryURL.appendingPathComponent("Downloads", isDirectory: true)
//        let fileURL: URL = folderPath.appendingPathComponent(pathComponent)
//        
//        print(fileURL )
//        print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last! as String )
        
        
        
        // UID 2.1 : Check user ID
        checkLoggedINUserStatus()
        // UID 2.2 : Call Saved uid from UserDefault
        uidString = defaults.object(forKey: "userId") as? String ?? String()
        print("uidString  : ",uidString)
        // UID 2.3 : Get fnames that user touched
        
        checkFnameOfUser(userID: uidString){ (userFnameArr) in
            self.userFnameArrFB = userFnameArr
        }
        
        
        
        // Display Launch Screen
        self.splashScreen()
        
        // Database 2.1 : Category related files loading
        loadCategoryFireBase{ (categoryNamesArr, totalIndexArr, adIndexArr, imageNameArr ) in
            
            self.categoryNamesArrFB = categoryNamesArr
            self.categoryIndexArrFB = totalIndexArr
            self.adIndexArrFB = adIndexArr
            self.categoryImageNameArrFB = imageNameArr
                        
        }
        // Database 2.2 : Collection related files loading
        loadCollectionFireBase{ (collectionNamesArr, collectionIndexArr, collectionImageNameArr ) in
            self.collectionNamesArrFB = collectionNamesArr
            self.collectionIndexArrFB = collectionIndexArr
            self.collectionImageNameArrFB = collectionImageNameArr
        }
        
        
        
        
        return true
    }
    
    
    
    func loadCategoryFireBase(completion: @escaping ( Array<String>, Array<Int>, Array<Int>, Array<Array<String>> ) -> Void ) {
        
        var categoryNamesArr = [String]()
        var categoryIndexArr = [Int]()
        var adIndexArr = [Int]()
        var categoryImageNameArr = [[String]]()
        
        // Category related
        let CategoryRef = Database.database().reference().child("objects").child("category")
        CategoryRef.observe(.value, with: { snapshot in
            
            for child in snapshot.children {
                    
                let snap = child as! DataSnapshot
                categoryNamesArr.append(snap.key)
                
                let snapDict = snap.value as! NSDictionary
                
                // 1.2. index save --> Sort
//                totalIndexArr.append( (snapDict["index"]! as! NSString).integerValue )
                categoryIndexArr.append( (snapDict["index"]! as! NSString ).integerValue )

                // 1.3. ad == TRUE --> index 를 adIndexArr 에 append
                if snapDict["ad"]! as! String == "TRUE" {

                    let adInt = (snapDict["index"]! as! NSString).integerValue
                    adIndexArr.append( adInt )

                    // *** adImg도 불러서 저장?
                }

                // 1.4. Loop over fname
                categoryImageNameArr.append( snapDict["fName"]! as! [String] )
                
            }
            completion(categoryNamesArr, categoryIndexArr, adIndexArr, categoryImageNameArr )
        })
    }
    
    func loadCollectionFireBase(completion: @escaping ( Array<String>, Array<Int>, Array<Array<String>> ) -> Void ) {
    
        var collectionNamesArr = [String]()
        var collectionIndexArr = [Int]()
        var collectionImageNameArr = [[String]]()
        
        // Collection related
        let CollectionRef = Database.database().reference().child("objects").child("collection")
        CollectionRef.observe(.value, with: { snapshot in
            
            for child in snapshot.children {
                
                let snap = child as! DataSnapshot
                collectionNamesArr.append(snap.key)
                
                let snapDict = snap.value as! NSDictionary
                
                // 1.2. index save --> Sort
                //                totalIndexArr.append( (snapDict["index"]! as! NSString).integerValue )
                collectionIndexArr.append( (snapDict["index"]! as! NSString ).integerValue )

                // 1.4. Loop over fname
                collectionImageNameArr.append( snapDict["fName"]! as! [String] )
            }
            completion(collectionNamesArr, collectionIndexArr, collectionImageNameArr )
        })
        
    }
 
    private func splashScreen(){
        
        let launchScreenVC = UIStoryboard.init(name: "LaunchScreen", bundle: nil)
        let rootVC = launchScreenVC.instantiateViewController(withIdentifier: "splashController")
        self.window?.rootViewController = rootVC
        self.window?.makeKeyAndVisible()
        
        Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(dismissSplashController), userInfo: nil, repeats: false)
        
    }
    
    @objc func dismissSplashController(){
        
        let mainVC = UIStoryboard.init(name: "Main", bundle: nil)
        let rootVC = mainVC.instantiateViewController(withIdentifier: "initController")
        
        self.window?.rootViewController = rootVC
        self.window?.makeKeyAndVisible()
        
    }
    
    
    fileprivate func checkLoggedINUserStatus(){
        if Auth.auth().currentUser == nil {
            print("===== auth user is nil !!!")
            DispatchQueue.main.async {
    
                // 1. Create a uid in UserDefault
                
                Auth.auth().signInAnonymously { (user, err) in
                    if let err = err {
                        print("Failed to log in Anonymously with error", err)
                        return
                    }
                    self.uidString = (user?.user.uid)!
                    self.defaults.set((user?.user.uid)!, forKey: "userId")
                }
                
                
                // 2. Create a uid in Database

                var userStorage: StorageReference!
                var ref: DatabaseReference!
                
                let storage = Storage.storage().reference(forURL: "gs://polypocketfirebase.appspot.com")
                userStorage = storage.child("users") // Create a folder in Storage
                ref = Database.database().reference()
                
                let userInfo = ["uid" : self.uidString ]
                ref.child("users").child(self.uidString).setValue(userInfo)

            }
        }else{
            
            uidString = self.defaults.object(forKey: "userId") as? String ?? String()

            return
            
        }
    }
    
    func checkFnameOfUser(userID: String, completion: @escaping ( Array<String> ) -> Void ) {

        var fNameOfUser = [String]()
        var ref: DatabaseReference!
        ref = Database.database().reference().child("users").child(userID).child("fName")

        ref.observe(.value, with: { snapshot in
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                fNameOfUser.append(snap.key)
            }
            completion(fNameOfUser)
        })
    }
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
//        for window in application.windows {
//            print("************** window Background: ",window)
//            window.rootViewController?.beginAppearanceTransition(false, animated: false)
//            window.rootViewController?.endAppearanceTransition()
//        }
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
//        for window in application.windows {
//            print("************** window Background: ",window)
//            window.rootViewController?.beginAppearanceTransition(false, animated: false)
//            window.rootViewController?.endAppearanceTransition()
//        }
        
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
//        for window in application.windows {
//            print("************** window Foreground: ",window)
//            window.rootViewController?.beginAppearanceTransition(false, animated: false)
//            window.rootViewController?.endAppearanceTransition()
//        }
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//        for window in application.windows {
//            print("************** window Foreground: ",window)
//            window.rootViewController?.beginAppearanceTransition(false, animated: false)
//            window.rootViewController?.endAppearanceTransition()
//        }
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

