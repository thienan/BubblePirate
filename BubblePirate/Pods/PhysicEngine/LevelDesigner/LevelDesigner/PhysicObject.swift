//
//  CollidableProtocol.swift
//  GameEngine
//
//  Created by limte on 7/2/17.
//  Copyright © 2017 nus.cs3217.a0101010. All rights reserved.
//

import Foundation
import UIKit

public protocol PhysicObject {
    var uniqueId: Int { get }
    var velocity: CGVector { get set }
    var position: CGVector { get set }

    func onCollide(_ other: PhysicObject)
    
    func onCollideWithLeftWorldBound()
    
    func onCollideWithRightWorldBound()
    
    func onCollideWithTopWorldBound()
    
    func onCollideWithBtmWorldBound()
    
    func isAlive() -> Bool
    
    func getSphereCollider() -> SphereCollider?
    
    func isEqual(_ other: PhysicObject) -> Bool
}
