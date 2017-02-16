//
//  StorageManager.swift
//  LevelDesigner
//
//  Created by limte on 3/2/17.
//  Copyright © 2017 nus.cs3217.a0101010. All rights reserved.
//

import Foundation

class StorageManager {
    private var levelNamesArr: [String] = []
    private let PATH_LEVEL_NAME = "level-names"
    
    init() {
        levelNamesArr = loadLevelNames()
    }
    
    private func getLevelNamesPath() -> String? {
        let fileManger = FileManager.default
        guard let url = fileManger.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return url.appendingPathComponent(PATH_LEVEL_NAME).path
    }
    
    private func getLevelContentsPath(_ levelName: String) -> String? {
        let fileManger = FileManager.default
        guard let url = fileManger.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return url.appendingPathComponent(levelName).path
    }

    // save level with given levelName, overwrite the content if same levelName exists
    public func save(levelName: String, bubbles: [[GridBubble]]) -> Bool {
        guard levelName != "" else {
            return false
        }
        
        guard let levelNamesPath = getLevelNamesPath() else {
            return false
        }
        
        guard let levelContentsPath = getLevelContentsPath(levelName) else {
            return false
        }
        
        if !levelNamesArr.contains(levelName) {
            levelNamesArr.append(levelName)
        }
        
        NSKeyedArchiver.archiveRootObject(levelNamesArr, toFile: levelNamesPath)
        NSKeyedArchiver.archiveRootObject(bubbles, toFile: levelContentsPath)
        return true
    }
    
    private func loadLevelNames() -> [String] {
        guard let levelNamesPath = getLevelNamesPath() else {
            return []
        }
        
        guard let levelNames = NSKeyedUnarchiver.unarchiveObject(withFile: levelNamesPath) as? [String] else {
            return []
        }
        
        return levelNames
    }
    
    public func loadLevel(levelName: String) -> [[GridBubble]]? {
        guard let levelContentsPath = getLevelContentsPath(levelName) else {
            return nil
        }
        
        guard let data = NSKeyedUnarchiver.unarchiveObject(withFile: levelContentsPath) as? [[GridBubble]] else {
            return nil
        }
        return data
    }
    
    public func getLevelNames() -> [String] {
        return levelNamesArr
    }
}


