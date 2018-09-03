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
    
	// SCNScene 
	var mainScene: mainSceneController?
	var dict: mainScene.newDict


	// SCNView & SCNNode 
    var scnView: SCNView!
    var selectedNode: SCNNode!
    
	// ColorsOverlay ( 2D )
    var overlay: ColorsOverlay { return scnView.overlaySKScene as! ColorsOverlay }

    //선택한 색상이 아닌 다른 색상을 선택 시, haptic feedback 을 제공하기 위함
    let notification = UINotificationFeedbackGenerator()


    override func viewDidLoad() {
        super.viewDidLoad()


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



