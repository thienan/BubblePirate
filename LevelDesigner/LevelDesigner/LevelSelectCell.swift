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
    
    @IBAction func buttonPressed(_ sender: Any) {

    }
    
    public func scaleImage() {
        imageView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
    }
    
}
