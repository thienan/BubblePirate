//
//  Level.swift
//  GameEngine
//
//  Created by limte on 25/2/17.
//  Copyright © 2017 nus.cs3217.a0101010. All rights reserved.
//

import Foundation

class Level: NSObject, NSCoding {
    
    private struct Keys {
        static let levelName = "levelName"
        static let star = "star"
    }

    public let levelName: String
    private var stars: Int
    private let MAX_STAR = 3
    
    init(_ levelName: String, _ stars: Int) {
        self.levelName = levelName
        self.stars = min(abs(stars), MAX_STAR)
    }
    
    convenience init(_ levelName: String) {
        self.init(levelName, 0)
    }
    
    public func setFullStar() {
        setStars(MAX_STAR)
    }
    
    public func setStars(_ stars: Int) {
        self.stars = min(abs(stars), MAX_STAR)
    }
    
    public func getStars() -> Int {
        return stars
    }
    
    required convenience init(coder decoder: NSCoder) {
        let decodedString = decoder.decodeObject(forKey: Keys.levelName) as? String ?? ""
        let decodedStar = decoder.decodeInteger(forKey: Keys.star)
        self.init(decodedString, decodedStar)
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(levelName, forKey: Keys.levelName)
        coder.encode(stars, forKey: Keys.star)
    }

    override func isEqual(_ object: Any?) -> Bool {
        return self.levelName == (object as? Level)?.levelName
    }
}
