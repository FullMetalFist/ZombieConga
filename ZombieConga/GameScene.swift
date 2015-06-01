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
    
    override init(size: CGSize) {
        let maxApsectRatio: CGFloat = 16.0 / 9.0                    // 1
        let playableHeight = size.width / maxApsectRatio            // 2
        let playableMargin = (size.height - playableHeight) / 2.0   // 3
        playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)   // 4
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
        
        debugDrawPlayableArea()
    }
    
    override func update(currentTime: NSTimeInterval) {
        if lastTimeUpdate > 0 {
            dt = currentTime - lastTimeUpdate
        } else {
            dt = 0
        }
        lastTimeUpdate = currentTime
        println("\(dt * 1000) milliseconds since last update")
        
        if let lastTouch = lastTouchLocation {
            let diff = lastTouch - zomBee.position
            if (diff.length() <= zomBeeMovePointsPerSec * CGFloat(dt)) {
                zomBee.position = lastTouchLocation!
                velocity = CGPointZero
            }
            else {
                moveSprite(zomBee, velocity: velocity)
                rotateSprite(zomBee, direction: velocity)
            }
        }
        
        boundsCheckZombie()
    }
    
    func moveSprite(sprite: SKSpriteNode, velocity: CGPoint) {
        let amountToMove = velocity * CGFloat(dt)
        println("Amount To Move: \(amountToMove)")
        sprite.position += amountToMove
    }
    
    func moveZomBeeToward(location: CGPoint) {
        let offset = location - zomBee.position
        let direction = offset.normalized()
        velocity = direction * zomBeeMovePointsPerSec
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
    
    func rotateSprite(sprite: SKSpriteNode, direction: CGPoint) {
        sprite.zRotation = CGFloat(atan2(Double(direction.y), Double(direction.x)))
    }
}
