//
//  GridCollectionCell.swift
//  LevelDesigner
//
//  Created by limte on 2/2/17.
//  Copyright © 2017 nus.cs3217.a0101010. All rights reserved.
//

import UIKit

class GridCollectionCell: UICollectionViewCell {
    @IBOutlet weak private var imageView: UIImageView!

    public func clearImage() {
        imageView.image = UIImage()
    }
    
    public func setImage(image: UIImage) {
        imageView.image = image
        // scale image view according to the size of the cell
        imageView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
    }
}
