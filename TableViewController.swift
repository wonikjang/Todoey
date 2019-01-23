//
//  TableViewController.swift
//  3dPolyPocket_1114_1
//
//  Created by HayoungKim on 14/11/2018.
//  Copyright © 2018 JangnKim. All rights reserved.
//

import UIKit

import Firebase
import FirebaseDatabase
import FirebaseStorage

struct objName {
    static var selectedListFname = String()
}


class TableViewController: UITableViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // 추후 삭제 01.01
    var subscribeBtn = UIButton()
    let subscribeViewController = SubscribeViewController()
    
    // AppDelegate에서 Firebase에 접근해 가져온 데이터를 불러오기 위한 delegate
    let delegate = UIApplication.shared.delegate as! AppDelegate
    let defaults = UserDefaults.standard
    
    let testString = "testString" 
    
    // Firebase로 부터 불러올 데이터
    var categoriesNameArr = [String]()
    var totalIndexArr = [Int]()
    var adIndexArr = [Int]()
    var imageNameArr = [[String]]()
    
    var adImageDict =  [ String : UIImage ]()
    var twoDimImageDict = [ String : UIImage ]()
    
    var newFname = [String]()
//    var newIndex = [(Int, Int)]()

    static var selectedListFname = String()
    static var selectedListIndex = [0,0]
    
    var filePathString = String()
    // Offsets
    var storedOffsets = [Int: CGFloat]()
    
    var scnView:MainView {return view as! MainView}
    
    var listTableViewCell = ListTableViewCell()
    
    var MyworksView = CollectionViewController()
    
    var userID = String()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // === Remove every items from  userDefaults
//        let domain = Bundle.main.bundleIdentifier!
//        UserDefaults.standard.removePersistentDomain(forName: domain)
//        UserDefaults.standard.synchronize()
//        print(Array(UserDefaults.standard.dictionaryRepresentation().keys).count)
        
        print("viewDidLoad() running starts! ")
        self.tabBarController?.tabBar.isHidden = false
        
        categoriesNameArr = delegate.categoriesNameArrFB
        totalIndexArr = delegate.totalIndexArrFB
        adIndexArr = delegate.adIndexArrFB
        imageNameArr = delegate.imageNameArrFB
        print("categoriesNameArr Out ", categoriesNameArr)
        print("totalIndexArr Out ", totalIndexArr)
        print("adIndexArr Out ", adIndexArr)
        print("imageNameArr Out ", imageNameArr)
        
        adImageDict = delegate.adImageDictFB
        twoDimImageDict = delegate.twoDimImageDictFB
        newFname = delegate.newFnameFB
//        newIndex = delegate.newIndexFB
        
        userID = delegate.uidString
        
