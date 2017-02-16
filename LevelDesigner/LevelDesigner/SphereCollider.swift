//
//  SphereCollider.swift
//  GameEngine
//
//  Created by limte on 11/2/17.
//  Copyright © 2017 nus.cs3217.a0101010. All rights reserved.
//

import Foundation
import UIKit

protocol SphereCollider {
    var centre: CGVector { get }
    var radius: CGFloat { get }
    var uniqueId: Int { get }
    
    func intersect(_ other: SphereCollider) -> Bool

    func intersect(rightVerticalLine: CGFloat) -> Bool
    
    func intersect(leftVerticalLine: CGFloat) -> Bool
    
    func intersect(topHorizontalLine: CGFloat) -> Bool
    
    func intersect(btmHorizontalLine: CGFloat) -> Bool
    
    func getCenterWorldPosition() -> CGVector
}
