//
//  CollidableProtocol.swift
//  GameEngine
//
//  Created by limte on 7/2/17.
//  Copyright © 2017 nus.cs3217.a0101010. All rights reserved.
//

import Foundation
import UIKit

protocol CollidableObject {
    var uniqueId: Int { get }
    var isStatic: Bool { get }
    
    func onCollide(_ other: CollidableObject)
    
    func onCollideWithLeftWorldBound()
    
    func onCollideWithRightWorldBound()
    
    func onCollideWithTopWorldBound()
    
    func onCollideWithBtmWorldBound()
    
    func isAlive() -> Bool
    
    func getSphereCollider() -> SphereCollider?
    
    func isEqual(_ other: CollidableObject) -> Bool
}