//        print("gameView selectedItemIndex : ", gameView.selectedItemIndex )
        
        
        
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if delegate.subscribeTemp{
            adIndexArr = delegate.adIndexArrFB
            tableView.reloadData()
            delegate.subscribeTemp = false
        }
        
        
        createFloatingButton()
        
        print("********* Tableivew  viewWillAppear  ")
        print("selectedListIndex  : " , TableViewController.selectedListIndex)
        
        if objName.selectedListFname.isEmpty{
            print(" ****** No selectedListFname ! ")
        }else{
            print(" ****** selectedListFname exist ! ")
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let twoDimWorkPath = documentsURL.appendingPathComponent( "File/" + "\(objName.selectedListFname)" + "/2DNoFill.jpg")
            
            let twoDimData = try? Data(contentsOf: twoDimWorkPath)
            self.twoDimImageDict[objName.selectedListFname] = UIImage(data: twoDimData!)
            
            // Reload Data if selectedListFname exist !!!
            let indexPath = IndexPath(item: TableViewController.selectedListIndex[0], section: 0)
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
 
    
    override func viewWillDisappear(_ animated: Bool) {
        if subscribeBtn.superview != nil {
            DispatchQueue.main.async {
                self.subscribeBtn.removeFromSuperview()
                
            }
        }
    }
    
    // MARK:- Floating Button related code
    
    func createFloatingButton() {
        subscribeBtn = UIButton(type: .custom)
        
        subscribeBtn.translatesAutoresizingMaskIntoConstraints = false
        subscribeBtn.backgroundColor = UIColor(red:0.12, green:0.56, blue:1.00, alpha:0.9)//.white
        // Make sure you replace the name of the image:
        subscribeBtn.setImage(UIImage(named:"NAME OF YOUR IMAGE"), for: .normal)
        // Make sure to create a function and replace DOTHISONTAP with your own function:
        subscribeBtn.addTarget(self, action: #selector(subscribeButtonTapped), for: UIControl.Event.touchUpInside)
        
        // We're manipulating the UI, must be on the main thread:
        DispatchQueue.main.async {
            if let keyWindow = UIApplication.shared.keyWindow {
                keyWindow.addSubview(self.subscribeBtn)
                NSLayoutConstraint.activate([
                    keyWindow.trailingAnchor.constraint(equalTo: self.subscribeBtn.trailingAnchor, constant: 15),
                    keyWindow.bottomAnchor.constraint(equalTo: self.subscribeBtn.bottomAnchor, constant: 98),
                    self.subscribeBtn.widthAnchor.constraint(equalToConstant: 350),
                    self.subscribeBtn.heightAnchor.constraint(equalToConstant: 65)])
                
            }
            
            // Make the button round:
            //self.subscribeBtn.layer.cornerRadius = 37.5
            self.subscribeBtn.layer.cornerRadius = 30.5
            self.subscribeBtn.frame.size = CGSize(width: 400, height: 100)
            
            // Add a black shadow:
            self.subscribeBtn.layer.shadowColor = UIColor.black.cgColor
            self.subscribeBtn.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
            self.subscribeBtn.layer.masksToBounds = false
            self.subscribeBtn.layer.shadowRadius = 2.0
            self.subscribeBtn.layer.shadowOpacity = 0.5
            // Add a pulsing animation to draw attention to button:
            let scaleAnimation: CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
            scaleAnimation.duration = 0.4
            scaleAnimation.repeatCount = .greatestFiniteMagnitude
            scaleAnimation.autoreverses = true
            scaleAnimation.fromValue = 1.0;
            scaleAnimation.toValue = 1.03;
            self.subscribeBtn.layer.add(scaleAnimation, forKey: "scale")
        }
    }
    
    @objc func subscribeButtonTapped(sender: UIBarButtonItem){
        print("Subscribe——")
        //self.navigationController?.pushViewController(subscribeViewController, animated: true )
        
        performSegue(withIdentifier: "popup", sender: self)
        
    }
    


    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("categoriesNameArr.count", categoriesNameArr.count)
        return categoriesNameArr.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if adIndexArr.contains(indexPath.row){ return 350 }
        else { return 180 }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        // 광고 이미지를 넣을 인덱스를 미리 위에서 설정해두고 그걸로 가져오도록
        // === Revised
        if adIndexArr.contains(indexPath.row){
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "AdTableViewCell", for: indexPath) as? AdTableViewCell
            cell?.selectionStyle = .none
            
            // ********************* AppDelegate에서 [ categoryName : UIImage] 로 저장해 놓은거에 접근해서 뿌려주기만!!!
            let adCategoryName = categoriesNameArr[indexPath.row]
            cell?.adImage.image =  adImageDict[adCategoryName]
            
            return cell!
            
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ListTableViewCell", for: indexPath) as? ListTableViewCell
            cell?.objectList.delegate = self as UICollectionViewDelegate
            cell?.objectList.dataSource = self as UICollectionViewDataSource
            cell?.objectList.tag = indexPath.row
            
            // ********************* categoryName
            cell?.objectCategory.text = categoriesNameArr[indexPath.row]
            
            
            cell?.selectionStyle = .none
            
            cell?.objectList.reloadData()

            return cell!
        }
        
        

    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let tableViewCell = cell as? ListTableViewCell else { return }
        tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
        tableViewCell.collectionViewOffset = storedOffsets[indexPath.row] ?? 0
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        guard let tableViewCell = cell as? ListTableViewCell else { return }
        storedOffsets[indexPath.row] = tableViewCell.collectionViewOffset
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("tableView indexPath is touched !!!!, indexPath  : ", indexPath.row )
        
        // MARK: - 광고 이미지 클릭시, 구매하는 부분 추가하기!
        
        // MARK: - 광고를 샀다는 피드백을 Input으로 하여,
        //         1. Firebase/users/userId/Ad/categoryName 에 기록
        //         2. 해당 Category를 tableViewCell --> collectionViewCell 로 전환해주고, 해당 TableView의 row 를 바꿔주기!
        
        // Test for 1.
        if indexPath.row != nil{ // 구매했다는 피드백으로 전환해야 함 !!!
            
            // === 1. Update to Firebase
            let ref = Database.database().reference()
            let paidAdInfo = [categoriesNameArr[indexPath.row] : indexPath.row]
            ref.child("users").child("\(userID)").child("paidAd").updateChildValues(paidAdInfo)
            
            
            // === 2. Update to UserDefaults
            let newPiadAd = categoriesNameArr[indexPath.row]
            //check if there is already an existing paidAd array in
            
            var paidAdArr = self.defaults.object(forKey: "paidAd") as? [String] ?? [String]()
            print(" ///////////////// ===== previosuly added paidAdArr  :  ", paidAdArr  )
            paidAdArr.append(newPiadAd)
            defaults.set(paidAdArr, forKey: "paidAd")
            
            let paidAdString = defaults.object(forKey: "paidAd")
            print(" ///////////////// ===== currently added all paidAdArr   :  ", paidAdString! )
            
            
            // === 3. Refresh contents at selected row of TableView
            
            // === 3.1.  remove indexPath.row from adIndexArr
            adIndexArr = adIndexArr.filter {$0 != indexPath.row}
            // === 3.2.
            let indexPath = IndexPath(item: indexPath.row, section: 0)
            tableView.reloadRows(at: [indexPath], with: .fade)

        }
        
        
    }
    
    
    // MARK: - Collection view data source
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // === Revised
        for i in 0..<imageNameArr.count{
            if collectionView.tag == i {
                return imageNameArr[i].count
            }
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ListCollectionViewCell", for: indexPath) as! ListCollectionViewCell
        
        // *** reload cell item
        print("collectionView - cellForItemAt Running")
        
        // MARK: - *** GameView에서 색칠하다 돌아오면 해당함수가 호출되므로, new에 대한 조건을 여기서 추가해줘서, 한번이라도 선택했으면 New가 안뜨도록 해주기!!!
        
        // ************************* Revised + Firebase 2D ***
        for i in 0..<imageNameArr.count{
            if collectionView.tag == i {
                
                let fileName = imageNameArr[i][indexPath.item]
                cell.objectImg.image = twoDimImageDict[fileName]

                // New 에 대한 표시 해주기
//                print("(i, indexPath.item) : ", (i, indexPath.item))
//                if newIndex.contains(where: {$0 == (i, indexPath.item)}) {
                if newFname.contains(fileName) {
                    print("new!!!")
                    cell.newLabel.text = "New"
                    cell.newLabel.textColor = UIColor.blue
                    cell.newLabel.shadowColor = UIColor.white
                    cell.newLabel.font = UIFont(name: "HelveticaNeue", size: CGFloat(15))

                } else {
                    print("Not new")    // false
                    cell.newLabel.text =  ""
                }

            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        print("collectionView - didSelectItemAt Running")
        
        print("At row\(collectionView.tag) \(indexPath.row)")
        objName.selectedListFname = imageNameArr[collectionView.tag][indexPath.item]
        TableViewController.selectedListIndex = [collectionView.tag, indexPath.item]
        
        //  *** Update to delegate.
        let currentDateTime = Date()
        
        // MARK: - 미래에 2DNoFill 로 작업중이던 3D파일이 캡쳐될 것이기 때문에, 추후 수정 필요 없음
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let twoDimWorkPath = documentsURL.appendingPathComponent("File/" + "\(objName.selectedListFname)" + "/2DNoFill.jpg")
        let twoDimData = try? Data(contentsOf: twoDimWorkPath)

        
//        delegate.imageMyworksDict[TableViewController.selectedListFname] = ( currentDateTime, UIImage(data: twoDimData!)! )
//        delegate.imageMyworksDict[TableViewController.selectedListFname]!.0 = currentDateTime  // current data time --> currentDateTime
//        delegate.imageMyworksDict[TableViewController.selectedListFname]!.1 = UIImage(data: twoDimData!)!
//        print("delegate.imageMyworksDict  :  ", delegate.imageMyworksDict )
        
        myworksUpdate.imageMyworks[objName.selectedListFname] = ( currentDateTime, UIImage(data: twoDimData!)! )
        print("myworksUpdate.imageMyworks  :  ", myworksUpdate.imageMyworks )
//        MyworksView.imageMyworks[TableViewController.selectedListFname] = ( currentDateTime, UIImage(data: twoDimData!)! )
//        MyworksView.imageMyworks[TableViewController.selectedListFname]?.0 = currentDateTime  // current data time --> currentDateTime
//        MyworksView.imageMyworks[TableViewController.selectedListFname]?.1 = UIImage(data: twoDimData!)!
//        print("MyworksView.imageMyworks  :  ", MyworksView.imageMyworks )
        
        // *** Check user Touch History
        if checkUserRecord(selectedFname: objName.selectedListFname){
           
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "GameViewController") as? GameViewController
            self.navigationController?.pushViewController(vc!, animated: true)
            
        }else{
            // *** Completion Handler : If downloading to Document directory is done, move to GameViewController
            workSuperTest{ (boolValue) in
                
                if boolValue {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "GameViewController") as? GameViewController
                    self.navigationController?.pushViewController(vc!, animated: true)
                }
            }
        
        }
        
        print("TableView  :  End of Code line ")
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // === Revised
        if adIndexArr.contains(collectionView.tag){
            let size = CGSize(width: 400, height: 400)
            return size
        }else{
            let size = CGSize(width: 100, height: 150)
            return size
        }
    }
    
    
    // =================== End of TableView and CollectionView
    

    // *** 11/20 for 문을 해제하고, Bool 을 세개 만들어서, 세개가 모두 false? 이면 completion 넘겨 받도록!
    
    func workSuperTest(completion: @escaping ( Bool ) -> Void) {
        
        // 2.1. subfolder 만들기
        let fileManager = FileManager.default
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        let pathComponent = url.appendingPathComponent("File/" + objName.selectedListFname)
        
        do {
            try fileManager.createDirectory(atPath: pathComponent!.path, withIntermediateDirectories: true, attributes: nil)
        }
        catch let error as NSError {
            print("Ooops! Something went wrong in creating objecName subfolder in Directory : \(error)")
        }
        print("1. subfolder creation Done! ")
        
        let threeDimFnameRef = Database.database().reference().child("objects").child("threeDim")
        threeDimFnameRef.child("\(objName.selectedListFname)").observe(.value, with: { (snapshot) in
            
            if let threeDimInf = snapshot.value as? NSDictionary{
                
                var count = 0
                
                for threeDimKey in threeDimInf.allKeys{    // [3DNoFill, 3DBack, dict]
                    
                    let threeDimKeyString = threeDimKey as! String
                    
                    // Step 1 : Saving Path of Documnet Directory
                    var extensionString = String()
                    if threeDimKeyString == "3DNoFill"{
                        extensionString = ".scn"
                    }else if threeDimKeyString == "3DBack"{
                        extensionString = ".png"
                    }else{
                        extensionString = ".json"
                    }
                    
                    let threeDimFname = threeDimKeyString + extensionString
                    let threeDimTotalPath = pathComponent!.appendingPathComponent(threeDimFname)
                    
                    // Step 2
                    let threeNoFillStorageRef = Storage.storage().reference(forURL: threeDimInf[threeDimKeyString]! as? String ?? String())
                    let downloadTask =  threeNoFillStorageRef.write(toFile: threeDimTotalPath) { (url, err)  in
                        
                        if let error = err{
                            print("error while downloading =your files :\(error)")
                        }else{
                            print("file download to Document directory complete! ")
                            
                        }
                        print("3D download complete")
                    }
                    downloadTask.observe(.progress){ snapshot in
                        let percentComplete = 100.0 * Double((snapshot.progress?.completedUnitCount)!) / Double(snapshot.progress!.totalUnitCount)
                        print("percentComplete  :  ",percentComplete )
                    }
                    downloadTask.observe(.success){ snapshot in
                        count += 1
                        if count == 3 {
                            completion(true)
                        }
                    }
                }
            }
        })
    }
    
    
    
    func checkUserRecord(selectedFname: String) -> Bool{
        
        var boolResult = Bool()
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponent = url.appendingPathComponent("File/" + "\(selectedFname)/3DBack.png" ) {
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
    

    
    
}


