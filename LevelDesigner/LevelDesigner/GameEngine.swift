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
    private(set) static var gameObjects: [GameObject] = []
    private static let physicEngine: PhysicEngine = PhysicEngine()
    private let renderEngine: RenderEngine

    init(_ scene: UIView) {
        renderEngine = RenderEngine(scene)
        createDisplayLink()
    }

    private func createDisplayLink() {
        let displaylink = CADisplayLink(target: self, selector: #selector(update))
        displaylink.add(to: .current, forMode: .defaultRunLoopMode)
    }
    
    @objc public func update(displaylink: CADisplayLink) {
        let deltaTime = CGFloat(displaylink.targetTimestamp - displaylink.timestamp)
        updateObjects(deltaTime)
        GameEngine.physicEngine.update(deltaTime, GameEngine.gameObjects)
        renderEngine.update(GameEngine.gameObjects)
        removeDeadObject()
    }

    private func removeDeadObject() {
        // remove gameobject's sprite component from renderer
        let removedObject = GameEngine.gameObjects.filter{!$0.isAlive()}
        renderEngine.removeSpriteComponent(removedObject)
        notifyDestroyed(removedObject)
        GameEngine.gameObjects = GameEngine.gameObjects.filter{$0.isAlive()}
    }
    
    private func notifyDestroyed(_ inGameObject: [GameObject]) {
        for gameObject in inGameObject {
            gameObject.onDestroyed()
        }
    }
    
    private func updateObjects(_ deltaTime: CGFloat) {
        for gameObject in GameEngine.gameObjects {
            gameObject.update(deltaTime)
        }
    }
    
    public func add(_ gameObject: GameObject) {
        GameEngine.gameObjects.append(gameObject)
    }
    
    public func setWorldBound(_ boundRect: CGRect) {
        GameEngine.physicEngine.setWorldBound(boundRect)
    }

    public static func localToWorldPosition(_ parent: GameObject, _ vec: CGVector) -> CGVector {
        return parent.position + vec
    }
    
    public static func rayCast(_ origin: CGVector, _ direction: CGVector) -> GameObject? {
        return GameEngine.physicEngine.rayCast(GameEngine.gameObjects, origin, direction) as? GameObject
    }
}
