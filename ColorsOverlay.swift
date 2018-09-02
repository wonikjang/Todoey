//
//  ColorsOverlay.swift
//  testingScenekitSpritekit
//
//  Created by HayoungKim on 28/07/2018.
//  Copyright © 2018 JangnKim. All rights reserved.
//

import SceneKit
import SpriteKit



class ColorsOverlay: SKScene {
    
    /// Scroll view
    var scrollView: SwiftySKScrollView?
    let scrollViewWidthAdjuster: CGFloat = 1.2
    
    /// Moveable node in the scrollView
    let moveableNode = SKNode()
    // 선택된 색상 전달
    var sendColor:UIColor!
    var selectedColor: Int!
    
    //color buttons
    var colorSprite: SKShapeNode?
    
    //hint button
    var hintSprite: SKShapeNode?
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        
        //        hintSprite = SKSpriteNode(imageNamed: "art.scnassets/hint.png")
        hintSprite = SKShapeNode(circleOfRadius: 30.0)
        //        hintSprite?.size = CGSize(width: 100.0, height: 100.0)
        hintSprite?.position = CGPoint(x: 340, y: 750)
        hintSprite?.xScale = 0.6
        hintSprite?.yScale = 0.6
        //        hintSprite?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        
        self.addChild(hintSprite!)
        
        addChild(moveableNode)
        
        prepareHorizontalScrolling()
        setupColorButton()
        
        sendColor = scrollView?.selectedColor
        selectedColor = scrollView?.selectedBtn
        
        

        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            
            //            print("<<<<<<<<<<<<COLORS OVERLAY>>>>>>>>")
            //            let location = touch.location(in: moveableNode)
            //            let touchedNode = self.nodes(at: location)
            //
            //            copyNode = touchedNode as! SKShapeNode
            //            copyNode.fillColor = .red
            //
            //            print("which node is selected?",touchedNode)
            

            
            //          let location = touch.location(in: self)
            sendColor = scrollView?.selectedColor
            selectedColor = scrollView?.selectedBtn
            
            //          arraySprites[1].fillColor = .blue
            //          arraySprites[1].strokeColor = .clear
            //          arraySprites[1].lineWidth = 2.0

            
        }
    }
    
    func virtualAttackButtonBounds() -> CGRect {
        
        var virtualAttackButtonBounds = CGRect(x: 320, y: 240, width: 45.0, height: 45.0)
        
        
        virtualAttackButtonBounds.origin.y = 40
        
        return virtualAttackButtonBounds
    }
    
    
    
    func setupColorButton() {
        
        let colorImageNames = ["red", "pink", "orange", "yellow", "green", "blue", "purple"]
        // var colorArray = [UIColor.red, UIColor.magenta, UIColor.orange, UIColor.yellow, UIColor.green, UIColor.blue, UIColor.purple]
        
        for i in 0..<colorImageNames.count {
            let imageName = colorImageNames[i]
            
            colorSprite = SKShapeNode(circleOfRadius: 22)
            colorSprite?.position = CGPoint(x: 40+CGFloat(i)*60 , y: 80)
            colorSprite?.name = imageName
            colorSprite?.lineWidth = 2.0
            
            //무조건 첫번째는 선택된 상태
            if i == 0 {
                colorSprite?.fillColor = .clear // fillcolor 가 실제로 보이는 컬러
                colorSprite?.strokeColor = .blue
            }
            else {
                colorSprite?.fillColor = .blue
                colorSprite?.strokeColor = .clear
            }
            
            
            //scene.addChild(colorSprite)
            scrollView?.arraySprites.append(colorSprite!)
            moveableNode.addChild((scrollView?.arraySprites[i])!)
            //          moveableNode.addChild(colorSprite!)
            //
            //
            
            //          let colorSprite = SKSpriteNode(imageNamed: "art.scnassets/colorbutton_" + String(imageName))
            //          colorSprite.blendMode = .subtract
            //          colorSprite.xScale = 1.0
            //          colorSprite.yScale = 1.0
            //          colorSprite.size = CGSize(width: 50.0, height: 50.0)
            //          colorSprite.anchorPoint = CGPoint(x: 0.0, y: 0.0)
        }


        
    }
    
//
//    func virtualAttackButtonBounds() -> CGRect {
//        var virtualAttackButtonBounds = CGRect(x: 0, y: 0, width: 100.0, height: 100.0)
//        virtualAttackButtonBounds.origin.y = 10
//
//        return virtualAttackButtonBounds
//    }
    
    override func willMove(from view: SKView) {
        scrollView?.removeFromSuperview()
        scrollView = nil
    }
    
    //    override func didChangeValue(forKey key: String) {
    //        <#code#>
    //    }
    
    override init(size: CGSize) {
        super.init(size: size)
        //      setupColorButton(with: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
