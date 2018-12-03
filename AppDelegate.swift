//
//  AppDelegate.swift
//  PolyPocket_1018
//
//
//  Created by HayoungKim on 18/10/2018.
//  Copyright © 2018 JangnKim. All rights reserved.
//

// Firebase related To-Do-List
// 1. User ID
// 2. CategoryName, Index, fileName, CollectionName

import UIKit

import Firebase
import FirebaseCore

import FirebaseDatabase
import FirebaseStorage

class fNameTime  {
    var fName = String()
    var Time = Date()
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var uidString = String()
    // UID 1 : To save uid into UserDefaults
    let defaults = UserDefaults.standard
    
    // Database 1 : To save Firebase related items in advance
    var categoriesNameArrFB = [String]()
    var totalIndexArrFB = [Int]()
    var adIndexArrFB = [Int]()
    var imageNameArrFB = [[String]]()
    
    var userPaidAdFB = [String]()
    
    var adImageDictFB = [ String : UIImage ]()
    var twoDimImageDictFB = [ String : UIImage ]()
    
//    var newFnameFB = [[String]]()
    var newIndexFB = [(Int, Int)]()
    
    var listenHnadler: AuthStateDidChangeListenerHandle?
    
//    var ref:  DatabaseReference! = Database.database().reference()
    
    var userIdString = String()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Firebase Configure
        FirebaseApp.configure()
        
        // Print Docunent Directory ( Local File Saving Path )
        print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last! as String )


//        uidString = defaults.object(forKey: "userId") as? String ?? String()
//        print("uidString  : ",uidString)
        
        // Load Ad related
        
        
        // Launch Screen
        print("============== splashScreen starts !!! ")
        self.splashScreen()
        print("============== splashScreen ends !!! ")
        
        return true
    }
    
    
    @objc func dismissSplashController(){
        
        let mainVC = UIStoryboard.init(name: "Main", bundle: nil)
        let rootVC = mainVC.instantiateViewController(withIdentifier: "initController")
        
        self.window?.rootViewController = rootVC
        self.window?.makeKeyAndVisible()
        
    }

    
    
    func checkUserPaidAd(completion: @escaping (Array<String>)-> Void ){
        
        var paidAdArray = [String]()
        let refUserPaidAd = Database.database().reference().child("users").child("\(uidString)")
        refUserPaidAd.child("paidAd").observe(.value, with: { snapshot in

            if snapshot.exists(){
                print("ad snapshot exist !!! ")
                for paidAdItem in snapshot.children{
                    let paidAdName = paidAdItem as! DataSnapshot
                    paidAdArray.append(paidAdName.key)
                }
            }
            completion(paidAdArray)

        })
    }

