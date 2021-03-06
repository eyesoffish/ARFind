//
//  Scene.swift
//  ARFind
//
//  Created by Bolo on 2017/10/11.
//  Copyright © 2017年 Bolo. All rights reserved.
//

import SpriteKit
import ARKit
import GameplayKit
class Scene: SKScene {
    
    let labelTitleNode = SKLabelNode()
    
    var createNodeCount = 0
    var currentNodeCount = 0{
        didSet{
            labelTitleNode.text = "\(currentNodeCount) in your room"
        }
    }
    var myTimer:Timer?
    
    //定时生成对象
    func createNode(){
        if currentNodeCount == 10{
            myTimer?.invalidate()
            myTimer = nil
            return
        }
        
        currentNodeCount += 1
        createNodeCount += 1
        
        //----------生成对象
        guard let sceneView = self.view as? ARSKView else { return }
        //生成随机位置
        let randNumber = GKRandomSource.sharedRandom()
        //生成x轴的旋转矩阵
        let xRotation = simd_float4x4(SCNMatrix4MakeRotation(randNumber.nextUniform() * Float.pi * 2, 1, 0, 0))
        let yRotation = simd_float4x4(SCNMatrix4MakeRotation(randNumber.nextUniform() * Float.pi * 2, 0, 1, 0))
        //合成坐标
        let rotation = simd_mul(xRotation, yRotation)
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -1//摄像头前面一米
        
        let transform = simd_mul(rotation, translation)
        
        let anchor = ARAnchor(transform: transform)
        sceneView.session.add(anchor: anchor)
    }
    
    override func didMove(to view: SKView) {
        // Setup your scene here
        
        labelTitleNode.fontSize = 25
        labelTitleNode.color = .white
        labelTitleNode.position = CGPoint(x: 0, y: view.frame.midY - 50)
        addChild(labelTitleNode)
        currentNodeCount = 0
        
        myTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { timer in
            self.createNode()
        })
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    //AR场景交互
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let sceneView = self.view as? ARSKView else {
//            return
//        }
//        // Create anchor using the camera's current position
//        if let currentFrame = sceneView.session.currentFrame {
//
//            // Create a transform with a translation of 0.2 meters in front of the camera
//            var translation = matrix_identity_float4x4
//            translation.columns.3.z = -0.2//在距离镜头墙两厘米位置设置了一个对象
//            let transform = simd_mul(currentFrame.camera.transform, translation)
//
//            // Add a new anchor to the session
//            let anchor = ARAnchor(transform: transform)
//            sceneView.session.add(anchor: anchor)
//        }
        
        //ar交互
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let currentNodes = nodes(at: location)
        if let node = currentNodes.first{
            currentNodeCount -= 1
            //放大渐变消失
            let scaleOut = SKAction.scale(by: 2, duration: 0.2)
            let fadeOut = SKAction.fadeOut(withDuration: 0.2)
            let group = SKAction.group([scaleOut, fadeOut])
            let sequence = SKAction.sequence([group, SKAction.removeFromParent()])
            
            node.run(sequence)
            
            if currentNodeCount == 0, createNodeCount == 10{
                labelTitleNode.removeFromParent()
                self.addChild(SKSpriteNode(imageNamed: "game_over"))
            }
        }
    }
}
