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


class GameViewController: UIViewController {
    
    var scnView: SCNView!
    var selectedNode: SCNNode!
    
    var overlay:ColorsOverlay { return scnView.overlaySKScene as! ColorsOverlay }
    
    //임시로 생성. 추후 서버와 연동시 수정
    var arr : [Int] = [0, 1, 2, 3, 4]


    //선택한 색상이 아닌 다른 색상을 선택 시, haptic feedback 을 제공하기 위함
    let notification = UINotificationFeedbackGenerator()
    
    // Firebase : database & storage References

    
    let storage = Storage.storage().reference(forURL: "gs://dpolypocket-f16f3.appspot.com")
    
    // SCNScene : Pre-Declaration
    
    var mainScene = SCNScene()
    
    let category: String = "animal"
	let fname: String = "splitfaces"



    override func viewDidLoad() {
        super.viewDidLoad()

        
        // ==================== 0. Firebase 사용해서 dae파일 업로드

        // 1. Datanase & Storage에 dae 파일들을 Update from a local file

        // Create a reference to the file you want to upload


		// ====================  Upload 3d file 
		let rootpath3d = "objects/" + category +  "/3d/"
		let fullpath3d = rootpath3d + fname + ".dae"
		
		//		let storageRef3d = storage.child("objects/animal/3d/splitfaces.dae")
		let storageRef3d = storage.child(fullpath3d)



        if let localFile3d = Bundle.main.url(forResource: "art.scnassets/" + fname, withExtension: "dae") {
            print("localFile is complete ")
            do {
                let data = try Data(contentsOf: localFile3d, options: .mappedIfSafe)
                print(" === data is loaded completely  === ")

                // Upload the file to the path "images/rivers.jpg"
                let uploadTask3d = storageRef3d.putFile(from: localFile3d, metadata: nil) { metadata, error in
                    guard let metadata = metadata else {
                        print("Data is not stored into Storage")
                        return
                    }
                    storageRef3d.downloadURL { (url, error) in

                        if let url = url {

                            let drawsInfo = ["fileName" : fname,
                                             "pathTo3d" : url.absoluteString]

                            let drawsImage = ["\(key)" : drawsInfo ]

                            self.ref.child("objects").child(category).updateChildValues(drawsImage)

                            self.dismiss(animated: true, completion: nil)
                        } else {
                           print("Firebase Storage url retrieve failed!")
                        }
                    }
                }
                uploadTask3d.resume()

            } catch {
                print("local file is not loaded")
            }
        } else {
            print("file is not found in Local ! ")
        }


		// ==================== Upload background file 
        
		let rootpathBack = "objects/" + category +"/back/"
		let fullpathBack = rootpath3d + fname + ".jpg"

        let storageRefBack = storage.child(fullpathBack)

        if let localFileBack = Bundle.main.url(forResource: "art.scnassets/" + fname , withExtension: "jpg") {
            print("localFile is complete ")
            do {
                let data = try Data(contentsOf: localFileBack, options: .mappedIfSafe)
                print(" === data is loaded completely  === ")

                // Upload the file to the path "images/rivers.jpg"
                let uploadTaskBack = storageRefBack.putFile(from: localFileBack, metadata: nil) { metadata, error in
                    guard let metadata = metadata else {
                        print("Data is not stored into Storage")
                        return
                    }
                    storageRefBack.downloadURL { (url, error) in

                        if let url = url {

                            let drawsInfo = [ "pathToBack" : url.absoluteString ]

                            let drawsImage = ["\(key)" : drawsInfo ]

                            self.ref.child("objects").child(category).updateChildValues(drawsImage)

                            self.dismiss(animated: true, completion: nil)
                        } else {
                           print("Firebase Storage url retrieve failed!")
                        }
                    }
                }
                uploadTaskBack.resume()

            } catch {
                print("local file is not loaded")
            }
        } else {
            print("file is not found in Local ! ")
        }





        // =================== 1.Local device 에 저장 하는 방법

        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let localURL3d = documentsURL.appendingPathComponent(fname + ".dae")
		let localURLBack = documentsURL.appendingPathComponent(fname + ".jpg")
        
        
        // ============ 1st way -->  Database & Storage :" Access to Database and get storage path -->

        // 1.1. Trial 1 --> Success but not the way we want
//        let ref = Database.database().reference()
//        ref.child("objects").child("animal").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
        
        // *** 1.2. Trial 2 --> This is it! Query database by Category & filename
        
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

        print(newDict)
        
        

        
        
        
        
        
       
        
        // ===================== SCNscene Area
        
        
//        mainScene = SCNScene(named: "art.scnassets/splitfaces.dae")!
//        mainScene.background.contents = UIImage(named: "art.scnassets/background.png")


        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        mainScene.rootNode.addChildNode(cameraNode)

        // place the camera
        cameraNode.position = SCNVector3(x: 1.7, y: 0, z: 8)

        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        mainScene.rootNode.addChildNode(lightNode)

        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        mainScene.rootNode.addChildNode(ambientLightNode)

        // retrieve the SCNView
        scnView = self.view as! SCNView

        // set the scene to the view
        scnView.scene = mainScene

        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true

        // configure the view
        scnView.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
//        scnView.backgroundColor = UIColor(red: 0.96, green: 0.56, blue: 0.69, alpha: 1.0)

        scnView.overlaySKScene = ColorsOverlay(size: view.frame.size)
        scnView.overlaySKScene?.isUserInteractionEnabled = false
        
    }
    

    

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        let touch = touches.first!
        let changeColor = SCNMaterial()

        notification.notificationOccurred(.warning)

        changeColor.diffuse.contents = overlay.scrollView?.selectedColor

        if let hit = scnView.hitTest(touch.location(in: scnView), options: nil).first {
            selectedNode = hit.node
            hit.node.geometry?.firstMaterial = changeColor

            print(selectedNode)

        }

    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    
}



