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
    
    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor.whiteColor()
        let background = SKSpriteNode(imageNamed: "background1")
//        background.position = CGPoint(x: size.width/2, y: size.height/2)
//        background.anchorPoint = CGPointZero
//        background.position = CGPointZero
//        background.zRotation = CGFloat(M_PI)/8
        
        // interesting discovery...
        // remove the anchorPoint & position,
        // with the CGPoint set to center- the
        // background spins across the center.
        // otherwise, the background spins depending on
        // where the anchor point is placed.
        
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.anchorPoint = CGPoint(x: 0.5, y: 0.5)    // default
        background.zPosition = -1
        addChild(background)
        
        zomBee.position = CGPoint(x: 400, y: 400)
        zomBee.anchorPoint = CGPoint(x: 0, y: 0)
        //        zomBee.size = CGSizeMake(400, 400)  // more control
        //        zomBee.setScale(2.0)                // easier, default
        
        addChild(zomBee)
        
//        let theSize = background.size
//        println("Size: \(theSize)")
    }
    
    override func update(currentTime: NSTimeInterval) {
        if lastTimeUpdate > 0 {
            dt = currentTime - lastTimeUpdate
        } else {
            dt = 0
        }
        lastTimeUpdate = currentTime
        println("\(dt * 1000) milliseconds since last update")
//        zomBee.position = CGPoint(x: zomBee.position.x + 4, y: zomBee.position.y)
//        moveSprite(zomBee, velocity: CGPoint(x: zomBeeMovePointsPerSec, y: 0))
        moveSprite(zomBee, velocity: velocity)
    }
    
    func moveSprite(sprite: SKSpriteNode, velocity: CGPoint) {
        // 1
        let amountToMove = CGPoint(x:velocity.x * CGFloat(dt), y:velocity.y * CGFloat(dt))
        println("Amount To Move: \(amountToMove)")
        // 2
        sprite.position = CGPoint(x:  sprite.position.x + amountToMove.x, y: sprite.position.y + amountToMove.y)
    }
    
    func moveZomBeeToward(location: CGPoint) {
        let offset = CGPoint(x: location.x - zomBee.position.x, y: location.y - zomBee.position.y)
        let length = sqrt(Double(offset.x * offset.x + offset.y * offset.y))
        let direction = CGPoint(x: offset.x / CGFloat(length), y: offset.y / CGFloat(length))
        velocity = CGPoint(x: direction.x * zomBeeMovePointsPerSec, y: direction.y * zomBeeMovePointsPerSec)
    }
    
    func sceneTouched(touchLocation:CGPoint) {
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
    //
}
