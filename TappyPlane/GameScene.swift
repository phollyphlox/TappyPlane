//
//  GameScene.swift
//  TappyPlane
//
//  Created by Phyllis Hollingshead on 4/20/15.
//  Copyright (c) 2015 Phyllis Hollingshead. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var plane = SKSpriteNode()
    var background = SKSpriteNode()
    var ground = SKSpriteNode()
    var labelHolder = SKSpriteNode()
    let planeGroup:UInt32 = 1 << 0
    let objectGroup:UInt32 = 1 << 1
    let gapGroup:UInt32 = 1 << 2
    var gameOver = false
    var score = 0
    var movingObjects = SKNode()
    var scoreLabel = SKLabelNode()
    var gameLabel = SKLabelNode()
    
    func makeBackground(){
        let backgroundImage = SKTexture(imageNamed: "images/background.png")
        let moveBackground = SKAction.moveBy(x: -backgroundImage.size().width, y: 0, duration: 9)
        let replaceBackground = SKAction.moveBy(x: backgroundImage.size().width, y: 0, duration: 0)
        let moveBackgroundForever = SKAction.repeatForever(SKAction.sequence([moveBackground, replaceBackground]))
        
        for x in 0..<3{
            let i = CGFloat(x)
            background = SKSpriteNode(texture: backgroundImage)
            background.position = CGPoint(x: backgroundImage.size().width/2 + backgroundImage.size().width * i, y: self.frame.midY)
            background.size.height = self.frame.height
            background.run(moveBackgroundForever)
            background.zPosition = -1
            movingObjects.addChild(background)
        }
    }
    
    
    func makePlane() {
        let planeImage = SKTexture(imageNamed: "images/planeRed1.png")
        let planeImage2 = SKTexture(imageNamed: "images/planeRed2.png")
        let planeImage3 = SKTexture(imageNamed: "images/planeRed3.png")
        let animation = SKAction.animate(with: [planeImage, planeImage2, planeImage3], timePerFrame: 0.1)
        let makePlaneFly = SKAction.repeatForever(animation)
        
        plane = SKSpriteNode(texture: planeImage)
        plane.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        plane.run(makePlaneFly)
        
        plane.physicsBody = SKPhysicsBody(circleOfRadius: plane.size.height/2)
        plane.physicsBody?.isDynamic = true
        plane.physicsBody?.allowsRotation = false
        plane.physicsBody?.categoryBitMask = planeGroup
        plane.physicsBody?.collisionBitMask = objectGroup
        plane.physicsBody?.contactTestBitMask = gapGroup | objectGroup
        plane.zPosition = 10 //Makes plane always on top because zed position is higher than other images which have a zed position of 0 by default
        
        self.addChild(plane)
    }
    
    func makeRocks() {
        if(gameOver == false ){
            let rock1Image = SKTexture(imageNamed: "images/rockDownSnow.png")
            let rock1 = SKSpriteNode(texture: rock1Image)
            let rock2Image = SKTexture(imageNamed: "images/rockGrass.png")
            let rock2 = SKSpriteNode(texture: rock2Image)
            let gapHeight = plane.size.height
            let rock1Offset = arc4random() % UInt32(self.frame.size.height / 4)
            let rock2Offset = arc4random() % UInt32(self.frame.size.height / 4)
            let addRocks = SKAction.moveBy(x: -self.frame.size.width * 2, y: 0, duration: TimeInterval(self.frame.size.width / 100))
            let removeRocks = SKAction.removeFromParent()
            let moveRocks = SKAction.sequence([addRocks, removeRocks])
            
            rock1.position = CGPoint(x: self.frame.midX + self.frame.size.width, y: self.frame.midY + rock1Image.size().height / 2 + gapHeight / 2 + CGFloat(rock1Offset))
            rock1.run(moveRocks)
            rock1.physicsBody = SKPhysicsBody(rectangleOf: rock1.size)
            rock1.physicsBody?.isDynamic = false
            rock1.physicsBody?.categoryBitMask = objectGroup
            rock1.zPosition = 1
            movingObjects.addChild(rock1)
            
            rock2.position = CGPoint(x: self.frame.midX + self.frame.size.width, y: self.frame.midY - rock2Image.size().height / 2 - gapHeight / 2 - CGFloat(rock2Offset))
            rock2.run(moveRocks)
            rock2.physicsBody = SKPhysicsBody(rectangleOf: rock1.size)
            rock2.physicsBody?.isDynamic = false
            rock2.physicsBody?.categoryBitMask = objectGroup
            rock2.zPosition = 1
            movingObjects.addChild(rock2)
            
            let gap = SKNode()
            gap.position = CGPoint(x: self.frame.midX + self.frame.size.width, y: self.frame.midY)
            gap.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: rock1.size.width, height: gapHeight))
            gap.run(moveRocks)
            gap.physicsBody?.isDynamic = false
            gap.physicsBody?.categoryBitMask = gapGroup
            gap.physicsBody?.contactTestBitMask = planeGroup
            movingObjects.addChild(gap)
        }
    }
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -5)
        self.addChild(movingObjects)
        
        makeBackground()
        
        //make ground
        let ground = SKNode()
        ground.position = CGPoint(x: 0, y: 0)
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.size.width, height: 1))
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.categoryBitMask = objectGroup
        self.addChild(ground)
        
        //create score label
        self.addChild(labelHolder)
        scoreLabel.fontName = "Helvetica"
        scoreLabel.fontSize = 60
        scoreLabel.text = "0"
        scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.size.height - 170)
        scoreLabel.zPosition = 9 //zed position is higher than rocks so the score can not be covered by rocks
        self.addChild(scoreLabel)
        
        makePlane()
        
        //sets the timer for the intervals when new rocks appear on the scene
        _ = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(GameScene.makeRocks), userInfo: nil, repeats: true)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        //Called when sprites come in contact with another sprite
        if (contact.bodyA.categoryBitMask == gapGroup || contact.bodyB.categoryBitMask == gapGroup){
            if gameOver == false{
                score += 1
                scoreLabel.text = "\(score)"
            }
        }else{
            if gameOver == false{
                gameOver = true
                movingObjects.speed = 0
                gameLabel.fontName = "Helvetica"
                gameLabel.fontSize = 30
                gameLabel.text = "Game Over! Tap to play again."
                gameLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
                gameLabel.zPosition = 10
                labelHolder.addChild(gameLabel)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch begins */
        if(gameOver == false){
            plane.physicsBody?.velocity = CGVector(dx: 0,dy: 0)
            plane.physicsBody?.applyImpulse(CGVector(dx: 0,dy: 30))
        }else{
            score = 0
            scoreLabel.text = "0"
            movingObjects.removeAllChildren()
            makeBackground()
            plane.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
            labelHolder.removeAllChildren()//this removes only the game over label
            plane.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            gameOver = false
            movingObjects.speed = 1
            
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
    }
}
