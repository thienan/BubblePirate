//
//  GameEngine.swift
//  GameEngine
//
//  Created by limte on 6/2/17.
//  Copyright © 2017 nus.cs3217.a0101010. All rights reserved.
//

import Foundation
import UIKit
import PhysicEngine

class GameEngine {
    private(set) var gameObjects: [GameObject] = []
    private let physicEngine: PhysicEngine = PhysicEngine()
    private let renderEngine: RenderEngine
    private let scene: UIView
    private var displayLink: CADisplayLink?
    public var isPaused: Bool = false
    
    static let SHAKE_DURATION = 0.3
    static let SHAKE_VALUES = [-3.0, 0.0, 1.0, 3.0, 2.0, 0.0]

    init(_ scene: UIView) {
        self.scene = scene
        renderEngine = RenderEngine(scene)
        createDisplayLink()
    }

    private func createDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink?.add(to: .current, forMode: .defaultRunLoopMode)
    }
    
    @objc public func update(displaylink: CADisplayLink) {
        if isPaused { return }
        
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
    
    public func turnOffEngine() {
        renderEngine.removeSpriteComponent(gameObjects)
        gameObjects = []
        displayLink?.invalidate()
    }
    
    public func add(_ gameObject: GameObject) {
        gameObjects.append(gameObject)
    }
    
    public func setWorldBound(_ boundRect: CGRect) {
        physicEngine.setWorldBound(boundRect)
    }

    public static func localToWorldPosition(_ parent: GameObject, _ vec: CGVector) -> CGVector {
        return parent.position + vec
    }
    
    public func rayCast(_ origin: CGVector, _ direction: CGVector, _ radius: CGFloat) -> [CGVector] {
        let physicObjectBody = GameObject()
        physicObjectBody.addSphereColliderComponent(CGVector.zero, radius)
        physicObjectBody.position = origin
        physicObjectBody.velocity = direction * radius
        return physicEngine.rayCast(gameObjects, physicObjectBody)
    }
    
    public func shake() {
        scene.shake()
    }
}

extension UIView {
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.y")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = GameEngine.SHAKE_DURATION
        animation.values = GameEngine.SHAKE_VALUES
        layer.add(animation, forKey: "shake")
    }
}
