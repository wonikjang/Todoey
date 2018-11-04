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

class GameViewController: UIViewController, UINavigationControllerDelegate {
    
    var data = [String]()
    
    var scnView:MainView {return view as! MainView}
    
    private var objectNode: SCNNode?
    var selectedNode: SCNNode!
    
    //선택한 색상이 아닌 다른 색상을 선택 시, haptic feedback 을 제공하기 위함
    let notification = UINotificationFeedbackGenerator()
    
    //임의로 생성. 추후 삭제
    var num:Int  = 0

    // To track selectedNode in Dictionary
    var ColorFaceDict = [String: [SCNNode]]()
    
    /// Scroll view & selectedColor
    var scrollView: SwiftySKScrollView?
    
    // 10.18 추가 : Page Title을 object명으로 받기 위함
    var objectName = ""
    
    // 10.21 추가 : 삭제된 노드를 전달하기 위한 임시 변수
    var deletedTemp: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        
        //Double tap하여 position reset 되는 현상을 막기 위한 custom camera control 생성
        setupGestures()
        
        // scnView 로 부터 objectNode ( 그룹장 )  엎어치기 --> 이걸해야 3D Object가 돌아 감!!!
        objectNode = scnView.objectNode
        
        
        
        // 10.18 추가 : object명으로 title 변경
        self.title = objectName
        
        // 10.18 추가 : back button에 생성되는 text 삭제
        self.navigationController?.navigationBar.topItem?.title = ""
        
        
        
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("GameViewController - viewWillAppear " )
        
        // Check user has files(fName) in DocumentDirectory
        
        
        
    }
    
    
    func saveUserWork(){
    
        // 1.0 Firebase Database/Storage 로 작업중인 파일 (3DWork,back, 2DWork,dict) 을 upload --> Storage로 부터 Local Document로 다운

        // 1.1 FireBase
        
        

        // 1.2 UseerDafualts
//        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//        let localURL = documentsURL.appendingPathComponent( objectName + "/" + " .dae")

        
    
    }
    
    // Home 버튼 눌렸을때를 대비해서
    @objc func willResignActive() {
        print("willResignActive")
        // saveUserWork() : App이 그냥 종료 되버릴때를 대비해서, 작성중이던 파일들 fName/3DWork,back, 2DWork,dict  --> Firebase / UserDefaults에 저장 하도록!
        
    }
    
    // 앞에 화면으로 갈때를 대비해서
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // saveUserWork() : App이 그냥 종료 되버릴때를 대비해서, 작성중이던 파일들 fName/3DWork,2DWork,dict  --> Firebase / UserDefaults에 저장 하도록!

        print(" GameViewController - viewWillDisappear !!! ")

        print(" === Going back To List View === ")
        
//        ListViewController
//        collectionView(UICollectionView, cellForItemAt: IndexPath)

        
        // 3D related download function : Same as in Collection view
