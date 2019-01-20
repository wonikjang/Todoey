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
    
    var newFnameFB = [String]()
    
    // Database 2 : Firebase or Documents 에서 가져올지 정할 시간 기준
    let currentDateTime = Date()
    
    // Database 3 : MyWorks Completion handler 로 저장하기 위한 Variables
//    var myWorksArrFB = [ String : UIImage ]()
//    var modifiedTimeArrFB = Date()
//    var imageMyworksDictArr = [(key: String, value: (Date, UIImage))]()
    var imageMyworksDict = [ String : ( Date, UIImage ) ]()
    
    // Basic Settings
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
    let fileManager = FileManager.default
    
    let newTimeInterval = 28 * 24 * 3600 // MARK: - 나중에 몇일을 기준으로 New 표시 해줄지에 따라 변경
    
    var IncomeTimeDate = Date()
    var prevIncomeTimeDate = Date()
    
    var subscribeTemp = false
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        FirebaseApp.configure()
        
        // Print Docunent Directory ( Local File Saving Path )
        print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last! as String )
        print(" ******* user paidAd in UserDefaults : ", defaults.object(forKey: "paidAd") as? String ?? String() )
        
        // Launch Screen
        print("============== splashScreen starts !!! ")
        self.splashScreen()
        print("============== splashScreen ends !!! ")
        
        myworksUpdate.imageMyworks = getTouchedFromDocuments()
        
        
        
        
        return true
    }
    
    @objc func dismissSplashController(){
        let mainVC = UIStoryboard.init(name: "Main", bundle: nil)
        let rootVC = mainVC.instantiateViewController(withIdentifier: "initController")
        
        self.window?.rootViewController = rootVC
        self.window?.makeKeyAndVisible()
    }

    
    // ======== ****** User Id Identification & Creation ****** ========
    
    func uploadUidDatabase(completion: @escaping (String) -> Void ){
        var userIdAnonymous = String()
        userIdAnonymous = self.defaults.object(forKey: "userId") as? String ?? String()
        completion(userIdAnonymous)
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
            }
            print("=== getAnonymousUserId is done Final  ==== ")
        }
    }
    
    // ======== ****** Check and Get Namse & Files ****** ========
    
    func checkUploadTime(completion: @escaping (Date)-> Void ){
        var uploadTime = String()
        var dateTime = Date()
        let refUserPaidAd = Database.database().reference().child("uploadTime")
        refUserPaidAd.observeSingleEvent(of: .value, with: { (snapshot) in

            if snapshot.exists(){
                let uploadDict = snapshot.value as! [String: Any]
                uploadTime = uploadDict["uploadTime"] as! String

                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/yy HH:mm:ss" // Excel 올릴때의 형식에 맞춰서 !
                dateTime = dateFormatter.date(from: uploadTime)!
            }
            completion(dateTime)
        })
    }

    func checkImageNameArr(completion: @escaping (Array<Array<String>>)-> Void ){
        var imageNameArr = [[String]]()
        let refCat = Database.database().reference().child("objects").child("category")
        refCat.observeSingleEvent(of: .value, with: { (snapshot) in
            for child in snapshot.children {
                
                let snap = child as! DataSnapshot
                let snapDict = snap.value as! NSDictionary
                
                // *** 1. Reorder fName by Time
                var observedDict = snapDict["fName"]! as? Dictionary<String, AnyObject>
                
                // 01. key : 값을 따로 저장
                var observedDictKey = Array((observedDict?.keys)!)
                print(" 1st observedDictKey " , observedDictKey)
                
                // 02. value : String -> Dict   ( 이전 설명 :  시간을 Integer로 전환 하는 코드 필요 ! )
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/yy HH:mm:ss" // Excel 올릴때의 형식에 맞춰서 !
                var dateObjects = observedDict?.values.compactMap { dateFormatter.date(from: $0 as! String) }
                print(" 1st dateObjects " , dateObjects!)
                
                // 03. Sort key by value
                let sorted = zip(dateObjects!, observedDictKey).sorted { $0.1 > $1.1 }
                observedDictKey = sorted.map { $0.1 }
                
                dateObjects = dateObjects!.sorted(by: { $0.compare($1) == .orderedDescending })
                print(" 2nd observedDictKey " , observedDictKey)
                print(" 2nd dateObjects " , dateObjects!)
                
                imageNameArr.append(observedDictKey)
            }
            completion(imageNameArr)
        })
    }
    
    
    
    
    func checkUserPaidAd(completion: @escaping (Array<String>)-> Void ){
        var paidAdArray = [String]()
        
        // Firebase way
        let refUserPaidAd = Database.database().reference().child("users").child("\(uidString)")
        refUserPaidAd.child("paidAd").observeSingleEvent(of: .value, with: { (snapshot) in

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
    
    func checkUserPaidAdFromUserDefaults(completion: @escaping (Array<String>)-> Void ){
        var paidAdArray = [String]()
        paidAdArray = defaults.object(forKey: "paidAd") as? [String] ?? [String]()
        print(" === checkUserPaidAdFromUserDefaults === paidAdArray  : ", paidAdArray)
        completion(paidAdArray)
    }
    
    

    func loadNameIndexFireBase(userPaidAdArray: [String] , completion: @escaping ( Array<String>, Array<Int>, Array<Int>, Array<Array<String>>, Array<String> ) -> Void ) {

        // Overall necessary components
        var categoryNamesArr = [String]()
        var totalIndexArr = [Int]()
        var adIndexArr = [Int]()
        var imageNameArr = [[String]]()
        var newFname = [String]()
        
        let refCat = Database.database().reference().child("objects").child("category")
        refCat.observeSingleEvent(of: .value, with: { (snapshot) in
            
            print("///  loadNameIndexFireBase  Firebase access Working /// ")

            for ( idx, child ) in snapshot.children.enumerated() {
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
                if snapDict["ad"]! as! String == "TRUE" &&  paidAdBool {
                    let adInt = (snapDict["index"]! as! NSString).integerValue
                    adIndexArr.append( adInt )
                }
                
                // === ************** Revised Code *************** === //

                // *** 1. Reorder fName by Time
                var observedDict = snapDict["fName"]! as? Dictionary<String, AnyObject>
                
                // 01. key : 값을 따로 저장
                var observedDictKey = Array((observedDict?.keys)!)
                print(" 1st observedDictKey " , observedDictKey)
                
                // 02. value : String -> Dict   ( 이전 설명 :  시간을 Integer로 전환 하는 코드 필요 ! )
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/yy HH:mm:ss" // Excel 올릴때의 형식에 맞춰서 !
                var dateObjects = observedDict?.values.compactMap { dateFormatter.date(from: $0 as! String) }
                print(" 1st dateObjects " , dateObjects!)
                
                // 03. Sort key by value
                let sorted = zip(dateObjects!, observedDictKey).sorted { $0.1 > $1.1 }
                observedDictKey = sorted.map { $0.1 }
                
                dateObjects = dateObjects!.sorted(by: { $0.compare($1) == .orderedDescending })
                print(" 2nd observedDictKey " , observedDictKey)
                print(" 2nd dateObjects " , dateObjects!)
                
                imageNameArr.append(observedDictKey)
                
                // *** 2. New 인 것들을 나중에 표시해주기 위해서
                // Value 와 현재시간을 비교해서 New 인지에 대한 여부를 index로 Return  -> return index [ x, y ]
                
                for (inndexIdx , time) in dateObjects!.enumerated(){
                    let realTimeInterval = self.currentDateTime.timeIntervalSince( time )
                    print("realTimeInterval  :  ",  realTimeInterval)
                    if Int(realTimeInterval) <= self.newTimeInterval{
                            
                            newFname.append(imageNameArr[idx][inndexIdx])
                        }
                }
                
            }
            
            // === Sort categoryNamesArr by totalIndexArr
            let combined = zip(totalIndexArr, categoryNamesArr ).sorted {$0.0 < $1.0}
            categoryNamesArr = combined.map {$0.1}
            
            // === Sort imageNameArr by totalIndexArr
            let combinedImageNameArr = zip(totalIndexArr, imageNameArr ).sorted {$0.0 < $1.0}
            imageNameArr = combinedImageNameArr.map {$0.1}
            
            
            
            completion(categoryNamesArr, totalIndexArr, adIndexArr, imageNameArr, newFname )
        })
    }
    
    
    func loadNameIndexFromDocument(userPaidAdArray: [String] , completion: @escaping ( Array<String>, Array<Int>, Array<Int>, Array<Array<String>>, Array<String> ) -> Void ) {
        
        // Overall necessary components
        var categoryNamesArr = [String]()
        var totalIndexArr = [Int]()
        var adIndexArr = [Int]()
        var imageNameArr = [[String]]()
        var newFname = [String]()
        var paidAdArr = [String]()
        var paidAdIdx = [Int]()
        
        
        categoryNamesArr =  defaults.object(forKey: "categoryNamesArr") as? [String] ?? [String]()
        totalIndexArr =  defaults.object(forKey: "totalIndexArr") as? [Int] ?? [Int]()
        adIndexArr =  defaults.object(forKey: "adIndexArr") as? [Int] ?? [Int]()
        imageNameArr =  defaults.object(forKey: "imageNameArr") as? [[String]] ?? [[String]]()
        newFname =  defaults.object(forKey: "newFname") as? [String] ?? [String]()
        
        // === Sort categoryNamesArr by totalIndexArr
        let combined = zip(totalIndexArr, categoryNamesArr ).sorted {$0.0 < $1.0}
        categoryNamesArr = combined.map {$0.1}

        // === Sort imageNameArr by totalIndexArr
        let combinedImageNameArr = zip(totalIndexArr, imageNameArr ).sorted {$0.0 < $1.0}
        imageNameArr = combinedImageNameArr.map {$0.1}
        
        
        // === adIndexArr 에서 paidAdArr 에 해당하는 index 는 제외해야 함!!!
        paidAdArr = defaults.object(forKey: "paidAd") as? [String] ?? [String]()
        for paidAd in paidAdArr{
            paidAdIdx.append( categoryNamesArr.firstIndex(of: paidAd)! )
        }
        adIndexArr = adIndexArr.filter { !paidAdIdx.contains($0) }
        
        
        completion(categoryNamesArr, totalIndexArr, adIndexArr, imageNameArr, newFname )
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
                
                let localURL = NSURL(fileURLWithPath: self.path).appendingPathComponent("Ad/\(adCategoryName)/adImg.jpg")
                let filePath = localURL?.path
                
                // if Documents has categoryname.adImg.jpg exist { // append from Documents
                if fileManager.fileExists(atPath: filePath!) {
                    
                    let adImgData = try? Data(contentsOf: localURL!)
                    self.adImageDictFB[adCategoryName] = UIImage(data: adImgData!)
                    adImagecount += 1
                    print("adImagecount   : ", adImagecount)
                    if adImagecount == totalAdNum{
                        completion(true)
                        print(" =========== Get Ad Image from Documents ========== ")
                    }
                    
                }else{
                    
                    let categoryRef = Database.database().reference().child("objects").child("category").child("\(adCategoryName)")
                    
                    categoryRef.observeSingleEvent(of: .value, with: { (snapshot) in
                        let adPath = snapshot.value! as! NSDictionary
                        
                        let adRef = Storage.storage().reference(forURL: adPath["adImg"]! as! String)
                        
                        // MARK: - *** Save into Documents/Ad/CategoryName/
                        //                    let localURL = NSURL(fileURLWithPath: self.path).appendingPathComponent("Ad/\(adCategoryName)/adImg.jpg")
                        _ = adRef.write(toFile: localURL!) { url, error in
                            if error != nil {
                                print("  Uh-oh, an error occurred! ")
                            }else {
                                print("   local url :  ", url!)
                            }
                        }
                        
                        // MARK: - *** Append Data into Ad Array
                        // Appenmd to Ad Array
                        
                        adRef.getData(maxSize: 1*1024*1024) { (adImgData, error) in
                            if error != nil {
                                print(error?.localizedDescription as Any)
                            }else {
                                self.adImageDictFB[adCategoryName] = UIImage(data: adImgData!)!
                                
                                adImagecount += 1
                                print("adImagecount   : ", adImagecount)
                                if adImagecount == totalAdNum{
                                    completion(true)
                                    print(" =========== Get Ad Image from Firebase ========== ")
                                }
                            }
                        }
                    })
                }
                
            }
        }
    }
    
    // 혹시, 앱이 이상하게 종료될 경우, twoDim image가 Document에 존재하지 않을 경우를 대비해서, twoDim 파일의 존재 여부로 가져오기.
    func checkUserRecord(selectedFname: String, lastFileName: String) -> Bool{
        
        var boolResult = Bool()

        let url = NSURL(fileURLWithPath: path)
        if let pathComponent = url.appendingPathComponent("File/" + "\(selectedFname)/\(lastFileName)") {
            let filePath = pathComponent.path
            
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
        for i in 0..<imageNameArray.count{
            for j in 0..<imageNameArray[i].count{
            
                let fileName = imageNameArray[i][j]
                print("while appending into Data Arry , Filename is    :   ", fileName )
                
                if checkUserRecord(selectedFname: fileName, lastFileName: "2DNoFill.jpg" ){
                    
                    print(" *********** Appending from Documents ")
                    let twoDimWorkPath = documentsURL.appendingPathComponent( "File/" + "\(fileName)" + "/2DNoFill.jpg")
                    
                    let twoDimData = try? Data(contentsOf: twoDimWorkPath)
                    self.twoDimImageDictFB[fileName] = UIImage(data: twoDimData!)
                    twoDimCount += 1
                    print("twoDimCount  : " , twoDimCount)
                    if twoDimCount == totalTwoDimNum{
                        completion(true)
                    }
                    
                } else{ // First time to see the file
                    
                    print(" ************* First time Appending ")
                    // MARK: - *** Firebase *** download and display 2DNoFill
                    let twoDimRef = Database.database().reference().child("objects").child("twoDim").child("\(fileName)")
                    twoDimRef.observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        let twoDimNoFillPath = snapshot.value! as! NSDictionary
                        let twoDimNoFillRef = Storage.storage().reference(forURL: twoDimNoFillPath["2DNoFill"]! as! String)
                        
                        // MARK: - ***  Document *** Save into Document directory
                        // Download to the local filesystem
                        let localURL = NSURL(fileURLWithPath: self.path).appendingPathComponent("File/" + fileName)!.appendingPathComponent("2DNoFill.jpg")
                        _ = twoDimNoFillRef.write(toFile: localURL) { url, error in
                            if error != nil {
                                 print("  Uh-oh, an error occurred! ")
                            } else {
                                print("   local url :  ", url!)
                            }
                        }
                        
                        // MARK: - *** Append Data into Array
                        // Appenmd to Data Array
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
    
    
    func executeEveryExceptUseId(){
        print("============== checkUserPaidAd starts!!! ")
        self.checkUserPaidAd { (userPaidAd) in
            self.userPaidAdFB = userPaidAd
            print("userPaidAd : ",self.userPaidAdFB)
            
            self.loadNameIndexFireBase(userPaidAdArray: self.userPaidAdFB){ (categoryNamesArr, totalIndexArr, adIndexArr, imageNameArr, newFname ) in
                
                print("laodFromFirebase Starts ! ")
                
                self.defaults.set( categoryNamesArr , forKey: "categoryNamesArr")
                self.defaults.set( totalIndexArr , forKey: "totalIndexArr")
                self.defaults.set( adIndexArr , forKey: "adIndexArr")
                self.defaults.set( imageNameArr , forKey: "imageNameArr")
                self.defaults.set( newFname , forKey: "newFname")
                
                // Load Names from Firebase
                self.categoriesNameArrFB = categoryNamesArr
                self.totalIndexArrFB = totalIndexArr
                self.adIndexArrFB = adIndexArr
                self.imageNameArrFB = imageNameArr
                self.newFnameFB = newFname
                
                print("categoryNamesArr  =  ", categoryNamesArr )
                
                print("  newIndex   :  ",self.newFnameFB  )

                // load real images from Firebase --> TableView cellForRowAt 에 대한 대체
                self.appendAdImage(adIndexArray: self.adIndexArrFB, categoryNamesArray: self.categoriesNameArrFB, completion: { (adDownBool) in
                    
                    print("appendAdImage  stats !! ")

                    self.appendTwoDimImage(imageNameArray: self.imageNameArrFB, completion: { (twoDimDownBool) in
                        
                        print("appendTwoDimImage starts !!! ")
                        
                        if  adDownBool && twoDimDownBool{
                            print("timer starts !")
                            Timer.scheduledTimer(timeInterval: 0.0001, target: self, selector: #selector(self.dismissSplashController), userInfo: nil, repeats: false)
                        }
                    })
                    
                })
            }
        }
    }

    func executeEveryExceptUseIdFromDocument(){
 
        print("============== checkUserPaidAd starts!!! ")
        self.checkUserPaidAdFromUserDefaults { (userPaidAd) in
            self.userPaidAdFB = userPaidAd
            print("userPaidAd : ",self.userPaidAdFB)
            
            self.loadNameIndexFromDocument(userPaidAdArray: self.userPaidAdFB){ (categoryNamesArr, totalIndexArr, adIndexArr, imageNameArr, newFname ) in
                
                print("laodFromFirebase Starts ! ")
                // Load Names from Firebase
                self.categoriesNameArrFB = categoryNamesArr
                self.totalIndexArrFB = totalIndexArr
                self.adIndexArrFB = adIndexArr
                self.imageNameArrFB = imageNameArr
                self.newFnameFB = newFname
                
                print("  newIndex   :  ", self.newFnameFB  )
                
                // load real images from Firebase
                // TableView cellForRowAt 에 대한 대체
                self.appendAdImage(adIndexArray: self.adIndexArrFB, categoryNamesArray: self.categoriesNameArrFB, completion: { (adDownBool) in
                    
                    print("appendAdImage  stats !! ")
                    
                    self.appendTwoDimImage(imageNameArray: self.imageNameArrFB, completion: { (twoDimDownBool) in
                        
                        print("appendTwoDimImage starts !!! ")
                        
                        if  adDownBool && twoDimDownBool{
                            print("timer starts !")
                            Timer.scheduledTimer(timeInterval: 0.0001, target: self, selector: #selector(self.dismissSplashController), userInfo: nil, repeats: false)
                        }
                    })
                    
                })
            }
        }
    }
    
    // MARK: - MyWorks related Functions
    
    func contentsOfDirectoryAtPath(path: String) -> [String]? {
        guard let paths = try? FileManager.default.contentsOfDirectory(atPath: path) else { return nil}
        return paths.map { aContent in (path as NSString).appendingPathComponent(aContent)}
    }
    
    func fileModificationDate(string: String) -> Date? {
        do {
            let attr = try FileManager.default.attributesOfItem(atPath: string)
            return attr[FileAttributeKey.modificationDate] as? Date
        } catch {
            return nil
        }
    }
    
    
    
    func getTouchedFromDocuments() -> [String : (Date, UIImage)] {
//    func getTouchedFromDocuments() -> [(key: String, value: (Date, UIImage))] {
        
//        var myWorksDict = [ String : UIImage ]()
//        var modifiedTimeDict = [ String : Date ]()
        var dateImageDict = [String : (Date, UIImage)]()
        
        let localURL = NSURL(fileURLWithPath: self.path).appendingPathComponent("File")
        if let allSubDirectory = contentsOfDirectoryAtPath(path: localURL!.path) {// Array of total sub-directory path
            
            // Update everything
            for subdir in allSubDirectory{
                
                let touchedFname = subdir.replacingOccurrences(of: localURL!.path , with: "").replacingOccurrences(of: "/" , with: "")
                let subdirThreeDim = subdir + "/3DBack.png"
                let subdirTwoDim = subdir + "/2DNoFill.jpg"
                
                // 한번이라도 Touch했다는 증거(3DBack.png) 가 있으면,
                if fileManager.fileExists(atPath: subdirThreeDim)  {
    //            if fileManager.fileExists(atPath: subdirThreeDim) &&  modifiedTimeDict[touchedFname] != fileModificationDate(string: subdirTwoDim){
                    print("============*************============subdirThreeDim   :   ", subdirThreeDim)
                    let touchedTwoDimData = try? Data(contentsOf: NSURL(fileURLWithPath: subdirTwoDim ) as URL )
                    
                    dateImageDict[touchedFname] = (fileModificationDate(string: subdirTwoDim), UIImage(data: touchedTwoDimData!)) as? (Date, UIImage)
                    print("**********/////////////*************   :  ", dateImageDict[touchedFname]!)
    //                myWorksDict[touchedFname] = UIImage(data: touchedTwoDimData!)
    //                modifiedTimeDict[touchedFname] = fileModificationDate(string: subdirTwoDim)
                    
                }else{
                    print("============*************============subdirThreeDim   NONONONO ")
                }
                
            }
        }
        print("============*************============  *************============ dateImageDict  : ", dateImageDict)
        // Order dictionary  by last modeified time
//        let dateImageDictOrdered  = dateImageDict.sorted(by: { $0.1.0 > $1.1.0 })
    
//        print("============*************============  *************============ dateImageDictOrdered  : ", dateImageDictOrdered)

//        return dateImageDictOrdered
        return dateImageDict
        
        
        
        
        // MARK: - Completion handler
        
        //        if fileManager.fileExists(atPath: filePath!) {
        //            // if Documents has categoryname.adImg.jpg exist { // append from Documents
        //
        //            let adImgData = try? Data(contentsOf: localURL!)
        //            self.adImageDictFB[adCategoryName] = UIImage(data: adImgData!)
        //            adImagecount += 1
        //            print("adImagecount   : ", adImagecount)
        //            if adImagecount == totalAdNum{
        //                completion(true)
        //                print(" =========== Get Ad Image from Documents ========== ")
        //            }
        
        
        
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
        
        // Time 관련 된 Setting 값 미리 선언!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy HH:mm:ss"
        
        self.uploadUidDatabase { (uidStringDefaults) in
            if uidStringDefaults.isEmpty{ // 처음 로그인 하는 경우
                
                // 처음 로그인 하는 경우 -> prevIncomeDateTime 을 UserDefaults에 저장
                let IncomeDateTime = self.currentDateTime

                let dateString = dateFormatter.string(from: IncomeDateTime)
                self.defaults.set(dateString, forKey: "prevIncomeDateTime")
                
                // Anonymously log in user
                self.getAnonymousUserId { (anonymousEnrolledUserId) in
                    print(" Ananoymous  ====== anonymousEnrolledUserId  : ", anonymousEnrolledUserId)
                    self.uidString = anonymousEnrolledUserId
                    self.executeEveryExceptUseId()
                }
            }else{
                
                // === Set IncomeDateTime into UserDefaults
                let prevIncomeDateTime = self.defaults.object(forKey: "prevIncomeDateTime") as? String ?? String()
                let previousDateTime = dateFormatter.date(from: prevIncomeDateTime)!
                
                // === uidString
                self.uidString = uidStringDefaults
                print("uidStringDefaults  :  ", uidStringDefaults)
            
                // Compare currentTime and uploadTime
                self.checkUploadTime{ (uploadTimeFB) in
                    
                    if uploadTimeFB > previousDateTime && uploadTimeFB < self.currentDateTime{ // Load some from database, others from document
                        print("************************* /////////////// Update from firebase ")
                        self.executeEveryExceptUseId()
                        
                    }else{ // Load Everything from Documents
                        print("************************* /////////////// Update from Document ")
                        self.executeEveryExceptUseId()
//                        self.executeEveryExceptUseIdFromDocument()
                    }
                    
                    // === Update 'prevIncomeDateTime' by current time
                    let IncomeDateTime = self.currentDateTime
                    let dateString = dateFormatter.string(from: IncomeDateTime)
                    self.defaults.set( dateString , forKey: "prevIncomeDateTime")
                }
                
                // 한번이라도 Touch한 적이 있는 것들에 대한 Loading for MyWorks
                
                
                
            }
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

