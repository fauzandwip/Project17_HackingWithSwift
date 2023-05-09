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
    var restart: SKLabelNode!
    
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
    
    var enemyPassed = 0
    var timeInterval = 1.0
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        starfield = SKEmitterNode(fileNamed: "starfield")
        starfield.position = CGPoint(x: 1024, y: 384)
        starfield.advanceSimulationTime(10)
        starfield.zPosition = -1
        addChild(starfield)
        
        createSpaceship()
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        startTimer()
    }
    
    override func update(_ currentTime: TimeInterval) {
        if enemyPassed >= 5 {
            if timeInterval > 0.3 {
                timeInterval -= 0.1
            }
            enemyPassed = 0
            
            gameTimer?.invalidate()
            startTimer()
        }
        
        if !isGameOver {
            score += 1
            
            for node in children {
                if node.position.x < -300 {
                    enemyPassed += 1
                    node.removeFromParent()
                }
            }
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
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = nodes(at: location)
        
        if let restart {
            if nodes.contains(restart) {
                restartGame()
            }
        }
        
        isPlayer("ended", touches: touches)
    }
    
    func isPlayer(_ from: String, touches: Set<UITouch>) {
        
        for touch in touches {
            let nodes = nodes(at: touch.location(in: self))
            for node in nodes {
                if node == player {
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
        gameTimer?.invalidate()
        enemyPassed = 0
        isPlayerTouched = false
        
        restart = SKLabelNode(fontNamed: "Chalkduster")
        restart.name = "restart"
        restart.text = "Restart"
        restart.fontSize = 45
        restart.position = CGPoint(x: 512, y: 384)
        restart.zPosition = 1
        addChild(restart)
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
    
    func restartGame() {
        self.enumerateChildNodes(withName: "restart") { node, stop in
            node.removeFromParent()
        }
        
        score = 0
        enemyPassed = 0
        timeInterval = 1
        isGameOver = false
        
        createSpaceship()
        startTimer()
    }
    
    func createSpaceship() {
        
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 100, y: 384)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.contactTestBitMask = 1
        addChild(player)
    }
    
    func startTimer() {
        gameTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
    }
    
}
