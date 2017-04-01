//
//  GridSettings.swift
//  GameEngine
//
//  Created by limte on 9/2/17.
//  Copyright © 2017 nus.cs3217.a0101010. All rights reserved.
//

import UIKit

class GridSettings {
    public static let COLUMN_COUNT_EVEN = 12
    public static let COLUMN_COUNT_ODD = 11
    public static let ROW_COUNT = 9
    
    public static var cellWidth: CGFloat {
        return UIScreen.main.bounds.size.width / CGFloat(COLUMN_COUNT_EVEN)
    }
}
