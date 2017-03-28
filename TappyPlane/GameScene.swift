//
//  GameScene.swift
//  TappyPlane
//
//  Created by Phyllis Hollingshead on 4/20/15.
//  Copyright (c) 2015 Phyllis Hollingshead. All rights reserved.
//

import SpriteKit


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var bird = SKSpriteNode()
    var background = SKSpriteNode()
    var labelHolder = SKSpriteNode()
    let birdGroup:UInt32 = 1
    let objectGroup:UInt32 = 2
    let gapGroup:UInt32 = 0 << 3
    var gameOver = 0
    var score = 0
    var movingObjects = SKNode()
    var scoreLabel = SKLabelNode()
    var gameLabel = SKLabelNode()
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -5)
        self.addChild(movingObjects)
        
        makeBackground()
        
        self.addChild(labelHolder)
        
        //create score label
        scoreLabel.fontName = "Helvetica"
        scoreLabel.fontSize = 60
        scoreLabel.text = "0"
        scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.size.height - 170)
        scoreLabel.zPosition = 9 //zed position is higher than pipes so the score can not be covered by pipes
        self.addChild(scoreLabel)
        
        makeBird()
        
        //make ground
        let ground = SKNode()
        ground.position = CGPoint(x: 0, y: 0)
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.size.width, height: 1))
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.categoryBitMask = objectGroup
        
        self.addChild(ground)
        
        _ = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(GameScene.makePipes), userInfo: nil, repeats: true)
    }
    
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
            movingObjects.addChild(background)
        }
    }
    
    func makeBird() {
        let planeImage = SKTexture(imageNamed: "images/planeRed1.png")
        let planeImage2 = SKTexture(imageNamed: "images/planeRed2.png")
        let planeImage3 = SKTexture(imageNamed: "images/planeRed3.png")
        let animation = SKAction.animate(with: [planeImage, planeImage2, planeImage3], timePerFrame: 0.1)
        let makeBirdFly = SKAction.repeatForever(animation)
        
        bird = SKSpriteNode(texture: planeImage)
        bird.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        bird.run(makeBirdFly)
        
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height/2)
        bird.physicsBody?.isDynamic = true
        bird.physicsBody?.allowsRotation = false
        bird.physicsBody?.categoryBitMask = birdGroup
        bird.physicsBody?.collisionBitMask = objectGroup
        bird.physicsBody?.contactTestBitMask = objectGroup
        bird.physicsBody?.collisionBitMask = gapGroup
        bird.zPosition = 10 //Makes bird always on top because zed position is higher than other images which have a zed position of 0 by default
        
        self.addChild(bird)
    }
    
    func makePipes() {
        if(gameOver == 0 ){
            let pipe1Image = SKTexture(imageNamed: "images/rockDown.png")
            let pipe1 = SKSpriteNode(texture: pipe1Image)
            let pipe2Image = SKTexture(imageNamed: "images/rock.png")
            let pipe2 = SKSpriteNode(texture: pipe2Image)
            let gapHeight = bird.size.height
            let moveAmount = arc4random() % UInt32(self.frame.size.height / 2)
            let pipeOffset = CGFloat(moveAmount) - self.frame.size.height / 4
            let addPipes = SKAction.moveBy(x: -self.frame.size.width * 2, y: 0, duration: TimeInterval(self.frame.size.width / 100))
            let removePipes = SKAction.removeFromParent()
            let movePipes = SKAction.sequence([addPipes, removePipes])
            
            pipe1.position = CGPoint(x: self.frame.midX + self.frame.size.width, y: self.frame.midY + pipe1.size.height)
            pipe1.run(movePipes)
            pipe1.physicsBody = SKPhysicsBody(rectangleOf: pipe1.size)
            pipe1.physicsBody?.isDynamic = false
            pipe1.physicsBody?.categoryBitMask = objectGroup
            movingObjects.addChild(pipe1)
            
            pipe2.position = CGPoint(x: self.frame.midX + self.frame.size.width, y: self.frame.midY - pipe2.size.height)
            pipe2.run(movePipes)
            pipe2.physicsBody = SKPhysicsBody(rectangleOf: pipe1.size)
            pipe2.physicsBody?.isDynamic = false
            pipe2.physicsBody?.categoryBitMask = objectGroup
            movingObjects.addChild(pipe2)
            
            let gap = SKNode()
            gap.position = CGPoint(x: self.frame.midX + self.frame.size.width, y: self.frame.midY)
            gap.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: pipe1.size.width, height: gapHeight))
            gap.run(movePipes)
            gap.physicsBody?.isDynamic = false
            gap.physicsBody?.collisionBitMask = gapGroup
            gap.physicsBody?.categoryBitMask = gapGroup
            gap.physicsBody?.contactTestBitMask = birdGroup
            movingObjects.addChild(gap)
        }
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        //Called when sprites come in contact with another sprite
        if (contact.bodyA.categoryBitMask == gapGroup || contact.bodyB.categoryBitMask == gapGroup){
            if gameOver == 0{
                score += 1
                scoreLabel.text = "\(score)"
            }
        }else{
            if gameOver == 0{
                gameOver = 1
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
        if(gameOver == 0){
            bird.physicsBody?.velocity = CGVector(dx: 0,dy: 0)
            bird.physicsBody?.applyImpulse(CGVector(dx: 0,dy: 30))
        }else{
            score = 0
            scoreLabel.text = "0"
            movingObjects.removeAllChildren()
            makeBackground()
            bird.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
            labelHolder.removeAllChildren()//this removes only the game over label
            bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            gameOver = 0
            movingObjects.speed = 1
            
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
    }
}
