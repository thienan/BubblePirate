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
    let PATH_GAP: CGFloat = 32
    
    let NUM_OF_SPRITES = 60
    let OFFSCREEN_POSITION = CGVector(-100, -100)
    
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
        gameObject.addSpriteComponent(IMAGE_AIM_SHOT, CGRect(x: -PATH_GAP/2, y: -PATH_GAP/2, width: PATH_GAP, height: PATH_GAP))

        gameEngine.add(gameObject)
        return gameObject
    }

    public override func update(_ deltaTime: CGFloat) {
        deactivateSpriteObjects()
        
        let positions = gameEngine.rayCast(launcher.position + launcher.dir * 130, launcher.dir, 30)
        var spriteObject: GameObject?
        for position in positions {
            spriteObject = findInactiveSpriteObject()
            spriteObject?.spriteComponent?.isActive = true
            spriteObject?.position = position
        }
        spriteObject?.spriteComponent?.alpha = 0.3
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
}
