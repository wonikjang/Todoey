//
//  ListViewController.swift
//  PolyPocket_1018
//
//  Created by HayoungKim on 18/10/2018.
//  Copyright © 2018 JangnKim. All rights reserved.
//

import UIKit

import Firebase
import FirebaseDatabase
import FirebaseStorage


class ListViewController: UIViewController {
    
    
    var data = [String]()

    
    
    // AppDelegate에서 Firebase에 접근해 가져온 데이터를 불러오기 위한 delegate
    let delegate = UIApplication.shared.delegate as! AppDelegate

    // userId
    var userId = String()
    var userFnameArr = [String]()
    var selectedFname = String()
    
    // Offsets
    var storedOffsets = [Int: CGFloat]()
    
    // AppDelegate 로 부터 불러올 Category 관련 데이터
    var categoryNameArr = [String]()
    var categoryIndexArr = [Int]()
    var adIndexArr = [Int]()
    var categoryImageNameArr = [[String]]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        data = ["some data"]


        
        print("viewDidLoad() running starts! ")
        userId = delegate.uidString
        
//        userFnameArr = delegate.userFnameArrFB
//        print("userFnameArr : ", userFnameArr)
        
        categoryNameArr = delegate.categoryNamesArrFB
        categoryIndexArr = delegate.categoryIndexArrFB
        adIndexArr = delegate.adIndexArrFB
        categoryImageNameArr = delegate.categoryImageNameArrFB
        print("categoriesNameArr Out ", categoryNameArr)
        
        self.tabBarController?.tabBar.isHidden = false
        

       
        
        
    }
    

    
    

    // 한번이라도 Touch한 적이 있는지 체크 -> 2D
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        
//        self.table .reloadData()

        
        print("ListViewController - viewWillAppear " )

        
//        self.tableView(tableView: UITableView, cellForRowAt: 1).reloadData()
        
        // *** Check user has files(fName) in DocumentDirectory
//        self.collectionView(UICollectionView, cellForItemAt: IndexPath)
        
        
        
//        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//
//            print("At row\(collectionView.tag) \(indexPath.row)")
//
//            //컬렉션 뷰의 이미지 선택 시, 해당 이미지 컬러링 페이지로 넘어감
//            let vc = storyboard?.instantiateViewController(withIdentifier: "GameViewController") as? GameViewController
//
//            selectedFname = categoryImageNameArr[collectionView.tag][indexPath.item]
//
//            // ****** Firebse: vc.objectName 을 fName으로 받아서 --> Firebase Uid 아래에 등록 해주기
//            let userRef = Database.database().reference().child("users").child("\(userId)").child("fName").child("\(selectedFname)")
//            let userWorkInfo = ["Done" : false]
//            userRef.updateChildValues(userWorkInfo)
//
//            // ******* Pass name to GameViewController
//            vc?.objectName = selectedFname
        

        

        
    }
    
    @objc func loadList(notification: NSNotification) {

    }
    
    

    // 색칠하다가 말았던 적이 있는지 체크 -> 3D
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("ListViewController - viewWillDisappear " )
        
        
        
        
        // *** 3D related download function : Same as in Collection view
        
        
        

        
        
//         ***** if local DocumentDirectory has fName then call it, else download from Sotrage ans save it into DocumentDirectory
        
//         1. fName 을 받아서 저장 해 놓고 그걸로 접근: 3DNoFill, 3DBack, dict
//        let selectedFileRef = Database.database().reference().child("objects").child("threeDim").child("\(selectedFname)")
//
//        selectedFileRef.observe(.value, with: { (snapshot) in
//
//            let selectedThreeDim = snapshot.value as! NSDictionary
//            print("selectedThreeDim :   ", selectedThreeDim)
//
//            let threeDimmNoFillRef = Storage.storage().reference(forURL: selectedThreeDim["3DNoFill"]! as! String)
//            let threeDimmBackRef = Storage.storage().reference(forURL: selectedThreeDim["3DBack"]! as! String)
//            let threeDimDict = selectedThreeDim["dict"]
//
////            let twoDimNoFillRef = Storage.storage().reference(forURL: adPath["adImg"]! as! String)
////            twoDimNoFillRef.getData(maxSize: 1*1024*1024) { (adImgData, error) in
////                if error != nil {
////                    print(error?.localizedDescription as Any)
////                } else {
////                    cell?.adImage.image = UIImage(data: adImgData!)
////                }
////
////            }
//
//
//        })

    }
    
    
    
}




