//
//  LauncherRing.swift
//  GameEngine
//
//  Created by limte on 23/2/17.
//  Copyright © 2017 nus.cs3217.a0101010. All rights reserved.
//

import Foundation
import UIKit

class LauncherRing: GameObject {
    var ringWidth: CGFloat {
        return GridSettings.cellWidth + 20
    }
    
    convenience init(_ position: CGVector) {
        self.init()
        self.position = position
        addSpriteComponent("ring", CGRect(x: -ringWidth/2, y: -ringWidth/2, width: ringWidth, height: ringWidth))
        spriteComponent?.zPosition = 99
    }
}
