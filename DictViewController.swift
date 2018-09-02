//
//  ViewController.swift
//  3dColoringTest
//
//  Created by HayoungKim on 09/07/2018.
//  Copyright © 2018 JangnKim. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class ViewController: UIViewController {
    
    var sceneView: SCNView!
    var selectedNode: SCNNode!
    var zDepth: Float!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let scene = SCNScene(named: "coloredTetrahedron.dae")!

        let m1 = SCNMaterial()
        let m2 = SCNMaterial()
        let m3 = SCNMaterial()
        
        m1.diffuse.contents = UIColor.blue
        m2.diffuse.contents = UIColor.red
        m3.diffuse.contents = UIColor.yellow
        
        var nodeArray = scene.rootNode.childNodes
        for childNode in nodeArray {
            scene.rootNode.addChildNode(childNode as SCNNode)
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
        

        // Appendix. sceneView, cameraNode, lightNode 설정값
        let sceneView = SCNView()
        sceneView.frame = self.view.frame
        sceneView.scene = scene
        sceneView.autoenablesDefaultLighting = false
        sceneView.allowsCameraControl = true
        sceneView.backgroundColor = UIColor.darkGray
        self.view = sceneView
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        cameraNode.position = SCNVector3(x: -30, y: 0, z: 100)
        cameraNode.camera?.automaticallyAdjustsZRange = true
        
        let myAmbientLight = SCNLight()
        myAmbientLight.type = SCNLight.LightType.ambient
        myAmbientLight.color = UIColor.white
        let myAmbientLightNode = SCNNode()
        myAmbientLightNode.light = myAmbientLight
        scene.rootNode.addChildNode(myAmbientLightNode)
    }
}
