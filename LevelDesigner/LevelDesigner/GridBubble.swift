//
//  GridBubble.swift
//  GameEngine
//
//  Created by limte on 9/2/17.
//  Copyright © 2017 nus.cs3217.a0101010. All rights reserved.
//

import Foundation

//
//  Bubble.swift
//  LevelDesigner
//
//  Created by limte on 1/2/17.
//  Copyright © 2017 nus.cs3217.a0101010. All rights reserved.
//

import Foundation
import UIKit

class GridBubble: NSObject, NSCoding {
    public enum BubbleColor: Int {
        case blue = 0
        case red = 1
        case orange = 2
        case green = 3
        case none = 4
    }
    
    var position: CGPoint = CGPoint(x: -1, y: -1)
    
    private struct Keys {
        static let color = "color"
    }
    
    public var color: BubbleColor
    private let FAIL_TO_LOAD_BUBBLE_COLOR = "ERROR: FAIL TO LOAD BUBBLE COLOR"
    
    init(color: BubbleColor) {
        self.color = color
    }
    
    public func cycleToNextColor() {
        switch color {
        case BubbleColor.blue:
            color = BubbleColor.red
            
        case GridBubble.BubbleColor.red:
            color = BubbleColor.orange
            
        case GridBubble.BubbleColor.orange:
            color = BubbleColor.green
            
        case GridBubble.BubbleColor.green:
            color = BubbleColor.blue
            
        case GridBubble.BubbleColor.none:
            color = BubbleColor.none
        }
    }
    
    required convenience init(coder decoder: NSCoder) {
        let colorDecoded = decoder.decodeInteger(forKey: Keys.color)
        guard let bubbleColor = BubbleColor(rawValue: colorDecoded) else {
            self.init(color: BubbleColor.none)
            print(FAIL_TO_LOAD_BUBBLE_COLOR)
            return
        }
        self.init(color: bubbleColor)
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(color.rawValue, forKey: Keys.color)
    }
}

