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
        case purple = 2
        case green = 3
        case black = 4
        case star = 5
        case bomb = 6
        case lightning = 7
        case none = 8
    }
    
    private let OFFSCREEN_POSITION = CGPoint(x: -1, y: -1)
    var position: CGPoint
    
    private struct Keys {
        static let color = "color"
    }
    
    public var color: BubbleColor
    private let FAIL_TO_LOAD_BUBBLE_COLOR = "ERROR: FAIL TO LOAD BUBBLE COLOR"
    
    init(color: BubbleColor) {
        self.color = color
        position = OFFSCREEN_POSITION
    }
    
    public func cycleToNextColor() {
        switch color {
        case .blue:
            color = BubbleColor.red
            
        case .red:
            color = BubbleColor.purple
            
        case .purple:
            color = BubbleColor.green
            
        case .green:
            color = BubbleColor.black
        
        case .black:
            color = BubbleColor.star
        
        case .star:
            color = BubbleColor.bomb
            
        case .bomb:
            color = BubbleColor.lightning
        
        case .lightning:
            color = BubbleColor.none
            
        case .none:
            color = .blue
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

