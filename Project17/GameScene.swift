//
//  GameScene.swift
//  Project17
//
//  Created by Fauzan Dwi Prasetyo on 09/05/23.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var starfield: SKEmitterNode!
    var player: SKSpriteNode!
    
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    let possibleEnemies = ["ball", "hammer", "tv"]
    var isGameOver = false
    var gameTimer: Timer?
    var isPlayerTouched = false
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        starfield = SKEmitterNode(fileNamed: "starfield")
        starfield.position = CGPoint(x: 1024, y: 384)
        starfield.advanceSimulationTime(10)
        starfield.zPosition = -1
        addChild(starfield)
        
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 100, y: 384)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.contactTestBitMask = 1
        addChild(player)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        gameTimer = Timer.scheduledTimer(timeInterval: 0.35, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
    }
    
    override func update(_ currentTime: TimeInterval) {
        for node in children {
            if node.position.x < -300 {
                node.removeFromParent()
            }
        }
        
        if !isGameOver {
            score += 1
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isPlayerTouched { return }
        guard let touch = touches.first else { return }
        var location = touch.location(in: self)
        
        
        if location.y < 100 {
            location.y = 100
        } else if location.y > 668 {
            location.y = 668
        }
        
        player.position = location
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        isPlayer("began", touches: touches)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        isPlayer("ended", touches: touches)
    }
    
    func isPlayer(_ from: String, touches: Set<UITouch>) {
        
        for touch in touches {
            let nodes = nodes(at: touch.location(in: self))
            for node in nodes {
                if node.contains(player) {
                    switch from {
                    case "began":
                        isPlayerTouched = true
                    case "ended":
                        isPlayerTouched = false
                    default:
                        return
                    }
                }
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let explosion = SKEmitterNode(fileNamed: "explosion")!
        explosion.position = player.position
        addChild(explosion)
        
        player.removeFromParent()
        isGameOver = true
    }
    
    @objc func createEnemy() {
        guard let enemy = possibleEnemies.randomElement() else { return }
        
        let spriteEnemy = SKSpriteNode(imageNamed: enemy)
        spriteEnemy.position = CGPoint(x: 1200, y: Int.random(in: 50...736))
        addChild(spriteEnemy)
        
        spriteEnemy.physicsBody = SKPhysicsBody(texture: spriteEnemy.texture!, size: spriteEnemy.size)
        spriteEnemy.physicsBody?.categoryBitMask = 1
        spriteEnemy.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        spriteEnemy.physicsBody?.angularVelocity = 5
        spriteEnemy.physicsBody?.linearDamping = 0
        // rotate speed
        spriteEnemy.physicsBody?.angularDamping = 0
    }
    
}
