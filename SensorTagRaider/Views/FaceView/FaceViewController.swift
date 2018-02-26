//
//  FaceViewController.swift
//  SensorTagRaider
//
//  Created by Lennart Olsen on 04/02/2018.
//  Copyright © 2018 lennartolsen.net. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore
import SceneKit

class FaceViewController {
    var faceScene : SCNScene!
    var cameraNode : SCNNode!
    
    var faceView : SCNView!
    
    var pacNode : SCNNode!
    
    var rotateX : Float = 0
    var rotateY : Float = 1.0
    var rotateZ : Float = 0
    
    init(scene : SCNView!){
        faceView = scene
        initView()
        initScene()
        initCamera()
        
        createTarget()
    }
    
    func initView(){
        
        faceView.allowsCameraControl = true
        faceView.autoenablesDefaultLighting = true
        
        faceView.backgroundColor = UIColor.lightGray
    }
    
    func initScene(){
        faceScene = SCNScene()
        faceView.scene = faceScene
        
        faceView.isPlaying = true
        
        faceView.showsStatistics = true
    }
    
    func initCamera(){
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        
        cameraNode.position = SCNVector3(x: 0, y: 0.2, z: 2)
        
        faceScene.rootNode.addChildNode(cameraNode)
        
    }
    
    func rotate(x: Double, y: Double, z : Double){
        
        let spin = CABasicAnimation(keyPath: "rotation")
        // Use from-to to explicitly make a full rotation around z
        spin.fromValue = NSValue(scnVector4: SCNVector4(x: rotateX, y: rotateY, z: rotateZ, w: Float(Double.pi)))
        spin.toValue = NSValue(scnVector4: SCNVector4(x: Float(x), y: Float(y), z: Float(z), w: Float(Double.pi)))
        spin.duration = 0.3
        pacNode.addAnimation(spin, forKey: "spin around")
        
        rotateX = Float(x)
        rotateY = Float(y)
        rotateZ = Float(z)
    }
    
    func createTarget(){
        
        pacNode = nodeWithFile(path: "3dassets.scnassets/Pac-Man.dataset/Pac-Man.obj")
        
        pacNode.position = SCNVector3(x: 0, y : 0, z: 0)
        
        pacNode.castsShadow = true
        
        pacNode.rotation = SCNVector4(x: rotateX, y: rotateY, z: rotateZ, w: Float(Double.pi))
        
        pacNode.scale = SCNVector3(x: 0.005, y : 0.005, z: 0.005)
        
        faceScene.rootNode.addChildNode(pacNode)
    }
    
    func cleanUp () {
        for node in faceScene.rootNode.childNodes {
            if node.presentation.position.y < -2 {
                node.removeFromParentNode()
            }
        }
    }
    
    func nodeWithFile(path: String) -> SCNNode {
        
        if let scene = SCNScene(named: path) {
            
            let node = scene.rootNode.childNodes[0] as SCNNode
            
            return node
            
        } else {
            print("Invalid path supplied")
            return SCNNode()
        }
        
    }
}