//        let notificationCenter = NotificationCenter.default
//        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)



    }
    
    @objc func appMovedToBackground() {
        print("App moved to background!")

    }
    
    
    
    // MARK: - Touch
    
    //3D Object Coloring을 위한 touch 인식
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        
        //coloring하기 위한 색 material 생성
        let changeColor = SCNMaterial()
        changeColor.diffuse.contents = scnView.overlay.scrollView?.selectedColor
        
        // hint 기능 구현
        if scnView.overlay.virtualAttackButtonBounds().contains(touch.location(in: scnView)) {
            print("HINT BUTTON SELECTED")
            //현재 선택된 색상에 해당하는 face array 중, 랜덤으로 한 개의 face에 애니메이션(사용되지 않은 컬러)
            
        } // 제대로 3D face Touch 했을때
        else if let hit = scnView.hitTest(touch.location(in: scnView), options: nil).first {
            selectedNode = hit.node

            // MARK: - Update ColorFaceDict or not
            
            // *** Touched 3D selectedColor 가 ColorCountDict 의 key 이고,
            // *** 2D selectedNode가 그 key 에 대응되는 value 일 경우
            
            // 3D에서 선택된 Face에대한 Dictionary Key ColorFaceDict 로 부터 가져오기
            guard let selectedFaceKey = accessMainView.ColorFaceDict.first(where: {$0.value.contains(selectedNode) } )?.key else{
                return print(" No matching 3D face touched ! ! ! ")
            }
   
            guard let selected2DNode = scnView.overlay.scrollView?.selectedColor?.toHex()! else{
                return print(" No matching 2D node touched ! ! ! ")
            }
            // 3D Face에 해당하는 색과 2D Node에 해당하는 색이 Key로써 ColorCount에 존재할때
            if selectedFaceKey == selected2DNode {
            
                selectedNode.geometry?.materials = [changeColor]
                
                // *** 화면에서 Completed 2D Node 제거 하는 부분이 필요! *** --> Done!!!
                // Error --> 딕셔너리에 이미 해당 Key가 없는데 그 키에 접속해서 Value를 -1 해주려고 해서 Error
                accessMainView.ColorCountDict[ selected2DNode ]! -= 1
                print(" -1 from Count Dictionary ")
                
                //*****10.22 : ColorFaceDict update 같이 해주기
 
                
                // ColorCountDict 의 Value가 0 인지 아닌지
                if accessMainView.ColorCountDict[ selected2DNode ]! == 0 {
                    // Remove from CountDict
                    accessMainView.ColorCountDict.removeValue(forKey: selectedFaceKey)
                    print("removing from ColorCountDict is done!")
                    
                    // Remove from arraysprite
                    if let child = scnView.overlay.moveableNode.childNode(withName: selectedFaceKey) as? SKShapeNode {
                        print(selectedFaceKey)
                        child.removeFromParent()
                        
                        //임시로 테스트. 모든 컬러 색칠 완성됐을 때에 호출 예정
                        accessMainView.endColoring()
                    }
                    //10.19 추가됨 : Color button들 앞으로 당겨지도록 설정하는 함수 호출
                    scnView.overlay.refreshColorButton(deletedBtnName: selectedFaceKey)
                    
                    //10.22 : ColorFaceDict에 아무것도 없을 경우, endColoring()호출
                    
                }
            }
            else {
                print("selectedNode is not included properly")
                notification.notificationOccurred(.warning)
            }
            
            // MARK: - Check whether ColorCountDict has key that has value as 0
//            if let zeroKey = (accessMainView.ColorCountDict as NSDictionary).allKeys(for: 0).first as? String{
//                print("zeroKey : ", zeroKey)
//
//                // Remove form CountDict & NodeNames
//                accessMainView.ColorCountDict.removeValue(forKey: zeroKey)
//                print("removing from ColorCountDict is done!")
//
//                // *** 화면에서 Completed 2D Node 제거 하는 부분이 필요! ***
//                // 1. ColorsOverlay 가 2D node들을 생성하므로, overlay 에대한 접근 필요?
//
//                for idx in 0..<(scnView.overlay.scrollView?.arraySprites.count ?? 0) {
//                    print(scnView.overlay.scrollView?.arraySprites[idx] as Any)
//
//                    if scnView.overlay.scrollView?.arraySprites[idx].name == zeroKey {
//                        print("================================= Remove node from 2D node scroll", idx)
//
//
//                        if let child = scnView.overlay.moveableNode.childNode(withName: zeroKey) as? SKShapeNode {
//                            child.removeFromParent()
//
//                            // 10.21 추가 : 노드가 삭제될 경우, 그 이후의 아이들을 당길 수 있도록 삭제된 버튼 정보 넘겨주기
//                            // deletedTemp = child.name!
//                            deletedTemp = idx
//
//                            //10.19 추가됨 : Color button들 앞으로 당겨지도록 설정하는 함수 호출
//                            scnView.overlay.refreshColorButton(deletedBtnName: deletedTemp!)
//                        }
//                    }
//                    else
//                    { print("zeroKey don't match with any kind of arraySprite") }
//                }
//            }
//            else { print("No zeroKey!") }
        }
    }
    
    // MARK: - UIGestureRecognizer
    
    private func setupGestures() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(sender:)))
        scnView.addGestureRecognizer(pan)
        
        let zoom = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(sender:)))
        scnView.addGestureRecognizer(zoom)
    }
    
    //Pan gesture를 활용한 오브젝트 rotation
    private var currentYAngle: Float = 0.0
    private var currentXAngle: Float = 0.0
    
    @objc func handlePan(sender: UIPanGestureRecognizer){
        let translation = sender.translation(in: sender.view!)
        
        var newAngleX = (Float)(translation.y)*(Float).pi/180.0
        newAngleX += currentXAngle
        var newAngleY = (Float)(translation.x)*(Float).pi/180.0
        newAngleY += currentYAngle
        
        objectNode?.eulerAngles.x = newAngleX
        objectNode?.eulerAngles.y = newAngleY
        
        if(sender.state == UIGestureRecognizer.State.ended) {
            currentXAngle = newAngleX
            currentYAngle = newAngleY
        }
        
        if sender.numberOfTouches == 2 {
            
        }
    }
    
    //Pinch gesture를 활용한 오브젝트 zoom in/zoom out
    private var startScale: Float?
    
    @objc func handlePinch(sender: UIPinchGestureRecognizer){

        if sender.state == .began {
            startScale = objectNode?.scale.x
        }
        guard let startScale = startScale else {
            return
        }
        let newScale: Float = startScale * Float(sender.scale)
        objectNode?.scale = SCNVector3(newScale, newScale, newScale)
        if sender.state == .ended {
            self.startScale = nil
        }
    }
    
    //two finger를 활용한 view pan
    @objc func handleDoubleFinger(sender: UITapGestureRecognizer){
        
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


extension GameViewController {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        (viewController as? ListViewController)?.data = data // Here you pass the to your original view controller
    }
}



