//
//  PathManager.swift
//  GameEngine
//
//  Created by limte on 26/2/17.
//  Copyright © 2017 nus.cs3217.a0101010. All rights reserved.
//

import Foundation
import PhysicEngine

class PathManager: GameObject {
    let launcher: Launcher
    let gameEngine: GameEngine
    var spriteObjectPool: [GameObject]
    
    private let IMAGE_AIM_SHOT = "aim-shot"
    let NUM_OF_SPRITES = 60
    let OFFSCREEN_POSITION = CGVector(-100, -100)
    let SPRITE_WIDTH: CGFloat = 20
    let PATH_GAP: CGFloat = 50
    let TO_DEGREE = 180/M_PI
    
    let angleOffset: CGFloat = 90
    let leftVector = CGVector(-1, 0)
    let anchorAtMiddle = CGVector(0.5, 0.5)
    
    init(_ launcher: Launcher, _ gameEngine: GameEngine) {
        self.launcher = launcher
        self.gameEngine = gameEngine
        spriteObjectPool = []
        super.init()
        initPool()
    }
    
    private func initPool() {
        for _ in 0..<NUM_OF_SPRITES {
            let spriteObject = createSprite()
            spriteObject.spriteComponent?.isActive = false
            spriteObjectPool.append(spriteObject)
        }
    }
    
    private func createSprite() -> GameObject {
        let gameObject = GameObject()
        gameObject.addSpriteComponent(IMAGE_AIM_SHOT, CGRect(x: -SPRITE_WIDTH/2, y: -SPRITE_WIDTH/2, width: SPRITE_WIDTH, height: SPRITE_WIDTH), anchorAtMiddle)
        gameEngine.add(gameObject)
        return gameObject
    }

    public override func update(_ deltaTime: CGFloat) {
        deactivateSpriteObjects()
        
        let positions = gameEngine.rayCast(launcher.position + launcher.dir * 130, launcher.dir, PATH_GAP)

        if positions.count < 1 {
            return
        }
        
        for i in 0..<positions.count-1 {
            let object = findInactiveSpriteObject()
            guard let spriteObject = object else { continue }
            
            spriteObject.spriteComponent?.isActive = true
            spriteObject.position = positions[i]
            
            let dir = CGVector.normalize(positions[i+1] - spriteObject.position)
            let dot = CGVector.dot(leftVector, dir)
            spriteObject.rotation = CGFloat(Double(acos(dot)) * TO_DEGREE) - angleOffset
        }
    }

    private func findInactiveSpriteObject() -> GameObject? {
        for spriteObject in spriteObjectPool {
            if spriteObject.position == OFFSCREEN_POSITION {
                return spriteObject
            }
        }
        return nil
    }
    
    private func deactivateSpriteObjects() {
        for spriteObject in spriteObjectPool {
            if spriteObject.position != OFFSCREEN_POSITION {
                spriteObject.position = OFFSCREEN_POSITION
            } else {
                spriteObject.spriteComponent?.isActive = false
            }
            spriteObject.spriteComponent?.alpha = 1
        }
    }
    
    public func getLookAtDir(_ lookAtPoint: CGVector) -> CGVector {
        return CGVector.normalize(lookAtPoint - position)
    }
}
