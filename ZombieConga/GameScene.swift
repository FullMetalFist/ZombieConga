//
//  GameScene.swift
//  ZombieConga
//
//  Created by Michael Vilabrera on 5/5/15.
//  Copyright (c) 2015 Giving Tree. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
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
        
//        let theSize = background.size
//        println("Size: \(theSize)")
    }
}
