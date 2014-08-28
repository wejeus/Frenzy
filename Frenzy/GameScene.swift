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
    
    var gameOverLabel = SKLabelNode()

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
        
        lives = UILabel(frame: CGRectMake(5, 0, 200, 21))
        lives.text = "Lives: " + String(playerLife)
        lives.textColor = UIColor.whiteColor()
        self.view.addSubview(lives)
        
        scoreText = UILabel(frame: CGRectMake(self.frame.width-100, 0, 400, 21)) // eh
        scoreText.text = "Score: "+String(score)
        scoreText.textColor = UIColor.whiteColor()
        self.view.addSubview(scoreText)
        isPlaying = true
        

    
        motionManager.startDeviceMotionUpdates()
    }
    
    func showFaster() {
        let fasterTextLabel = SKLabelNode()
        
        fasterTextLabel.text = "Faster!!"
        fasterTextLabel.fontName = "Something Strange"
        fasterTextLabel.fontSize = 40
        fasterTextLabel.position = CGPoint(x: (self.frame.width/2)+50, y: (self.frame.height/2)-100)
        fasterTextLabel.color = SKColor.whiteColor()

        self.addChild(fasterTextLabel)


        let action = SKAction.scaleTo(80, duration: 6)

        let action2 = SKAction.fadeAlphaTo(0, duration: 1.5)
        
        let removeAction = SKAction.runBlock({
            fasterTextLabel.removeFromParent()
        })
        
        fasterTextLabel.runAction(action2)
        fasterTextLabel.runAction(SKAction.sequence([action, removeAction]))
    }

    func showGameOver() {
        gameOverLabel = SKLabelNode()
        
        gameOverLabel.text = "Game Over!"
        gameOverLabel.fontSize = 55
        gameOverLabel.position = CGPoint(x: (self.frame.width/2), y: (self.frame.height/2))
        gameOverLabel.color = SKColor.whiteColor()
        
        self.addChild(gameOverLabel)
        
        // TODO: Add NewGame button here
    }
    
    func reset() {
        playerLife = 10
        score = 0
        lives.text = "Lives: "+String(playerLife)
        scoreText.text = "Score: "+String(score)
        
        level = 1
        levelSpeed = 0.02
        scoreLevelMultiplier = 1.1
        numKilled = 0
        
        isPlaying = true
        crybaby.stop()
        crybaby.currentTime = 0;
        unzunz.play()
        
        for node in self.children! {
            if let shapeNode = node as? SKShapeNode {
                shapeNode.removeFromParent();
            }
        }
        numCircles = 0
    }
    
    /* Called when a touch begins */
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        for touch: AnyObject in touches {

            let location = touch.locationInNode(self)
            
            var touchedNodes = self.nodesAtPoint(location)
            for touchedNode in touchedNodes {
                
                if !isPlaying {
                    if gameOverLabel != nil {
                        gameOverLabel.removeFromParent()
                        reset()
                        return
                    }
                }

                if touchedNode.isKindOfClass(SKShapeNode) && touchedNode.name == "circle" {
                    
                    let actionDissolve = SKAction.fadeAlphaTo(0, duration:0.2)

                    let animation = SKShapeNode(circleOfRadius: 25)
                    animation.fillColor = SKColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.3)
                    animation.name = "animation"
                    animation.position = location
                    self.addChild(animation)
                    
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
                    break
                }
            }
        }
    }
    
    // Can also search for sprite in tree! var sprite = self.childNodeWithName("MyJetSprite"); // uses sprite.name = "x" to find (can also use patterns)
    func levelUp() {
        showFaster()
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
                circle.name = "circle"
                
                circle.fillColor = SKColor(hue: CGFloat(arc4random_uniform(255)) / 255.0, saturation: 0.9, brightness: 0.8, alpha: 1.0)
                circle.strokeColor = SKColor(hue: CGFloat(arc4random_uniform(255)) / 255.0, saturation: 0.9, brightness: 0.8, alpha: 1.0)
                
                circle.glowWidth = 1.0
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

                    if (shapeNode.name == "circle") {
                        shapeNode.xScale += levelSpeed
                        shapeNode.yScale += levelSpeed

                        shapeNode.alpha = 1 - 0.75 * (shapeNode.xScale / MAX_CIRCLE_SCALE)
                    
                        // test if circle have exploded
                    
                        if shapeNode.xScale > MAX_CIRCLE_SCALE {
                            playerLife--
                            lives.text = "Lives: "+String(playerLife)
                            wompwomp.play()
                            shapeNode.fillColor = UIColor.redColor()
                            shapeNode.removeFromParent()
                            self.numCircles--;
                            if playerLife == 0 {
                                unzunz.stop() // :o
                                unzunz.currentTime = 0
                                crybaby.play() // :(
                                isPlaying = false

                                showGameOver()

                                break
                            }
                        }
                    } else if (shapeNode.name == "animation") {
                        shapeNode.xScale += 0.5
                        shapeNode.yScale += 0.5

                        shapeNode.alpha = 0.3 - 0.1 * (shapeNode.xScale / (1.5*MAX_CIRCLE_SCALE))
                        if (shapeNode.xScale > 1.5*MAX_CIRCLE_SCALE) {
                            shapeNode.removeFromParent()
                        }
                    }
                }
            }
        } else {
            // SHOW ALERT HERE OR SOMETHING
        }
    }
}