extension ListViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        print("categoryNameArr OUT", categoryNameArr.count)
        return categoryNameArr.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if adIndexArr.contains(indexPath.row){ return 350 }
        else { return 180 }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // 광고 이미지를 넣을 인덱스를 미리 위에서 설정해두고 그걸로 가져오도록
        // === Revised
        if adIndexArr.contains(indexPath.row){

            print("=========TABLE VIEW AD ")
            let cell = tableView.dequeueReusableCell(withIdentifier: "AdTableViewCell", for: indexPath) as? AdTableViewCell
            cell?.selectionStyle = .none

            
            // ********************* Firebase *** adImg 뿌려줘야함!!
            
            let adCategoryName = categoryNameArr[indexPath.row]
            
            let adcategoryRef = Database.database().reference().child("objects").child("category").child("\(adCategoryName)")
            
            adcategoryRef.observe(.value, with: { (snapshot) in
                
                let adPath = snapshot.value! as! NSDictionary
                
                let twoDimNoFillRef = Storage.storage().reference(forURL: adPath["adImg"]! as! String)
                twoDimNoFillRef.getData(maxSize: 1*1024*1024) { (adImgData, error) in
                    if error != nil {
                        print(error?.localizedDescription as Any)
                    } else {
                        cell?.adImage.image = UIImage(data: adImgData!)
                    }
                    
                }
            })
            
            return cell!

        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ListTableViewCell", for: indexPath) as? ListTableViewCell
            cell?.objectList.delegate = self as UICollectionViewDelegate
            cell?.objectList.dataSource = self as UICollectionViewDataSource
            cell?.objectList.tag = indexPath.row
            
            // ********************* categoryName
            cell?.objectCategory.text = categoryNameArr[indexPath.row]
            
            cell?.selectionStyle = .none
            cell?.objectList.reloadData()
            return cell!
        }

    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let tableViewCell = cell as? ListTableViewCell else { return }
        tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
        tableViewCell.collectionViewOffset = storedOffsets[indexPath.row] ?? 0
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        guard let tableViewCell = cell as? ListTableViewCell else { return }
        storedOffsets[indexPath.row] = tableViewCell.collectionViewOffset
    }
}



extension ListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // === Revised
        for i in 0..<categoryImageNameArr.count{
            if collectionView.tag == i {
                return categoryImageNameArr[i].count
            }
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ListCollectionViewCell", for: indexPath) as! ListCollectionViewCell
        
        // ************************* Revised + Firebase 2D ***
        for i in 0..<categoryImageNameArr.count{
            if collectionView.tag == i {
                
                let fileName = categoryImageNameArr[i][indexPath.item]
                
                // MARK: - *** Firebase *** download and display 2DNoFill
                
                let twoDimRef = Database.database().reference().child("objects").child("twoDim").child("\(fileName)")
//                let queryRef = twoDimRef.queryOrdered(byChild: "\(self.categoriesNameArr[i])").queryEqual(toValue: fileName)
                
                twoDimRef.observe(.value, with: { (snapshot) in
                    
                    let twoDimNoFillPath = snapshot.value! as! NSDictionary
                    
                    let twoDimNoFillRef = Storage.storage().reference(forURL: twoDimNoFillPath["2DNoFill"]! as! String)
                    twoDimNoFillRef.getData(maxSize: 1*1024*1024) { (imgData, error) in
                        if error != nil {
                            print(error?.localizedDescription as Any)
                        } else {
                            cell.objectImg.image = UIImage(data: imgData!)
                        }
                        
                    }
                    
                })
                
                
                
                // MARK: - *** Firebase *** User has records about that file
                
                
                
            }
        }
        
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        print("At row\(collectionView.tag) \(indexPath.row)")
        
        //컬렉션 뷰의 이미지 선택 시, 해당 이미지 컬러링 페이지로 넘어감
        let vc = storyboard?.instantiateViewController(withIdentifier: "GameViewController") as? GameViewController
        
        selectedFname = categoryImageNameArr[collectionView.tag][indexPath.item]
        
        // ****** Firebse: vc.objectName 을 fName으로 받아서 --> Firebase Uid 아래에 등록 해주기
        let userRef = Database.database().reference().child("users").child("\(userId)").child("fName").child("\(selectedFname)")
        let userWorkInfo = ["Done" : false]
        userRef.updateChildValues(userWorkInfo)
        
        // ******* Pass name to GameViewController
        vc?.objectName = selectedFname

        // 화면 Coloring페이지로 넘어가기
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtindexPath: IndexPath) -> CGSize {

        // === Revised
        if adIndexArr.contains(collectionView.tag){
            let size = CGSize(width: 400, height: 400)
            return size
        }else{
            let size = CGSize(width: 100, height: 150)
            return size
        }
        

    }
}
