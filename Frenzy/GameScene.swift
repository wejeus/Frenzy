//
//  GameScene.swift
//  Frenzy
//
//  Created by Samuel Wejéus on 26/08/14.
//  Copyright (c) 2014 Rocket Labs. All rights reserved.
//

import CoreMotion
import SpriteKit
import AVFoundation

class GameScene: SKScene {
    
    var womp = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("wompwomp", ofType: "mp3"))
    var wompwomp = AVAudioPlayer()
    
    let MAX_NUM_CIRCLES = 3
    let MAX_CIRCLE_SCALE:CGFloat = 10
    let margin:CGFloat = 100
    
    let motionManager = CMMotionManager()
    let colors = [SKColor.blackColor(), SKColor.brownColor(), SKColor.blueColor()]
    
    var numCircles = 0
    
    var isPlaying:Bool = false
    var score = 0
    var playerLife = 10;
    
    var level:Int = 1
    var levelSpeed:CGFloat = 0.02
    var scoreLevelMultiplier = 1.5
    var numKilled:Int = 0
    let levelCap:Int = 10
    var lives:UILabel = UILabel()
    
    /* Setup your scene here */
    override func didMoveToView(view: SKView) {
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        self.backgroundColor = SKColor.whiteColor()
        wompwomp = AVAudioPlayer(contentsOfURL: womp, error: nil)
        wompwomp.prepareToPlay()
        
        isPlaying = true
        motionManager.startDeviceMotionUpdates()
    }
    
    /* Called when a touch begins */
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            
            var touchedNode = self.nodeAtPoint(location)
            if touchedNode.isKindOfClass(SKShapeNode) {
                
                let actionDissolve = SKAction.fadeAlphaTo(0, duration:0.2)
                
                let actionRemove = SKAction.runBlock({
                    touchedNode.removeFromParent()
                    self.numCircles--;
                    self.numKilled++
                    
                    println("numKilled: \(self.numKilled)")
                })
                
                touchedNode.runAction(actionDissolve)
                touchedNode.runAction(actionRemove)
            }
        }
    }
    
    // Can also search for sprite in tree! var sprite = self.childNodeWithName("MyJetSprite"); // uses sprite.name = "x" to find (can also use patterns)
    func levelUp() {
        level++
        levelSpeed += levelSpeed
        scoreLevelMultiplier += scoreLevelMultiplier
        numKilled = 0
    }
    
    /* Called before each frame is rendered */
    override func update(currentTime: CFTimeInterval) {
        if numKilled == levelCap {
            levelUp()
        }
        
        if isPlaying {
            // create new nodes
            if (numCircles < MAX_NUM_CIRCLES) {
                let circle = SKShapeNode(circleOfRadius: 15)
                
                var colorId = Int(arc4random_uniform(2))
                circle.fillColor = colors[colorId]
                
                let randX = CGFloat(arc4random_uniform(UInt32(self.frame.width - margin)))
                let randY = CGFloat(arc4random_uniform(UInt32(self.frame.height - margin)))
                
                circle.position = CGPoint(x: randX + margin/2 , y: randY + margin/2)
                self.addChild(circle)
                numCircles++
            }
            
            // increase size of existing nodes
            for node in self.children {
                if let shapeNode = node as? SKShapeNode {
                    shapeNode.xScale += levelSpeed
                    shapeNode.yScale += levelSpeed
                    
                    // test if circle have exploded
                    
                    // TODO! So this clearly does not work since when we are removing the node
                    // we do animation that scale the fuck of of this fucker and this will break
                    if shapeNode.xScale > MAX_CIRCLE_SCALE {
                        playerLife--
                        wompwomp.play()
                        shapeNode.fillColor = UIColor.redColor()
                        shapeNode.removeFromParent()
                        self.numCircles--;
                        if playerLife == 0 {
                            println("game over!")
                            isPlaying = false
                            break
                        }
                    }
                }
            }
        }
    }
}
