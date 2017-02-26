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
    
    let UI_Z_POSITION: CGFloat = 99
    let IMAGE_SPRITE = "ring"
    
    convenience init(_ position: CGVector) {
        self.init()
        self.position = position
        addSpriteComponent(IMAGE_SPRITE, CGRect(x: -ringWidth/2, y: -ringWidth/2, width: ringWidth, height: ringWidth))
        spriteComponent?.zPosition = UI_Z_POSITION
    }
}
