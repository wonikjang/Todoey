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
//    let ref = Database.database().reference()
    
    let storage = Storage.storage().reference(forURL: "gs://dpolypocket-f16f3.appspot.com")
    
    // SCNScene : Pre-Declaration
    
    var mainScene = SCNScene()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // ==================== 0. Firebase 사용해서 dae파일 업로드

        // 1. Datanase & Storage에 dae 파일들을 Update from a local file

        // Create a reference to the file you want to upload
//        let storageRef = storage.child("objects/animal/splitfaces.dae")
//
//        let key = ref.child("objects").child("animal").childByAutoId().key
//
//        if let localFile = Bundle.main.url(forResource: "art.scnassets/splitfaces", withExtension: "dae") {
//            print("localFile is complete ")
//            do {
//                let data = try Data(contentsOf: localFile, options: .mappedIfSafe)
//                print(" === data  === ")
//
//                // Upload the file to the path "images/rivers.jpg"
//                let uploadTask = storageRef.putFile(from: localFile, metadata: nil) { metadata, error in
//                    guard let metadata = metadata else {
//                        print("Data is not stored into Storage")
//                        return
//                    }
//                    // Metadata contains file metadata such as size, content-type.
//                    // You can also access to download URL after upload.
//                    storageRef.downloadURL { (url, error) in
//
//                        if let url = url {
//
//                            let drawsInfo = ["fileName" : "splitfaces.dae",
//                                             "pathToImage" : url.absoluteString]
//
//                            let drawsImage = ["\(key)" : drawsInfo ]
//
//                            self.ref.child("objects").child("animal").updateChildValues(drawsImage)
//
//                            self.dismiss(animated: true, completion: nil)
//                        } else {
//                            print("url retrieve failed!")
//                        }
//
//                    }
//                }
//                uploadTask.resume()
//
//
//            } catch {
//                print("local file is not loaded")
//            }
//        } else {
//            print("file is not found! ")
//        }

        
        
        // =================== 1.Local device 에 저장 하는 방법

        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let localURL = documentsURL.appendingPathComponent("splitfaces.dae")
        print("localURL")
        print(localURL)
        
        
        // ============ 1st way -->  Database & Storage :" Access to Database and get storage path -->

        // 1.1. Trial 1 --> Success but not the way we want
//        let ref = Database.database().reference()
//        ref.child("objects").child("animal").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
        
        // *** 1.2. Trial 2 --> This is it! Query database by Category & filename
        
        let ref = Database.database().reference().child("objects").child("animal")
        let queryRef = ref.queryOrdered(byChild: "fileName").queryEqual(toValue: "splitfaces.dae")
        
        queryRef.observe(.childAdded, with: { (snapshot) in

            
            let draws = snapshot.value as! [String : NSDictionary]
            
            for (_, value) in draws { // value == AnyObject
                
                
                
                // Step 1 : Download file from Firebse storage to localURL
                
                if let pathToImage = value["pathToImage"] as? String{
                    
                    let storageRef = Storage.storage().reference(forURL: pathToImage)
                    
                    let downloadTask =  storageRef.write( toFile: localURL ) { (url, err)  in
                        if let error = err{
                            print("error while downloading your image :\(error)")
                        }else{
                            print("download complete")
                        }
                    }
                    downloadTask.resume()
                    
                }
                
                // Step 2 : Get necessary information
                

            }
            
        })
        ref.removeAllObservers()
        
        
        // =========== 2nd way --> Only Storage access
        
        
        // Download to the local filesystem
        
//        let storageRef = self.storage.child("objects/animal/splitfaces.dae")
//
//        // Step 1 : Download from Firebse storage
//
//        let downloadTask =  storageRef.write( toFile: localURL ) { (url, err)  in
//            if let error = err{
//                print("error while downloading your image :\(error)")
//            }else{
//                print("download complete")
//            }
//        }
        
        
        
        // Step 2 : Show mainScene
        
        do{
            mainScene = try SCNScene(url: localURL)
        } catch {
            print("mainScene is not imported correctly ")
        }
        
        
        

        
        

        
        
        
        
        
        
        
        
        
        
        
        // ===================== SCNscene Area
        
        
//        mainScene = SCNScene(named: "art.scnassets/splitfaces.dae")!
        mainScene.background.contents = UIImage(named: "art.scnassets/background.png")


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



