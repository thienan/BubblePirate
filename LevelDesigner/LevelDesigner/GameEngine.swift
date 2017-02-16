//
//  GameEngine.swift
//  GameEngine
//
//  Created by limte on 6/2/17.
//  Copyright © 2017 nus.cs3217.a0101010. All rights reserved.
//

import Foundation
import UIKit

class GameEngine {
    private(set) var gameObjects: [GameObject] = []
    private let physicEngine: PhysicEngine
    private let renderEngine: RenderEngine

    init(_ scene: UIView) {
        renderEngine = RenderEngine(scene)
        physicEngine = PhysicEngine()
        createDisplayLink()
    }

    private func createDisplayLink() {
        let displaylink = CADisplayLink(target: self, selector: #selector(update))
        displaylink.add(to: .current, forMode: .defaultRunLoopMode)
    }
    
    @objc public func update(displaylink: CADisplayLink) {
        let deltaTime = CGFloat(displaylink.targetTimestamp - displaylink.timestamp)
        updateObjects(deltaTime)
        physicEngine.update(deltaTime, gameObjects)
        renderEngine.update(gameObjects)
        removeDeadObject()
    }

    private func removeDeadObject() {
        // remove gameobject's sprite component from renderer
        let removedObject = gameObjects.filter{!$0.isAlive()}
        renderEngine.removeSpriteComponent(removedObject)
        notifyDestroyed(removedObject)
        gameObjects = gameObjects.filter{$0.isAlive()}
    }
    
    private func notifyDestroyed(_ inGameObject: [GameObject]) {
        for gameObject in inGameObject {
            gameObject.onDestroyed()
        }
    }
    
    private func updateObjects(_ deltaTime: CGFloat) {
        for gameObject in gameObjects {
            gameObject.update(deltaTime)
        }
    }
    
    public func add(_ gameObject: GameObject) {
        gameObjects.append(gameObject)
    }
    
    public func setWorldBound() {
        physicEngine.setWorldBound(CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
    }

    public static func localToWorldPosition(_ parent: GameObject, _ vec: CGVector) -> CGVector {
        return parent.position + vec
    }
}
