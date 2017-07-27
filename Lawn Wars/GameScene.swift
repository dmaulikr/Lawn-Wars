//
//  GameScene.swift
//  Lawn Wars
//
//  Created by Kefiloe Tsotetsi on 7/18/17.
//  Copyright © 2017 Kefiloe Tsotetsi. All rights reserved.
//

import SpriteKit
import GameplayKit

enum GameSceneState {
    case active, gameOver
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var marty: SKSpriteNode!
    //    var neighbor1: SKSpriteNode?
    //    var neighbor2: SKSpriteNode?
    var neighbor3: SKReferenceNode!
    //    var neighbor4: SKSpriteNode?
    let impulse: Int = 1400
    var obstacleSource: SKNode!
    var obstacleLayer: SKNode!
    /* Add an optional camera target */
    var cameraTarget: SKSpriteNode?
    /* Define a var to hold the camera */
    var sinceTouch : CFTimeInterval = 0
    var cameraNode:SKCameraNode!
    var scrollLayer: SKNode!
    //    var platform: SKSpriteNode?
    let fixedDelta: CFTimeInterval = 1.0 / 60.0 /* 60 FPS */
    let scrollSpeed: CGFloat = 400
    var spawnTimer: CFTimeInterval = 0
    var velocitySwitch: Bool = false
    var points = 0
    var scoreLabel: SKLabelNode!
    var gameState: GameSceneState = .active
    var restartButton: MSButtonNode?
    
    override func didMove(to view: SKView) {
        marty = self.childNode(withName: "//marty") as! SKSpriteNode
        //        neighbor1 = self.childNode(withName: "//neighbor1") as? SKSpriteNode
        //        neighbor2 = self.childNode(withName: "//neighbor2") as? SKSpriteNode
        
        //        neighbor4 = self.childNode(withName: "//neighbor4") as? SKSpriteNode
        
        obstacleLayer = self.childNode(withName: "obstacleLayer")
        neighbor3 = obstacleLayer.childNode(withName: "neighbor3") as! SKReferenceNode
        
        cameraNode = self.childNode(withName: "cameraNode") as! SKCameraNode
        scrollLayer = self.childNode(withName: "scrollLayer")
        
        scoreLabel = self.childNode(withName: "scoreLabel") as! SKLabelNode
        restartButton = self.childNode(withName: "restartButton") as? MSButtonNode
        
        physicsWorld.contactDelegate = self
        
        self.camera = cameraNode
        
//        /* Setup restart button selection handler */
//        restartButton?.selectedHandler = {
//            
//            /* Grab reference to our SpriteKit view */
//            let skView = self.view as SKView!
//            
//            /* Load Game scene */
//            let scene = GameScene(fileNamed:"GameScene") as GameScene!
//            
//            /* Ensure correct aspect mode */
//            scene?.scaleMode = .aspectFill
//            
//            /* Restart game scene */
//            skView?.presentScene(scene)
//            
//        }
        
//        /* Hide restart button */
//        restartButton?.state = .MSButtonNodeStateHidden
        
        /* Reset Score label */
        scoreLabel.text = "\(points)"
        
        restartButton?.isHidden == true
        
        marty.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 300))
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch begins */
        
        velocitySwitch = true
        
//        /* Reset velocity, helps improve response against cumulative falling velocity */
        marty.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