//    func loadNameIndexFireBase(userPaidAdArray: [String] , completion: @escaping ( Array<String>, Array<Int>, Array<Int>, Array<Array<String>>, Array<Array<String>> ) -> Void ) {
    func loadNameIndexFireBase(userPaidAdArray: [String] , completion: @escaping ( Array<String>, Array<Int>, Array<Int>, Array<Array<String>>, Array<(Int, Int)> ) -> Void ) {

        // Overall necessary components
        var categoryNamesArr = [String]()
        var totalIndexArr = [Int]()
        var adIndexArr = [Int]()
        var imageNameArr = [[String]]()
//        var newFname = [[String]]()
        var newIndex = [(Int, Int)]()

        
        let refCat = Database.database().reference().child("objects").child("category")
        refCat.observe(.value, with: { snapshot in

//            for child in snapshot.children {
            for ( idx, child) in snapshot.children.enumerated() {
                print("idx : " , idx)

                var paidAdBool = true

                let snap = child as! DataSnapshot
                categoryNamesArr.append(snap.key)

                // check User PaidAd
                if userPaidAdArray.contains(snap.key){
                    paidAdBool = false
                }
                print("paidAdBool : ", paidAdBool)
                
                let snapDict = snap.value as! NSDictionary

                // 1.2. index save --> Sort
                totalIndexArr.append( (snapDict["index"]! as! NSString ).integerValue )

                // 1.3. ad == TRUE --> index 를 adIndexArr 에 append
//                if snapDict["ad"]! as! String == "TRUE" {
                if snapDict["ad"]! as! String == "TRUE" &&  paidAdBool {

                    let adInt = (snapDict["index"]! as! NSString).integerValue
                    adIndexArr.append( adInt )
                }
                
                // 1.4. Loop over fname
                
                // === ************** Original Code
                //                imageNameArr.append( snapDict["fName"]! as! [String] )
                
                
                // === ************** Revised Code *************** === //

                // *** 1. Reorder fName by Time
                var observedDict = snapDict["fName"]! as? Dictionary<String, AnyObject>
                
                // 01. key : 값을 따로 저장
                var observedDictKey = Array((observedDict?.keys)!)
                print(" 1st observedDictKey " , observedDictKey)
                
                // 02. value : 시간을 Integer로 전환 하는 코드 필요 !
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/yy HH:mm" // Excel 올릴때의 형식에 맞춰서 !
                var dateObjects = observedDict?.values.compactMap { dateFormatter.date(from: $0 as! String) }
                print(" 1st dateObjects " , dateObjects!)
                
                // 03. Sort key by value
                let sorted = zip(dateObjects!, observedDictKey).sorted { $0.1 > $1.1 }
                observedDictKey = sorted.map { $0.1 }
                
//                dateObjects = sorted.map { $0.0 }
                dateObjects = dateObjects!.sorted(by: { $0.compare($1) == .orderedDescending })
                print(" 2nd observedDictKey " , observedDictKey)
                print(" 2nd dateObjects " , dateObjects!)
                
                imageNameArr.append(observedDictKey)
                
                // *** 2. New 인 것들을 나중에 표시해주기 위해서
                // Value 와 현재시간을 비교해서 New 인지에 대한 여부를 index로 Return  -> return index [ x, y ]
                
//                let currentDateTime = Date()
                let currentDateTime = Date()
                let newTimeInterval = 9 * 24 * 3600
                
                
                for (inndexIdx , time) in dateObjects!.enumerated(){
                    let realTimeInterval = currentDateTime.timeIntervalSince( time )
                        if Int(realTimeInterval) <= newTimeInterval{
                            newIndex.append( (idx, inndexIdx) )
                        }
                }
                
                
//                var newFnameInnerLoop = [String]()
//                for ( name, time ) in zip( observedDictKey, dateObjects!) {
//                    let realTimeInterval = currentDateTime.timeIntervalSince( time )
//                    print("realTimeInterval  : ", realTimeInterval)
//                    if Int(realTimeInterval) <= newTimeInterval{
//                        newFnameInnerLoop.append(name)
//                    }
//                }
//                newFname.append( newFnameInnerLoop )
                
//                print("newIndexTuple  :  ",newIndexTuple )
//
//                print("  currentDateTime  :  ", currentDateTime)
//                print("  type of currentDateTime  :  ", type(of: currentDateTime) )
//                print("dateObjects![0]  : ", dateObjects![0])
//                print("dateObjects![1]  : ", dateObjects![1])
//                let interval = dateObjects![0].timeIntervalSince(dateObjects![1]) // 초 단위 차이 2일 : 2 * 24 * 3600
//                print(" ===== interval : ",interval  )
//                print(" ===== interval : ", type(of: interval ) )


            }
            completion(categoryNamesArr, totalIndexArr, adIndexArr, imageNameArr, newIndex )
        })
    }
    

    
    
    // AdImage
    func appendAdImage( adIndexArray: [Int], categoryNamesArray: [String], completion: @escaping ( Bool ) -> Void) {
     
        var adImagecount = 0
        let totalAdNum = adIndexArray.count
        
        if totalAdNum == 0 {
            completion(true)
        }else{
            
            
            for adIndex in adIndexArray {
                
                let adCategoryName = categoryNamesArray[adIndex]
                let categoryRef = Database.database().reference().child("objects").child("category").child("\(adCategoryName)")
                
                categoryRef.observe(.value, with: { (snapshot) in
                    let adPath = snapshot.value! as! NSDictionary
                    
                    let twoDimNoFillRef = Storage.storage().reference(forURL: adPath["adImg"]! as! String)
                    twoDimNoFillRef.getData(maxSize: 1*1024*1024) { (adImgData, error) in
                        if error != nil {
                            print(error?.localizedDescription as Any)
                        } else {
                            self.adImageDictFB[adCategoryName] = UIImage(data: adImgData!)!
                            
                            adImagecount += 1
                            print("adImagecount   : ", adImagecount)
                            if adImagecount == totalAdNum{
                                completion(true)
                            }
                        }
                    }
                })
            }
        }
    }
    
    // 혹시, 앱이 이상하게 종료될 경우, twoDim image가 Document에 존재하지 않을 경우를 대비해서, twoDim 파일의 존재 여부로 가져오기.
    func checkUserTwoDimRecord(selectedFname: String) -> Bool{
        
        var boolResult = Bool()
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponent = url.appendingPathComponent("\(selectedFname)/2DNoFill.png") {
            let filePath = pathComponent.path
            
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath) {
                boolResult = true
            }else{
                boolResult = false
            }
        }
        return boolResult
    }
    
    func appendTwoDimImage( imageNameArray: [[String]], completion: @escaping ( Bool ) -> Void) {
        
        // Input : fileName
        var twoDimCount = 0
        let totalTwoDimNum = imageNameArray.joined().count
        
        // MARK: - *** Document *** if user has touched History, then import from Document
        // if fileName exists, cell.objectImg.image = UIImage(data: at Document )
        for i in 0..<imageNameArray.count{
            for j in 0..<imageNameArray[i].count{
            
                let fileName = imageNameArray[i][j]
                
                if checkUserTwoDimRecord(selectedFname: fileName){
                    
                    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let twoDimWorkPath = documentsURL.appendingPathComponent( "\(fileName)" + "/2DNoFill.png")
                    
                    let twoDimData = try? Data(contentsOf: twoDimWorkPath)
                    self.twoDimImageDictFB[fileName] = UIImage(data: twoDimData!)
                    twoDimCount += 1
                    print("twoDimCount  : " , twoDimCount)
                    if twoDimCount == totalTwoDimNum{
                        completion(true)
                    }
                    
                } else{
                    // MARK: - *** Firebase *** download and display 2DNoFill
                    let twoDimRef = Database.database().reference().child("objects").child("twoDim").child("\(fileName)")
                    twoDimRef.observe(.value, with: { (snapshot) in
                        
                        let twoDimNoFillPath = snapshot.value! as! NSDictionary
                        
                        let twoDimNoFillRef = Storage.storage().reference(forURL: twoDimNoFillPath["2DNoFill"]! as! String)
                        twoDimNoFillRef.getData(maxSize: 1*1024*1024) { (imgData, error) in
                            if error != nil {
                                print(error?.localizedDescription as Any)
                            } else {
                                self.twoDimImageDictFB[fileName] = UIImage(data: imgData!)
                                twoDimCount += 1
                                print("twoDimCount  : " , twoDimCount)
                                if twoDimCount == totalTwoDimNum{
                                    completion(true)
                                }
                            }
                        }
                    })
                }
            }
        }
    }

    func getAnonymousUserId(completion: @escaping ( String )-> Void ){
        
        var userIdAnonymous = String()
        
        DispatchQueue.main.async {
            Auth.auth().signInAnonymously{ (user, err) in
                
                userIdAnonymous = user!.user.uid
                print(" ===  userIdAnonymous  : " ,userIdAnonymous)
                
                // Save Uid into " UserDefaults "
                self.defaults.set(userIdAnonymous, forKey: "userId")
                
                // Save Uid into " Database "
                var ref: DatabaseReference!
                ref = Database.database().reference().child("users")
    
                let userInfo = ["uid" : userIdAnonymous ]
                ref.child("\(userIdAnonymous)").setValue(userInfo){ (error, ref) -> Void in
                    completion(userIdAnonymous)
                }
                
                
//                ref.child("\(userIdAnonymous)").observe(.value, with: { snapshot in
                
//                    let userInfo = ["uid" : userIdAnonymous ]
                    
                    
//                    if snapshot.exists(){
//                        print(" Uid already exists in Firebase Database ")
//                    } else {
//                        let userInfo = ["uid" : userIdAnonymous ]
//                        ref.child("\(userIdAnonymous)").setValue(userInfo){ (error, ref) -> Void in
//                        }
//                    }
//                    completion(userIdAnonymous)

                
            }
            print("=== getAnonymousUserId is done Final  ==== ")
        }
        
        
    }
    
    func uploadUidDatabase(completion: @escaping (String) -> Void ){
        
        var userIdAnonymous = String()
        userIdAnonymous = self.defaults.object(forKey: "userId") as? String ?? String()
        //        self.uidString = userIdAnonymous
        completion(userIdAnonymous)
    }

    
    func executeEveryExceptUseId(){
        print("============== checkUserPaidAd starts!!! ")
        self.checkUserPaidAd { (userPaidAd) in
            self.userPaidAdFB = userPaidAd
            print("userPaidAd : ",self.userPaidAdFB)
            
            self.loadNameIndexFireBase(userPaidAdArray: self.userPaidAdFB){ (categoryNamesArr, totalIndexArr, adIndexArr, imageNameArr, newIndex ) in
                
                print("laodFromFirebase Starts ! ")
                // Load Names from Firebase
                self.categoriesNameArrFB = categoryNamesArr
                self.totalIndexArrFB = totalIndexArr
                self.adIndexArrFB = adIndexArr
                self.imageNameArrFB = imageNameArr
                self.newIndexFB = newIndex
                
                print("  newIndex   :  ",self.newIndexFB  )
                
                // load real images from Firebase
                // TableView cellForRowAt 에 대한 대체
                self.appendAdImage(adIndexArray: self.adIndexArrFB, categoryNamesArray: self.categoriesNameArrFB, completion: { (adDownBool) in
                    
                    print("appendAdImage  stats !! ")
                    
                    self.appendTwoDimImage(imageNameArray: self.imageNameArrFB, completion: { (twoDimDownBool) in
                        
                        print("appendTwoDimImage starts !!! ")
                        
                        if  adDownBool && twoDimDownBool{
                            print("timer starts !")
                            Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(self.dismissSplashController), userInfo: nil, repeats: false)
                        }
                    })
                    
                })
            }
        }
    }
    
    
 
    func splashScreen(){
        
        print("============== splashScreen Inside  starts!!! ")
        let launchScreenVC = UIStoryboard.init(name: "LaunchScreen", bundle: nil)
        let rootVC = launchScreenVC.instantiateViewController(withIdentifier: "splashController")
        self.window?.rootViewController = rootVC
        self.window?.makeKeyAndVisible()
        
        // MARK: - Revise -> completion handler : Import data from Firebase
        // Database 2 : Load files from Firebase
        
        
        print("============== checkUserPaidAd starts!!! ")
        
        if Auth.auth().currentUser == nil {
            
            self.getAnonymousUserId { (anonymousEnrolledUserId) in
                print(" Ananoymous  ====== anonymousEnrolledUserId  : ", anonymousEnrolledUserId)
                self.uidString = anonymousEnrolledUserId
                
                self.executeEveryExceptUseId()
                
            }
        } else {
            print("Auth.auth().currentUser  : " , Auth.auth().currentUser!.uid)
//            uploadUidDatabase { (anonymousEnrolledUserId ) in
//                print(" Already Existing ====== anonymousEnrolledUserId  : ", Auth.auth().currentUser!.uid)
                self.uidString = Auth.auth().currentUser!.uid
                
                self.executeEveryExceptUseId()
                
//        }

    }
    
    }
    

    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


    
}

extension Array where Element : Collection,
Element.Iterator.Element : Equatable, Element.Index == Int {
    
    func indices(of x: Element.Iterator.Element) -> (Int, Int)? {
        for (i, row) in self.enumerated() {
            if let j = row.index(of: x) {
                return (i, j)
            }
        }
        return nil
    }
}
