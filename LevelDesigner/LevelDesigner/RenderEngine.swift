//
//  RenderEngine.swift
//  GameEngine
//
//  Created by limte on 6/2/17.
//  Copyright © 2017 nus.cs3217.a0101010. All rights reserved.
//

import Foundation
import UIKit

class RenderEngine: AnimatedSpriteDelegate {
    private var scene: UIView
    private var imageViews: [Int:UIImageView]
    
    init(_ scene: UIView) {
        self.scene = scene
        imageViews = [:]
    }

    public func update(_ gameObjects: [GameObject]) {
        for gameObject in gameObjects {
            if gameObject.isAlive() == false {
                return
            }
            // if sprite doesnt have spriteComponent
            guard let sprite = gameObject.getSpriteComponent() else {
                continue
            }
            draw(sprite)
        }
    }
    
    public func draw(_ spriteComponent: SpriteComponent) {
        //let worldRec = GameEngine.localToWorldRec(spriteComponent.parent, spriteComponent.rect)
        let imageView = getImageView(spriteComponent)
        imageView.alpha = spriteComponent.alpha
        let angle =  CGFloat(spriteComponent.parent.rotation * CGFloat(M_PI / 180))
        var transform = CGAffineTransform.identity.translatedBy(x: spriteComponent.parent.position.x, y: spriteComponent.parent.position.y)
        transform = transform.rotated(by: angle)
        imageView.transform = transform
    }
    
    private func setAnchorPoint(anchorPoint: CGVector, view: UIView) {
        var newPoint = CGPoint(x: view.bounds.size.width * anchorPoint.x, y: view.bounds.size.height * anchorPoint.y)
        var oldPoint = CGPoint(x: view.bounds.size.width * view.layer.anchorPoint.x, y: view.bounds.size.height * view.layer.anchorPoint.y)
        
        newPoint = newPoint.applying(view.transform)
        oldPoint = oldPoint.applying(view.transform)
        
        var position: CGPoint = view.layer.position
        position.x -= oldPoint.x
        position.x += newPoint.x
        
        position.y -= oldPoint.y
        position.y += newPoint.y
        
        view.layer.position = position
        view.layer.anchorPoint = CGVector.toPoint(anchorPoint)
    }
    
    private func getImageView(_ spriteComponent: SpriteComponent) -> UIImageView {
        // if imageView for the spriteComponent doesnt exists
        guard let imageView = imageViews[spriteComponent.uniqueId] else {
            let newImageView: UIImageView
            
            if let spriteComponent = spriteComponent as? AnimatedSpriteComponent {
                newImageView = createNewAnimatedImageView(spriteComponent)
            } else {
                newImageView = createNewImageView(spriteComponent)
            }
            
            imageViews[spriteComponent.uniqueId] = newImageView
            return newImageView
        }
        return imageView
    }
    
    private func createNewImageView(_ spriteComponent: SpriteComponent) -> UIImageView {
        let image = UIImage(named: spriteComponent.spriteName)
        let newImageView = UIImageView(image: image)
        newImageView.frame = spriteComponent.rect
        newImageView.layer.zPosition = spriteComponent.zPosition
        setAnchorPoint(anchorPoint: spriteComponent.anchorPoint, view: newImageView)
        scene.addSubview(newImageView)
        return newImageView
    }
    
    private func createNewAnimatedImageView(_ spriteComponent: AnimatedSpriteComponent) -> UIImageView {
        spriteComponent.animatedSpriteDelegate = self
        
        let image = UIImage(named: spriteComponent.spriteName)
        let newImageView = UIImageView(image: image)
        newImageView.frame = spriteComponent.rect
        newImageView.layer.zPosition = spriteComponent.zPosition
        setAnchorPoint(anchorPoint: spriteComponent.anchorPoint, view: newImageView)
        
        var uiImages = [UIImage]()
        for image in spriteComponent.animatedSpriteNames {
            // remove question mark
            uiImages.append(UIImage(named: image)!)
        }
        newImageView.animationImages = uiImages
        newImageView.animationDuration = spriteComponent.animationDuration
        newImageView.animationRepeatCount = spriteComponent.animationRepeatCount

        if spriteComponent.autoPlay {
            newImageView.startAnimating()
            Timer.scheduledTimer(timeInterval: newImageView.animationDuration, target: spriteComponent, selector: #selector(spriteComponent.animationFinished), userInfo: nil, repeats: false)
        }
        
        scene.addSubview(newImageView)
        return newImageView
    }

    public func removeSpriteComponent(_ gameObjects: [GameObject]) {
        for gameObject in gameObjects {
            guard let spriteComponent = gameObject.getSpriteComponent() else {
                continue
            }
            guard let imageView = imageViews[spriteComponent.uniqueId] else {
                continue
            }
            imageView.removeFromSuperview()
            imageViews.removeValue(forKey: spriteComponent.uniqueId)
        }
    }
    
    public func play(_ animeSpriteComponent: AnimatedSpriteComponent) {
        guard let imageView = imageViews[animeSpriteComponent.uniqueId] else {
            return
        }
        imageView.startAnimating()
        
        Timer.scheduledTimer(timeInterval: imageView.animationDuration, target: animeSpriteComponent, selector: #selector(animeSpriteComponent.animationFinished), userInfo: nil, repeats: false)
    }
}
