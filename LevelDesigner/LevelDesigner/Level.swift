//
//  Level.swift
//  GameEngine
//
//  Created by limte on 25/2/17.
//  Copyright © 2017 nus.cs3217.a0101010. All rights reserved.
//

import Foundation

class Level: NSObject, NSCoding  {
    
    private struct Keys {
        static let levelName = "levelName"
    }

    private let levelName: String
    
    init(_ levelName: String) {
        self.levelName = levelName
    }
    
    required convenience init(coder decoder: NSCoder) {
        let decodedString = decoder.decodeObject(forKey: Keys.levelName) as? String ?? ""
        self.init(decodedString)
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(levelName, forKey: Keys.levelName)

    }
}
