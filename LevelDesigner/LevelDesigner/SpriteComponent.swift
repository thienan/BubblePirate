//
//  SpriteComponent.swift
//  GameEngine
//
//  Created by limte on 6/2/17.
//  Copyright © 2017 nus.cs3217.a0101010. All rights reserved.
//

import Foundation
import UIKit

class SpriteComponent: Component {
    private static var idCount = 0
    
    let spriteName: String
    let rect: CGRect
    public var alpha: CGFloat = 1.0
    let uniqueId: Int
    private(set) var anchorPoint: CGVector
    var zPosition: CGFloat = 0
    
    init(_ parent: GameObject, _ spriteName: String, _ rect: CGRect, _ anchorPoint: CGVector = CGVector.zero) {
        self.spriteName = spriteName
        self.rect = rect
        self.anchorPoint = anchorPoint
        
        uniqueId = SpriteComponent.idCount
        SpriteComponent.idCount += 1
        
        super.init(parent)
    }
    
    convenience init(_ parent: GameObject, _ spriteName: String, _ rect: CGRect) {
        self.init(parent, spriteName, rect, CGVector.zero)
    }
    
    convenience override init(_ parent: GameObject) {
        self.init(parent, "", CGRect())
    }
}
