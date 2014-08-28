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
    
    let womp = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("wompwomp", ofType: "mp3"))
    var wompwomp = AVAudioPlayer()
    let babby = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("crybaby", ofType: "mp3"))
    var crybaby = AVAudioPlayer()
    let unz = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("unz", ofType: "mp3"))
    var unzunz = AVAudioPlayer()
    
    let MAX_NUM_CIRCLES = 3
    let MAX_CIRCLE_SCALE:CGFloat = 5
    let margin:CGFloat = 100
    
    let motionManager = CMMotionManager()
    
    var numCircles = 0
    
    var isPlaying:Bool = false
    var score:Int = 0
    var playerLife = 10;
    
    var level:Int = 1
    var levelSpeed:CGFloat = 0.02
    var scoreLevelMultiplier = 1.1
    var numKilled:Int = 0
    let levelCap:Int = 10
    var lives:UILabel = UILabel()
    var scoreText:UILabel = UILabel()
    
    /* Setup your scene here */
    override func didMoveToView(view: SKView) {
        var bg = SKSpriteNode(imageNamed: "water.jpg")
        
        bg.anchorPoint = CGPoint(x: 0, y: 0)
        bg.size = self.size
        bg.zPosition = -2
        self.addChild(bg)
        
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        self.backgroundColor = SKColor.whiteColor()
        wompwomp = AVAudioPlayer(contentsOfURL: womp, error: nil)
        wompwomp.prepareToPlay()
        crybaby = AVAudioPlayer(contentsOfURL: babby, error: nil)
        crybaby.prepareToPlay()
        unzunz = AVAudioPlayer(contentsOfURL: unz, error: nil)
        unzunz.prepareToPlay()
        unzunz.play()
        
        lives = UILabel(frame: CGRectMake(0, 0, 200, 21))
        lives.backgroundColor = UIColor.blueColor()
        lives.text = "Lives: "+String(playerLife)
        lives.textColor = UIColor.whiteColor()
        self.view.addSubview(lives)
        
        scoreText = UILabel(frame: CGRectMake(200, 0, 400, 21)) // eh
        scoreText.text = "Score: "+String(score)
        scoreText.textColor = UIColor.whiteColor()
        scoreText.backgroundColor = UIColor.blueColor()
        self.view.addSubview(scoreText)
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
                    self.score++
                    // this multiplier is kind of aggressive
                    // var actualScore:Double = Double(Double(self.score) * self.scoreLevelMultiplier)
                    // self.score = Int(actualScore)
                    self.scoreText.text = "Score: "+String(self.score)
                    
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
                
                circle.fillColor = SKColor(red: CGFloat(arc4random_uniform(255)) / 255.0, green: CGFloat(arc4random_uniform(255)) / 255.0, blue: CGFloat(arc4random_uniform(255)) / 255.0, alpha: 1.0)
                
                circle.strokeColor = SKColor.blackColor()
                circle.lineWidth = 1.0
                circle.antialiased = true
                circle.alpha = 1
                
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
                    
                    if shapeNode.xScale > MAX_CIRCLE_SCALE {
                        playerLife--
                        lives.text = "Lives: "+String(playerLife)
                        wompwomp.play()
                        shapeNode.fillColor = UIColor.redColor()
                        shapeNode.removeFromParent()
                        self.numCircles--;
                        if playerLife == 0 {
                            println("game over!")
                            unzunz.stop() // :o
                            crybaby.play() // :(
                            isPlaying = false
                            break
                        }
                    }
                }
            }
        } else {
            // SHOW ALERT HERE OR SOMETHING
        }
    }
}
