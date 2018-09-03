//
//  GameViewController.swift
//  0805_Combining3D2D
//
//  Created by HayoungKim on 05/08/2018.
//  Copyright © 2018 JangnKim. All rights reserved.
//

import UIKit
import QuartzCore

import SceneKit
import SpriteKit

import Firebase
import FirebaseDatabase
import FirebaseStorage


class mainSceneController: SCNscene {
    
    // Firebase : database & storage References
    let storage = Storage.storage().reference(forURL: "gs://dpolypocket-f16f3.appspot.com")
    

    // SCNScene : Pre-Declaration
    var mainScene = SCNScene()
    
	// File Info : category & fname 
    let category: String = "animal"
	let fname: String = "splitfaces"

    // ======================== Local device 에 저장 하는 방법
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let localURL3d = documentsURL.appendingPathComponent(fname + ".dae")
	let localURLBack = documentsURL.appendingPathComponent(fname + ".jpg")
        

        
    // ================== Query database by Category & filename
        
    let ref = Database.database().reference().child("objects").child(category)
    let queryRef = ref.queryOrdered(byChild: "fileName").queryEqual(toValue: fname)
        
    queryRef.observe(.childAdded, with: { (snapshot) in

        let draws = snapshot.value as! [String : NSDictionary]
            
        for (_, value) in draws { // value == AnyObject
               
                            
            // Step 1 (3d) : Download file from Firebse storage to localURL
                
            if let pathTo3d = value["pathTo3d"] as? String{
                    
                let storageRef = Storage.storage().reference(forURL: pathTo3d)
                    
                let downloadTask3d =  storageRef.write( toFile: localURL3d ) { (url, err)  in
                    if let error = err{
                        print("error while downloading your image :\(error)")
                    }else{
                        print("download complete")
                    }
                }
                downloadTask3d.resume()
            }
                
            // Step 2 (background) : Get necessary information
                
			if let pathToBack = value["pathToBack"] as? String{
                    
                let storageRef = Storage.storage().reference(forURL: pathToBack)
                    
                let downloadTaskBack =  storageRef.write( toFile: localURLBack ) { (url, err)  in
                    if let error = err{
                        print("error while downloading your image :\(error)")
                    }else{
                        print("download complete")
                    }
                }
                downloadTaskBack.resume()
            }



        }
            
    })
    ref.removeAllObservers()
        

        
    // Step 3 : Get 3d & Background from local URLs
        
    do{
        mainScene = try SCNScene(url: localURL3d)

		// 1st way 
		let backdata = try? Data(contentsOf: localURLBack!) 
		mainScene.background.contents = UIImage(data: backdata!)
			
		// 2nd way 
		mainScene.background.contents = UIImage(url: localURLBack)
        
	} catch {
        print("mainScene is not imported correctly ")
    }
        
        
        
	// =======================  Dictionary --> Color : Face = key : value 


	var nodeArray = mainScene.rootNode.childNodes
    for childNode in nodeArray {
        mainScene.rootNode.addChildNode(childNode as SCNNode)
    }
        
    // 1. 데이터 읽어서 색 / 노드 구분해서 저장하기
        
    // 1.1. itemArray  : node들을 저장 (camera, lamp등 말고, "Solid" 가 이름에 들어간 노드들만)
    // 1.2. colorArray : itemArray에 저장된 node들의 색을 순서대로 저장
        
    var itemsArray = [SCNNode]()
    var colorArray = [UIColor]()
        
    for i in 0..<nodeArray.count {
            
        // Conditional to get nodes that contain "Solid"
        if nodeArray[i].name!.lowercased().contains("Solid".lowercased()){
            itemsArray.append(nodeArray[i])
            colorArray.append(nodeArray[i].geometry?.firstMaterial?.diffuse.contents! as! UIColor)
                
        }
    }
        
        
    // 2. 색 값을 기준으로 여러 노드를 Dictionary 로 저장
        
    // 2.1. Unique Color들을 Dictionary의 Key로 가지기 위해서, 미리 뽑아내기
    let key = Array( Set(colorArray) )
        
    // 2.2. Dictionary of Key(Color) : Value(Multiple Nodes) 를 생성하기
    var newDict = [UIColor: [SCNNode]]()

    for i in 0..<itemsArray.count {
        if let colorInf = itemsArray[i].geometry?.firstMaterial?.diffuse.contents! {
            if key.contains(colorInf as! UIColor) {
                    
                // Dictionary 의 Value 값이 하나의 key에 대해 여러 값을 가질 수 있도록, 해당 array에 더해주는 방식
                newDict[colorInf as! UIColor] = (newDict[colorInf as! UIColor] ?? []) + [itemsArray[i]]
            }
        }
    }

//    print(newDict)
        
    
        
}
    