//        
//        /* Apply vertical impulse */
//        marty.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 300))
//        
        /* Apply subtle rotation */
        marty.physicsBody?.applyAngularImpulse(1)
        
        
        /* Reset touch timer */
        sinceTouch = 0
        
        cameraTarget = marty
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        velocitySwitch = false
    }
    
    override func update(_ currentTime: TimeInterval){
        
        /* Skip game update if game no longer active */
        
        /* Check and cap vertical velocity */
//        if velocityY > 400 {
//            marty.physicsBody?.velocity.dy = 400
//        }
        
        if velocitySwitch == true {
            /* Grab current velocity */
            
        marty.physicsBody?.velocity.dy += CGFloat(-400 * fixedDelta)
        }
        
        /* Process world scrolling */
        scrollWorld()
        
        
        /* Process obstacles */
        updateObstacles()
        
        spawnTimer+=fixedDelta
    }
    
    func clamp<T: Comparable>(value: T, lower: T, upper: T) -> T {
        return min(max(value, lower), upper)
    }
    
    func scrollWorld() {
        /* Scroll World */
        scrollLayer.position.x -= scrollSpeed * CGFloat(fixedDelta)
        /* Loop through scroll layer nodes */
        for ground in scrollLayer.children as! [SKReferenceNode] {
            
            /* Get ground node position, convert node position to scene space */
            let groundPosition = scrollLayer.convert(ground.position, to: self)
            
            /* Check if ground sprite has left the scene */
            if groundPosition.x <= -1820 / 2 {
                
                /* Reposition ground sprite to the second starting position */
                let newPosition = CGPoint(x: (self.size.width / 2) + 1442, y: groundPosition.y)
                
                /* Convert new node position back to scroll layer space */
                ground.position = self.convert(newPosition, to: scrollLayer)
           }
        }
    }
    
    func resetCamera() {
        /* Reset camera */
        let cameraReset = SKAction.move(to: CGPoint(x:0, y:camera!.position.y), duration: 1.5)
        let cameraDelay = SKAction.wait(forDuration: 0.5)
        let cameraSequence = SKAction.sequence([cameraDelay,cameraReset])
        cameraNode.run(cameraSequence)
        cameraTarget = nil
    }
    
    //    func updateObstacles() {
    //        /* Update Obstacles */
    //
    //        obstacleLayer.position.x -= scrollSpeed * CGFloat(fixedDelta)
    //
    //        /* Loop through obstacle layer nodes */
    //        for obstacle in obstacleLayer.children as! [SKReferenceNode] {
    //
    //            /* Get obstacle node position, convert node position to scene space */
    //            let obstaclePosition = obstacleLayer.convert(obstacle.position, to: self)
    //
    //            /* Check if obstacle has left the scene */
    //            if obstaclePosition.x <= -26 {
    //                // 26 is one half the width of an obstacle
    //
    //                /* Remove obstacle node from obstacle layer */
    //                obstacle.removeFromParent()
    //            }
    //
    //        }
    //    }
    
    func moveCamera() {
        guard let cameraTarget = cameraTarget else {
            return
        }
        let targetX = cameraTarget.position.x
        let x = clamp(value: targetX, lower: 0, upper: 392)
        cameraNode.position.x = x
    }
    
    //    func removeNeighbor(node: SKNode) {
    //
    //        /* Create our hero death action */
    //        let neighborDeath = SKAction.run({
    //            /* Remove parent node from scene */
    //            node.removeFromParent()
    //        })
    //        self.run(neighborDeath)
    //    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        /* Physics contact delegate implementation */
        /* Get references to the bodies involved in the collision */
        let contactA:SKPhysicsBody = contact.bodyA
        let contactB:SKPhysicsBody = contact.bodyB
        
        let nodeA = contactA.node as! SKSpriteNode
        let nodeB = contactB.node as! SKSpriteNode
        
        print("New contact between A-Cat: \(String(describing: contactA.categoryBitMask)), B-Cat: \(String(describing: contactB.categoryBitMask))")
        
        // Category 2 = Enemy | Category 1 = Marty
        if (contactA.categoryBitMask == 2 && contactB.categoryBitMask == 1) || (contactB.categoryBitMask == 2 && contactA.categoryBitMask == 1) {
            
            if contactA.categoryBitMask == 2 {
                marty.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                marty.physicsBody?.applyImpulse(CGVector(dx: 5, dy: 450))
                nodeA.isHidden = true
                /* Increment points */
                points += 1
                
                /* Update score label */
                scoreLabel.text = String(points)
    
                /* We can return now */
                return
            }
            if contactB.categoryBitMask == 2 {
                marty.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                marty.physicsBody?.applyImpulse(CGVector(dx: 5, dy: 450))
                nodeB.isHidden = true
                
                /* Increment points */
                points += 1
                
                /* Update score label */
                scoreLabel.text = String(points)
                
                /* We can return now */
                return
            }
            
        }
        
       
        
        
        
        /* Run action */
        
        /* Show restart button */
        restartButton?.state = .MSButtonNodeStateActive
        
        /* Collision with the ground */
        if (contactA.categoryBitMask == 8 && contactB.categoryBitMask == 1) || (contactB.categoryBitMask == 8 && contactA.categoryBitMask == 1) {
         gameState = .gameOver
            
            
            /* Reset angular velocity */
            marty.physicsBody?.angularVelocity = 0
            
            /* Stop hero flapping animation */
            marty.removeAllActions()
            restartButton?.isHidden == false

        }
    
    }
    func updateObstacles() {
        /* Update Obstacles */
    
        obstacleLayer.position.x -= scrollSpeed * CGFloat(fixedDelta)
    
        /* Loop through obstacle layer nodes */
        for neighbor3 in (obstacleLayer.children as? [SKReferenceNode])! {
    
            /* Get obstacle node position, convert node ®position to scene space */
            let obstaclePosition = obstacleLayer.convert(neighbor3.position, to: self)
    
            /* Check if obstacle has left the scene */
            //            if obstaclePosition.x <= -26 {
            // 26 is one half the width of an obstacle
    
            /* Remove obstacle node from obstacle layer */
            //                obstacle.removeFromParent()
            //            }
    
       }
    
    
        if spawnTimer >= CFTimeInterval(CGFloat.random(min: 1.5, max: 4)){
    
            /* Create a new obstacle by copying the source obstacle */
            let newObstacle = neighbor3.copy() as! SKReferenceNode
    
            newObstacle.isHidden = false
           let neighborBody: SKSpriteNode = newObstacle.childNode(withName: "//neighborBody") as! SKSpriteNode
            neighborBody.physicsBody?.categoryBitMask = 2
            neighborBody.physicsBody?.contactTestBitMask = 1
    
           obstacleLayer.addChild(newObstacle)
    
    
            /* Generate new r obstacle position, start just outside screen and with a random y value */
            let randomPosition = CGPoint(x: 1352, y: -300)
    
            /* Convert new node position back to obstacle layer space */
            newObstacle.position = self.convert(randomPosition, to: obstacleLayer)
    
            // Reset spawn timer
            spawnTimer = 0
        }
    
    
    }

}
