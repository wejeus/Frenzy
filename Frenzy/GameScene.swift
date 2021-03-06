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
    
    let womp = URL(fileURLWithPath: Bundle.main.path(forResource: "wompwomp", ofType: "mp3")!)
    var wompwomp = AVAudioPlayer()
    let babby = URL(fileURLWithPath: Bundle.main.path(forResource: "crybaby", ofType: "mp3")!)
    var crybaby = AVAudioPlayer()
    let unz = URL(fileURLWithPath: Bundle.main.path(forResource: "unz", ofType: "mp3")!)
    var unzunz = AVAudioPlayer()
    
    let MAX_NUM_CIRCLES = 6
    let MAX_CIRCLE_SCALE:CGFloat = 5
    let margin:CGFloat = 100
    
    let motionManager = CMMotionManager()
    
    var playerOneNumCircles = 0
    var playerTwoNumCircles = 0
    
    var isPlaying:Bool = false
    
    
    var playerOneScore:Int = 0
    var playerOneLife = 10;
    

    var playerTwoScore:Int = 0
    var playerTwoLife = 10

    
    var lives:UILabel = UILabel()
    var scoreText:UILabel = UILabel()
    var numKilled:Int = 0
    let levelCap:Int = 1
    
    var level:Int = 1
    var levelSpeed:CGFloat = 0.02
    var scoreLevelMultiplier = 1.1
    
    var gameOverLabel = SKLabelNode()

    /* Setup your scene here */
    override func didMove(to view: SKView) {
        var bg = SKSpriteNode(imageNamed: "water.jpg")
        
        bg.anchorPoint = CGPoint(x: 0, y: 0)
        bg.size = self.size
        bg.zPosition = -2
        self.addChild(bg)
        
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.backgroundColor = SKColor.white
        
        do {
            wompwomp = try AVAudioPlayer(contentsOf: womp)
            wompwomp.prepareToPlay()
            crybaby = try AVAudioPlayer(contentsOf: babby)
            crybaby.prepareToPlay()
            unzunz = try AVAudioPlayer(contentsOf: unz)
            unzunz.prepareToPlay()
            unzunz.play()
        } catch let error {
            print(error)
        }
        
        lives = UILabel(frame: CGRect(x: 5, y: 0, width: 200, height: 21))
        lives.text = "Lives - P1: \(String(playerOneLife)) P2: \(String(playerTwoLife))"
        lives.textColor = UIColor.white
        self.view?.addSubview(lives)

        scoreText = UILabel(frame: CGRect(x: self.frame.width-100, y: 0, width: 400, height: 21)) // eh
        lives.text = "Score - P1: \(String(playerOneScore)) P2: \(String(playerTwoScore))"
        scoreText.textColor = .white
        self.view?.addSubview(scoreText)
        
        isPlaying = true
        motionManager.startDeviceMotionUpdates()
    }
    
    func showFaster() {
//        let fasterTextLabel = SKLabelNode()
//
//        fasterTextLabel.text = "Faster!!"
//        fasterTextLabel.fontName = "Something Strange"
//        fasterTextLabel.fontSize = 40
//        fasterTextLabel.position = CGPoint(x: (self.frame.width/2)+50, y: (self.frame.height/2)-100)
//        fasterTextLabel.color = SKColor.white
//
//        self.addChild(fasterTextLabel)
//
//
//        let action = SKAction.scale(to: 80, duration: 6)
//
//        let action2 = SKAction.fadeAlpha(to: 0, duration: 1.5)
//
//        let removeAction = SKAction.run({
//            fasterTextLabel.removeFromParent()
//        })
//
//        fasterTextLabel.run(action2)
//        fasterTextLabel.run(SKAction.sequence([action, removeAction]))
    }

    func showGameOver() {
        gameOverLabel = SKLabelNode()
        
        gameOverLabel.text = "Game Over! Continue?"
        gameOverLabel.fontSize = 55
        gameOverLabel.position = CGPoint(x: (self.frame.width/2), y: (self.frame.height/2))
        gameOverLabel.color = SKColor.white
        
        self.addChild(gameOverLabel)
    }
    
    func reset() {
        playerOneLife = 10
        playerOneScore = 0
        playerTwoLife = 10
        playerTwoScore = 0
    
        
        lives.text = "Lives - P1: \(String(playerOneLife)) P2: \(String(playerTwoLife))"
        lives.text = "Score - P1: \(String(playerOneScore)) P2: \(String(playerTwoScore))"
        
        level = 1
        levelSpeed = 0.02
        scoreLevelMultiplier = 1.1
        numKilled = 0
        
        isPlaying = true
        crybaby.stop()
        crybaby.currentTime = 0;
        unzunz.play()
        
        for node in self.children {
            if let shapeNode = node as? SKShapeNode {
                shapeNode.removeFromParent();
            }
        }
        
        playerOneNumCircles = 0
        playerTwoNumCircles = 0
    }
    
    /* Called when a touch begins */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isPlaying {
            return
        }
        
        for touch: UITouch in touches {
            
            let location = touch.location(in: self)
            
            var touchedNodes = self.nodes(at: location)
            for touchedNode in touchedNodes {
                if touchedNode is SKShapeNode && touchedNode.name == "circle" {
                    
                    let actionDissolve = SKAction.fadeAlpha(to: 0, duration:0.2)

                    let animation = SKShapeNode(circleOfRadius: 25)
                    animation.fillColor = SKColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.3)
                    animation.name = "animation"
                    animation.position = location
                    self.addChild(animation)
                    
                    let actionRemove = SKAction.run({
                        touchedNode.removeFromParent()
                        self.numKilled += 1
                        
                        if location.x < self.frame.width/2 {
                            self.playerOneScore += 1
                            self.playerOneNumCircles -= 1
                        } else {
                            self.playerTwoScore += 1
                            self.playerTwoNumCircles -= 1
                        }
                        
                        // this multiplier is kind of aggressive
                        // var actualScore:Double = Double(Double(self.score) * self.scoreLevelMultiplier)
                        // self.score = Int(actualScore)
                        self.lives.text = "Score - P1: \(String(self.playerOneScore)) P2: \(String(self.playerTwoScore))"
                        
                        print("numKilled: \(self.numKilled)")
                    })
                    
                    touchedNode.run(actionDissolve)
                    touchedNode.run(actionRemove)
                    break
                } else if gameOverLabel != nil && touchedNode as NSObject == gameOverLabel {
                    gameOverLabel.removeFromParent()
                    reset()
                    return
                }
            }
        }
    }
    
    // Can also search for sprite in tree! var sprite = self.childNodeWithName("MyJetSprite"); // uses sprite.name = "x" to find (can also use patterns)
    func levelUp() {
        showFaster()
        level += 1
        if levelSpeed < 0.9 {
            levelSpeed += 0.01
        }
        scoreLevelMultiplier += scoreLevelMultiplier
        numKilled = 0
    }
    
    /* Called before each frame is rendered */
    
    override func update(_ currentTime: CFTimeInterval) {
        if numKilled == levelCap {
            levelUp()
        }
        
        if !isPlaying {
            return
        }
        
        if isPlaying {
            // create new nodes
            if (playerOneNumCircles < MAX_NUM_CIRCLES && playerTwoNumCircles < MAX_NUM_CIRCLES) {
                
                
                if playerOneNumCircles < MAX_NUM_CIRCLES/2 {
                    let circle = SKShapeNode(circleOfRadius: 15)
                    circle.name = "circle"
                    
                    circle.strokeColor = SKColor(hue: CGFloat(arc4random_uniform(255)) / 255.0, saturation: 0.9, brightness: 0.8, alpha: 1.0)
                    
                    circle.glowWidth = 1.0
                    circle.lineWidth = 1.0
                    circle.isAntialiased = true
                    circle.alpha = 1
                    
                    circle.fillColor = SKColor.red
                    
                    let randX = CGFloat(arc4random_uniform(UInt32(self.frame.width/2 - margin)))
                    let randY = CGFloat(arc4random_uniform(UInt32(self.frame.height - margin)))
                    circle.position = CGPoint(x: randX + margin/2 , y: randY + margin/2)
                    self.addChild(circle)
                    playerOneNumCircles += 1
                }
                
                if playerTwoNumCircles < MAX_NUM_CIRCLES/2 {
                    let circle = SKShapeNode(circleOfRadius: 15)
                    circle.name = "circle"
                    
                    circle.strokeColor = SKColor(hue: CGFloat(arc4random_uniform(255)) / 255.0, saturation: 0.9, brightness: 0.8, alpha: 1.0)
                    
                    circle.glowWidth = 1.0
                    circle.lineWidth = 1.0
                    circle.isAntialiased = true
                    circle.alpha = 1
                    
                    circle.fillColor = SKColor.blue
                    
                    let randX = CGFloat(arc4random_uniform(UInt32(self.frame.width/2 - margin))) + self.frame.width/2
                    let randY = CGFloat(arc4random_uniform(UInt32(self.frame.height - margin)))
                    circle.position = CGPoint(x: randX + margin/2 , y: randY + margin/2)
                    self.addChild(circle)
                    playerTwoNumCircles += 1
                }
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
                            
                            if shapeNode.fillColor == SKColor.red {
                                playerOneLife -= 1
                                self.playerOneNumCircles -= 1
                            }
                            
                            if shapeNode.fillColor == SKColor.blue {
                                playerTwoLife -= 1
                                self.playerTwoNumCircles -= 1
                            }
                            
                            
                            
                            lives.text = "Lives - P1: \(String(playerOneLife)) P2: \(String(playerTwoLife))"
                            wompwomp.play()
                            
                            shapeNode.fillColor = UIColor.green
                            shapeNode.removeFromParent()
                            
                            if playerOneLife == 0 || playerTwoLife == 0 {
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
