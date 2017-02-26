//
//  LevelSelectCell.swift
//  GameEngine
//
//  Created by limte on 19/2/17.
//  Copyright © 2017 nus.cs3217.a0101010. All rights reserved.
//

import Foundation
import UIKit

class LevelSelectCell: UICollectionViewCell {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var star1: UIImageView!
    @IBOutlet weak var star2: UIImageView!
    @IBOutlet weak var star3: UIImageView!
    
    private let MAX_STARS = 3
    private let OFFSET_X_SIDE_STAR: CGFloat = 60
    private let OFFSET_Y_SIDE_STAR: CGFloat = 35
    private let OFFSET_X_MIDDLE_STAR: CGFloat = 45
    private let OFFSET_Y_LABEL: CGFloat = 35
    
    private let STAR1 = "star1"
    private let STAR2 = "star2"
    private let STAR3 = "star3"
    
    private let STAR_WIN1 = "star-win1"
    private let STAR_WIN2 = "star-win2"
    private let STAR_WIN3 = "star-win3"
    
    public func initCell(stars: Int) {
        scaleImage()
        initStar(stars)
    }
    
    private func initStar(_ stars: Int) {
        let stars = min(abs(stars), MAX_STARS)

        var sprite1 = STAR1
        var sprite2 = STAR2
        var sprite3 = STAR3
        
        if stars == 1 {
            sprite1 = STAR_WIN1
        } else if stars == 2 {
            sprite1 = STAR_WIN1
            sprite2 = STAR_WIN2
        } else if stars >= 3 {
            sprite1 = STAR_WIN1
            sprite2 = STAR_WIN2
            sprite3 = STAR_WIN3
        }
        
        star1.image = UIImage(named: sprite1)
        star2.image = UIImage(named: sprite2)
        star3.image = UIImage(named: sprite3)
        
        star1.center = CGPoint(x: imageView.center.x - OFFSET_X_SIDE_STAR, y: imageView.center.y - OFFSET_Y_SIDE_STAR)
        star2.center = CGPoint(x: imageView.center.x, y: imageView.center.y - OFFSET_X_MIDDLE_STAR)
        star3.center = CGPoint(x: imageView.center.x + OFFSET_X_SIDE_STAR, y: imageView.center.y - OFFSET_Y_SIDE_STAR)
    }
    
    public func scaleImage() {
        imageView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        label.center = CGPoint(x: imageView.center.x, y: imageView.center.y + OFFSET_Y_LABEL)
    }
}
