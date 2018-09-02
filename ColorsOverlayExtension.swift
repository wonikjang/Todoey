//
//  ColorListScene.swift
//  testingScenekitSpritekit
//
//  Created by HayoungKim on 29/07/2018.
//  Copyright © 2018 JangnKim. All rights reserved.
//

import SpriteKit

extension ColorsOverlay {
    
    func prepareHorizontalScrolling() {
        // Set up scrollView
        scrollView = SwiftySKScrollView(frame: CGRect(x: 0, y: 30, width: size.width, height: 80), moveableNode: moveableNode, direction: .horizontal)
        
        guard let scrollView = scrollView else { return }
        
        scrollView.center = CGPoint(x: frame.midX, y: 750)
        scrollView.contentSize = CGSize(width: 430, height: 80 ) //ContentSize는 컬러 팔레트 크기(길이)
        
        view?.addSubview(scrollView)
    }
    
    //    func setupColorButton() {
    //
    //        let colorImageNames = ["red", "pink", "orange", "yellow", "green", "blue", "purple"]
    //        // var colorArray = [UIColor.red, UIColor.magenta, UIColor.orange, UIColor.yellow, UIColor.green, UIColor.blue, UIColor.purple]
    //
    //        for i in 0..<colorImageNames.count {
    //            let imageName = colorImageNames[i]
    //
    //            let colorSprite = SKShapeNode(circleOfRadius: 22)
    //
    //            colorSprite.position = CGPoint(x: 40+CGFloat(i)*60 , y: 80)
    //            colorSprite.fillColor = .blue
    //            colorSprite.strokeColor = .clear
    //            colorSprite.name = imageName
    //
    //            //scene.addChild(colorSprite)
    //            moveableNode.addChild(colorSprite)
    //
    //            //          let colorSprite = SKSpriteNode(imageNamed: "art.scnassets/colorbutton_" + String(imageName))
    //            //          colorSprite.blendMode = .subtract
    //            //          colorSprite.xScale = 1.0
    //            //          colorSprite.yScale = 1.0
    //            //          colorSprite.size = CGSize(width: 50.0, height: 50.0)
    //            //          colorSprite.anchorPoint = CGPoint(x: 0.0, y: 0.0)
    //        }
    //    }
}
