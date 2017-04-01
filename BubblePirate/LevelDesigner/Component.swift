//
//  Component.swift
//  GameEngine
//
//  Created by limte on 7/2/17.
//  Copyright © 2017 nus.cs3217.a0101010. All rights reserved.
//

import Foundation
import UIKit

class Component {
    private(set) var parent: GameObject
    public var isActive: Bool = true
    
    init(_ parent: GameObject) {
        self.parent = parent
    }
}
