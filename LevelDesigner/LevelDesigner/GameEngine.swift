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
    private let scene: UIView
    
    init(_ scene: UIView) {
        self.scene = scene
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
    
    public static func rayCast(_ origin: CGVector, _ direction: CGVector) -> (Bool, GameObject?) {
        return GameEngine.physicEngine.rayCast(GameEngine.gameObjects, origin, direction) as! (Bool, GameObject?)
    }
    
    public func shake() {
        scene.shake()
        //scene.shakeHorizontal()
    }
}

extension UIView {
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.y")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = 0.3
        //animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        animation.values = [-3.0, 0.0, 1.0, 3.0, 2.0, 0.0]
        layer.add(animation, forKey: "shake")
    }
    
    func shakeHorizontal() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = 0.3
        //animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        animation.values = [-2.0, 0.0, 2.0, 0.0, -2.0, 0.0]
        layer.add(animation, forKey: "shake")
    }
}

public extension UIView {
    
    func shake2(count : Float? = nil,for duration : TimeInterval? = nil,withTranslation translation : Float? = nil) {
        let animation : CABasicAnimation = CABasicAnimation(keyPath: "transform.translation.y")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        
        animation.repeatCount = count ?? 2
        animation.duration = (duration ?? 0.5)/TimeInterval(animation.repeatCount)
        animation.autoreverses = true
        animation.byValue = translation ?? -5
        layer.add(animation, forKey: "shake")
    }
}
