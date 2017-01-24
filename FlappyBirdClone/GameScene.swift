//
//  GameScene.swift
//  FlappyBirdClone
//
//  Created by Faysal Ahmed on 1/16/17.
//  Copyright © 2017 Binary5. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var bird = SKSpriteNode()
    
    var bg = SKSpriteNode()
    
    var scoreLabel = SKLabelNode()
    
    var gameOver = SKLabelNode()
    
    var timer = Timer()
    
    var score = 0
    
    enum ColliderType: UInt32 {
        
        case Bird = 1
        case object = 2
        case Gap = 4
    }
    
    var gameover = false
    
    func makePipes() {
        
        let movePipes = SKAction.move(by: CGVector(dx: -2 * self.frame.width, dy: 0), duration: TimeInterval(self.frame.width / 100))
        let removePipes = SKAction.removeFromParent()
        let moveAndRemovePipes = SKAction.sequence([movePipes, removePipes])
        
        let gapHeight = bird.size.height * 4
        
        let movementAmount = arc4random() % UInt32(self.frame.height / 2)
        
        let pipeOffSet = CGFloat(movementAmount) - self.frame.height / 4
        
        let pipeTexture1 = SKTexture(imageNamed: "pipe1.png")
        
        let pipe1 = SKSpriteNode(texture: pipeTexture1)
        
        pipe1.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + pipeTexture1.size().height / 2 + gapHeight / 2 + pipeOffSet)
        pipe1.zPosition = -1
        
        pipe1.run(moveAndRemovePipes)
        
        // set physicsbody to pipe1
        pipe1.physicsBody = SKPhysicsBody(rectangleOf: pipeTexture1.size())
        pipe1.physicsBody!.isDynamic = false
        
        pipe1.physicsBody!.contactTestBitMask = ColliderType.object.rawValue
        pipe1.physicsBody!.collisionBitMask = ColliderType.object.rawValue
        pipe1.physicsBody!.categoryBitMask = ColliderType.object.rawValue
        
        self.addChild(pipe1)
        
        let pipeTexture2 = SKTexture(imageNamed: "pipe2.png")
        
        let pipe2 = SKSpriteNode(texture: pipeTexture2)
        
        pipe2.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY - pipeTexture2.size().height / 2 - gapHeight / 2 + pipeOffSet)
        pipe2.zPosition = -1
        
        pipe2.run(moveAndRemovePipes)
        
        // set physicsbody for pipe2
        
        pipe2.physicsBody = SKPhysicsBody(rectangleOf: pipeTexture2.size())
        pipe2.physicsBody!.isDynamic = false
        
        pipe2.physicsBody!.contactTestBitMask = ColliderType.object.rawValue
        pipe2.physicsBody!.collisionBitMask = ColliderType.object.rawValue
        pipe2.physicsBody!.categoryBitMask = ColliderType.object.rawValue
        
        self.addChild(pipe2)
        
        let gap = SKNode()
        
        gap.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + pipeOffSet)
        
        gap.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: pipeTexture1.size().width, height: gapHeight))
        
        gap.physicsBody!.isDynamic = false
        
        gap.run(moveAndRemovePipes)
        
        gap.physicsBody!.contactTestBitMask = ColliderType.Bird.rawValue
        gap.physicsBody!.collisionBitMask = ColliderType.Gap.rawValue
        gap.physicsBody!.categoryBitMask = ColliderType.Gap.rawValue
        
        self.addChild(gap)
        
        
    }
    
    //MARK: Delegate Method goes here
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if gameover == false {
        
        if contact.bodyA.categoryBitMask == ColliderType.Gap.rawValue || contact.bodyB.categoryBitMask == ColliderType.Gap.rawValue {
            
            score += 1
            
            scoreLabel.text = String(score)
            
        } else {
            
            
            self.speed = 0
            gameover = true
            
            // timer must be invalidate, otherwise it will be created multiple times and bloat the scene
            timer.invalidate()
            
            gameOver.fontName = "Helvetica"
            gameOver.fontSize = 30
            gameOver.text = "Game Over! Tap to Restart"
            gameOver.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
            
            self.addChild(gameOver)
            
            }
        }
    }

    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        
        setupGame()

    }
    
    func setupGame() {
        
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.makePipes), userInfo: nil, repeats: true)
        
        let background = SKTexture(imageNamed: "bg.png")
        
        let moveBGAnimation = SKAction.move(by: CGVector(dx: -background.size().width, dy: 0), duration: 5)
        let shiftBGAnimation = SKAction.move(by: CGVector(dx: background.size().width, dy: 0), duration: 0)
        let moveBGForever = SKAction.repeatForever(SKAction.sequence([moveBGAnimation, shiftBGAnimation]))
        
        var i: CGFloat = 0
        
        while i < 3 {
            
            bg = SKSpriteNode(texture: background)
            bg.position = CGPoint(x: background.size().width * i, y: self.frame.midY)
            bg.size.height = self.frame.height
            
            bg.run(moveBGForever)
            
            bg.zPosition = -2
            
            self.addChild(bg)
            
            i += 1
            
        }
        
        
        
        let texture = SKTexture(imageNamed: "flappy1.png")
        let texture2 = SKTexture(imageNamed: "flappy2.png")
        
        let animation = SKAction.animate(with: [texture, texture2], timePerFrame: 0.3)
        let makeFlappyFlap = SKAction.repeatForever(animation)
        
        bird = SKSpriteNode(texture: texture)
        
        
        
        bird.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        
        bird.run(makeFlappyFlap)
        
        
        bird.physicsBody = SKPhysicsBody(circleOfRadius: texture.size().height / 2)
        bird.physicsBody!.isDynamic = false
        
        
        // Adding Contacts
        
        bird.physicsBody!.contactTestBitMask = ColliderType.object.rawValue
        bird.physicsBody!.collisionBitMask = ColliderType.Bird.rawValue
        bird.physicsBody!.categoryBitMask = ColliderType.Bird.rawValue
        
        self.addChild(bird)
        
        let ground = SKNode()
        
        ground.position = CGPoint(x: self.frame.midX, y: -self.frame.height / 2)
        
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: 1.0))
        
        ground.physicsBody!.isDynamic = false
        
        ground.physicsBody!.contactTestBitMask = ColliderType.object.rawValue
        ground.physicsBody!.collisionBitMask = ColliderType.object.rawValue
        ground.physicsBody!.categoryBitMask = ColliderType.object.rawValue
        
        
        self.addChild(ground)
        
        scoreLabel.fontName = "Helvetica"
        scoreLabel.fontSize = 60
        scoreLabel.text = "0"
        scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.height / 2 - 70)
        
        self.addChild(scoreLabel)
        
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        if gameover == false {
            
            bird.physicsBody!.isDynamic = true
            // Always set velocity before applyimpulse, otherqise it wont work
        
            bird.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
        
            bird.physicsBody!.applyImpulse(CGVector(dx: 0 , dy: 60))
        
        } else {
            
            gameover = false
            score = 0
            self.speed = 1
            self.removeAllChildren()
            
            setupGame()
            
        }
    }
    
        
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
