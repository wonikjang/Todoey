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
import FirebaseStorage


class GameViewController: UIViewController {
    
    var scnView: SCNView!
    var selectedNode: SCNNode!
    
    var overlay:ColorsOverlay { return scnView.overlaySKScene as! ColorsOverlay }
    
    //임시로 생성. 추후 서버와 연동시 수정
    var arr : [Int] = [0, 1, 2, 3, 4]
    
    
    //firebase
//    let storage = Storage.storage()
//    var data = Data()
//
//    

    //선택한 색상이 아닌 다른 색상을 선택 시, haptic feedback 을 제공하기 위함
    let notification = UINotificationFeedbackGenerator()
    
    // Firebase : database & storage References
    
    let ref = Database.database().reference()
    let storage = Storage.storage().reference(forURL: "gs://dpolypocket-f16f3.appspot.com")
    
    var mainScene = SCNScene()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // < Firebase 사용해서 dae파일 업로드 및 가져오기 >

        // 1. Storage에 dae 파일들을 Manually update - Presumed to be done !
        // 2. Swift code로 database에 업로드
        // 3. Swift에서 database, storage 접근해서 dae 파일 가져오기.
        
        
        // < Start >
        
        // 2. Swift code로 database에 업로드

        let key = ref.child("objects").child("animal").childByAutoId().key

        // Data in memory
        let data = Data()

        let tempImageRef = storage.child("objects/animal/splitfaces.dae")

        let uploadTask = tempImageRef.putData(data, metadata: nil, completion: { (data, error) in

            if error != nil {
                print(error?.localizedDescription)
            }

            tempImageRef.downloadURL(completion: { (url, error) in

                if let url = url {

                    let objectInfo = ["fileName" : "splitfaces.dae",
                                     "pathToImage" : url.absoluteString]

                    let drawsImage = ["\(key)" : objectInfo ]

                    self.ref.child("objects").child("animal").updateChildValues(drawsImage)

                    self.dismiss(animated: true, completion: nil)
                    
                } else {
                    print("url retrieve failed!")
                }

            })


        })
        uploadTask.resume()
        
        
        // 3. Swift에서 database --> storage 접근해서 dae 파일 가져오기.

//        var mainScene = SCNScene()
        
//        var objectPath = Data()
//        var objectPath = URL(string: "")
        
//        var mainScene = SCNScene()
        
        
        fetchDraws()
//        print(mainScene)
        
        
        // create a new scene
//        mainScene = SCNScene(named: "art.scnassets/splitfaces.dae")!
        
        let pathToObject = "https://firebasestorage.googleapis.com/v0/b/dpolypocket-f16f3.appspot.com/o/objects%2Fanimal%2Fsplitfaces.dae?alt=media&token=31a9a64d-b173-4417-bead-8691c0e113e0"
        
        print("pathToObject ======")
        print(pathToObject)
        
        
        let fileUrl = URL(fileURLWithPath: pathToObject)
        print("fileUrl ======")
        print(fileUrl)
        do {
            mainScene = try SCNScene(url: fileUrl)
        } catch {
            print("Unexpected error: \(error).")
        }
        
//        mainScene = SCNScene(named: "https://firebasestorage.googleapis.com/v0/b/dpolypocket-f16f3.appspot.com/o/objects%2Fanimal%2Fsplitfaces.dae?alt=media&token=ecfb73f6-57a5-409c-8656-dcee7700b363")!
        
//        let a = "https://firebasestorage.googleapis.com/v0/b/dpolypocket-f16f3.appspot.com/o/objects%2Fanimal%2Fsplitfaces.dae?alt=media&token=ecfb73f6-57a5-409c-8656-dcee7700b363"
//        print(a)
//
//        let url_a = URL(string: a)
//
//        do {
//            mainScene = try SCNScene(url: url_a! )
//        } catch {
//            print("Unexpected error: \(error).")
//        }
        
        
        
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
    
    func fetchDraws() {
        
        
        let ref = Database.database().reference()
        
        ref.child("objects").child("animal").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            
            let draws = snapshot.value as! [String : NSDictionary]
//            let draws = snapshot.value as! [String : AnyObject] // --> Anyobject can't be read : 에러 원인
            
            for (_, value) in draws { // value == AnyObject
                
                print("===value===")
                print(value)
                if let pathToImage = value["pathToImage"] as? String{
                    print("pathToImage")
                    print(pathToImage)
                    
//                    let storageRef = Storage.storage().reference(forURL: pathToImage)
//                    storageRef.downloadURL { url, error in
//
//                        if error != nil {
//                              print(error!.localizedDescription)
//                        } else {
//                            let fileUrl = URL(string: pathToImage)
//                            print("=== fileURL ===")
//                            print(fileUrl!)
//                            do{
//                                self.mainScene = SCNScene(named: "art.scnassets/splitfaces.dae")!
////                                self.mainScene = try SCNScene(url: fileUrl! , options : nil)
//
//
//                            } catch {
//                                print("Unexpected error: \(error).")
//
//                            }
//
//                        }

                    
                    
                    
                    
                    //                    // Fetch the download URL
                    //                    storageRef.downloadURL { url, error in
                    //                        if let error = error {
                    //                            print(error)
                    //                        } else {
                    //                            print(url!)
                    ////                            let objectPath = url!
                    ////                            let mainScene = try SCNScene(url: url!)
                    //
                    //                      }
                    //                    }
                    
                    //                    let storageRef = Storage.storage().reference(forURL: pathToImage)
                    //
                    //                    storageRef.getData(maxSize: 1*1024*1024) { (data, error) in
                    //                        if error != nil {
                    //                            print(error!.localizedDescription)
                    //                        } else {
                    //                            print(data)
                    //
                    //                            var objectPath = data
                    //                        }
                    //
                    //                    }
                    
                        
//                    }
                }
                
            }
            
        })
        ref.removeAllObservers()
    }
    
    
    
    
    
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first!
        let changeColor = SCNMaterial()
        
        notification.notificationOccurred(.warning)

        
        changeColor.diffuse.contents = overlay.scrollView?.selectedColor
        
//         changeColor.diffuse.contents = UIImage(named: "art.scnassets/pattern3.png")?.flipsForRightToLeftLayoutDirection
//         changeColor.locksAmbientWithDiffuse = true
//        
        
        if let hit = scnView.hitTest(touch.location(in: scnView), options: nil).first {
            selectedNode = hit.node
//            hit.node.geometry?.materials = [changeColor]
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
