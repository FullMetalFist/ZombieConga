//
//  GameScene.swift
//  ZombieConga
//
//  Created by Michael Vilabrera on 5/5/15.
//  Copyright (c) 2015 Giving Tree. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    // challenge
    let zomBee = SKSpriteNode(imageNamed: "zombie1")
    var lastTimeUpdate: NSTimeInterval = 0
    var dt: NSTimeInterval = 0
    let zomBeeMovePointsPerSec: CGFloat = 480.0
    var velocity = CGPointZero
    let playableRect: CGRect
    var lastTouchLocation: CGPoint?
    let zomBeeRotateRadiansPerSec: CGFloat = 4.0 * π
    let zomBeeAnimation: SKAction
    let catCollisionSound: SKAction = SKAction.playSoundFileNamed("hitCat.wav", waitForCompletion: false)
    let enemyCollisionSound: SKAction = SKAction.playSoundFileNamed("hitCatLady.wav", waitForCompletion: false)
    
    override init(size: CGSize) {
        let maxApsectRatio: CGFloat = 16.0 / 9.0                    // 1
        let playableHeight = size.width / maxApsectRatio            // 2
        let playableMargin = (size.height - playableHeight) / 2.0   // 3
        playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)   // 4
        var textures: [SKTexture] = []
        for i in 1...4 {
            textures.append(SKTexture(imageNamed: "zombie\(i)"))
        }
        textures.append(textures[2])
        textures.append(textures[1])
        zomBeeAnimation = SKAction.animateWithTextures(textures, timePerFrame: 0.1)
        super.init(size: size)  // 5
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")         // 6
    }
    
    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor.whiteColor()
        let background = SKSpriteNode(imageNamed: "background1")
        
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.anchorPoint = CGPoint(x: 0.5, y: 0.5)    // default
        background.zPosition = -1
        addChild(background)
        
        zomBee.position = CGPoint(x: 400, y: 400)
        zomBee.anchorPoint = CGPoint(x: 0, y: 0)
        //        zomBee.size = CGSizeMake(400, 400)  // more control
        //        zomBee.setScale(2.0)                // easier, default
        
        addChild(zomBee)
        
        zomBee.runAction(SKAction.repeatActionForever(zomBeeAnimation))
        
        runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(spawnEnemy), SKAction.waitForDuration(2.0)])))
        
        runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(spawnCat), SKAction.waitForDuration(1.0)])))
        
        debugDrawPlayableArea()
    }
    
    override func update(currentTime: NSTimeInterval) {
        if lastTimeUpdate > 0 {
            dt = currentTime - lastTimeUpdate
        } else {
            dt = 0
        }
        lastTimeUpdate = currentTime
        //println("\(dt * 1000) milliseconds since last update")
        
        if let lastTouch = lastTouchLocation {
            let diff = lastTouch - zomBee.position
            if (diff.length() <= zomBeeMovePointsPerSec * CGFloat(dt)) {
                zomBee.position = lastTouchLocation!
                velocity = CGPointZero
            }
            else {
                moveSprite(zomBee, velocity: velocity)
                rotateSprite(zomBee, direction: velocity, rotateRadiansPerSec: zomBeeRotateRadiansPerSec)
            }
        }
        
        boundsCheckZombie()
        //checkCollisions()
    }
    
    func moveSprite(sprite: SKSpriteNode, velocity: CGPoint) {
        let amountToMove = velocity * CGFloat(dt)
        println("Amount To Move: \(amountToMove)")
        sprite.position += amountToMove
    }
    
    func moveZomBeeToward(location: CGPoint) {
        startZomBeeAnimation()
        let offset = location - zomBee.position
        let direction = offset.normalized()
        velocity = direction * zomBeeMovePointsPerSec
        stopZomBeeAnimation()
    }
    
    func sceneTouched(touchLocation:CGPoint) {
        lastTouchLocation = touchLocation
        moveZomBeeToward(touchLocation)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch
        let touchLocation = touch.locationInNode(self)
        sceneTouched(touchLocation)
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch
        let touchLocation = touch.locationInNode(self)
        sceneTouched(touchLocation)
    }
    
    // bounds checking
    func boundsCheckZombie() {
        let bottomLeft = CGPoint(x: 0, y: CGRectGetMinY(playableRect))
        let topRight = CGPoint(x: size.width, y: CGRectGetMaxY(playableRect))
        
        if zomBee.position.x <= bottomLeft.x {
            zomBee.position.x = bottomLeft.x
            velocity.x = -velocity.x
        }
        if zomBee.position.x >= topRight.x {
            zomBee.position.x = topRight.x
            velocity.x = -velocity.x
        }
        if zomBee.position.y <= bottomLeft.y {
            zomBee.position.y = bottomLeft.y
            velocity.y = -velocity.y
        }
        if zomBee.position.y >= topRight.y {
            zomBee.position.y = topRight.y
            velocity.y = -velocity.y
        }
    }
    
    func debugDrawPlayableArea() {
        let shape = SKShapeNode()
        let path = CGPathCreateMutable()
        CGPathAddRect(path, nil, playableRect)
        shape.path = path
        shape.strokeColor = SKColor.redColor()
        shape.lineWidth = 4.0
        addChild(shape)
    }
    
    func rotateSprite(sprite: SKSpriteNode, direction: CGPoint, rotateRadiansPerSec: CGFloat) {
        let shortest = shortestAngleBetween(sprite.zRotation, velocity.angle)
        let amountToRotate = min(rotateRadiansPerSec * CGFloat(dt), abs(shortest))
        sprite.zRotation += shortest.sign() * amountToRotate
    }
    
    func spawnEnemy() {
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.position = CGPoint(x: size.width + enemy.size.width/2, y: CGFloat.random(min: CGRectGetMinY(playableRect) + enemy.size.height/2, max: CGRectGetMaxY(playableRect) - enemy.size.height/2))
        addChild(enemy)
        enemy.name = "enemy"
        let actionMove = SKAction.moveToX(-enemy.size.width/2, duration: 2.0)
        let actionRemove = SKAction.removeFromParent()
        enemy.runAction(SKAction.sequence([actionMove, actionRemove]))
    }
    
    func startZomBeeAnimation() {
        if zomBee.actionForKey("animation") == nil {
            zomBee.runAction(SKAction.repeatActionForever(zomBeeAnimation), withKey: "animation")
        }
    }
    
    func stopZomBeeAnimation() {
        zomBee.removeActionForKey("animation")
    }
    
    func spawnCat() {
        let cat = SKSpriteNode(imageNamed: "cat")
        cat.position = CGPoint(x: CGFloat.random(min: CGRectGetMinX(playableRect), max: CGRectGetMaxX(playableRect)), y: CGFloat.random(min: CGRectGetMinY(playableRect), max: CGRectGetMaxY(playableRect)))
        cat.setScale(0)
        addChild(cat)
        cat.name = "cat"
        
        let appear = SKAction.scaleTo(1.0, duration: 0.5)
        
        cat.zRotation = -π / 16.0
        let leftWiggle = SKAction.rotateByAngle(π/8.0, duration: 0.5)
        let rightWiggle = leftWiggle.reversedAction()
        let fullWiggle = SKAction.sequence([leftWiggle, rightWiggle])
        
        let scaleUp = SKAction.scaleBy(1.2, duration: 0.25)
        let scaleDown = scaleUp.reversedAction()
        let fullScale = SKAction.sequence([scaleUp, scaleDown, scaleUp, scaleDown])
        let group = SKAction.group([fullScale, fullWiggle])
        let groupWait = SKAction.repeatAction(group, count: 10)
        
        let disappear = SKAction.scaleTo(0, duration: 0.5)
        let removeFromParent = SKAction.removeFromParent()
        let actions = [appear, groupWait, disappear, removeFromParent]
        cat.runAction(SKAction.sequence(actions))
    }
    
    func zomBeeHitCat(cat: SKSpriteNode) {
        cat.removeFromParent()
        runAction(catCollisionSound)
    }
    
    func zomBeeHitEnemy(enemy: SKSpriteNode) {
        enemy.removeFromParent()
        runAction(enemyCollisionSound)
    }
    
    func checkCollisions() {
        var hitCats: [SKSpriteNode] = []
        enumerateChildNodesWithName("cat", usingBlock: { (node, _) -> Void in
            let cat = node as! SKSpriteNode
            if CGRectIntersectsRect(cat.frame, self.zomBee.frame) {
                hitCats.append(cat)
            }
        })
        for cat in hitCats {
            zomBeeHitCat(cat)
        }
        
        var hitEnemies: [SKSpriteNode] = []
        enumerateChildNodesWithName("enemy", usingBlock: { (node, _) -> Void in
            let enemy = node as! SKSpriteNode
            if CGRectIntersectsRect(CGRectInset(node.frame, 20, 20), self.zomBee.frame) {
                hitEnemies.append(enemy)
            }
        })
        for enemy in hitEnemies {
            zomBeeHitEnemy(enemy)
        }
    }
    
    override func didEvaluateActions() {
        checkCollisions()
    }
}
