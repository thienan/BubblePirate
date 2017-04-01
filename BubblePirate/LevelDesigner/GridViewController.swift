//
//  GridViewController.swift
//  LevelDesigner
//
//  Created by limte on 2/2/17.
//  Copyright © 2017 nus.cs3217.a0101010. All rights reserved.
//

import UIKit

class GridViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    //@IBOutlet weak var gameArea: UIView!
    
    let COLUMN_COUNT = 12
    let COLUMN_COUNT_ODD = 11
    let ROW_COUNT = 9
    let COLUMN_SPACING = 0
    
    
    @IBOutlet var collectionView: UICollectionView!
    
    var cellWidth: CGFloat {
        return UIScreen.main.bounds.size.width / CGFloat(COLUMN_COUNT)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        /*
         let backgroundImage = UIImage(named: "background.png")
         let background = UIImageView(image: backgroundImage)
         
         let gameViewHeight = gameArea.frame.height
         let gameViewWidth = gameArea.frame.width
         background.frame = CGRect(x: 0, y: 0, width: gameViewWidth, height: gameViewHeight)
         gameArea.addSubview(background)
         */
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(COLUMN_SPACING)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section % 2 == 0 {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        } else {
            let sectionVecticalOffset = -10/64 * cellWidth
            return UIEdgeInsets(top: sectionVecticalOffset, left: cellWidth/2, bottom: sectionVecticalOffset, right: cellWidth/2)
        }
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return ROW_COUNT
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section % 2 == 0 {
            return COLUMN_COUNT
        } else {
            return COLUMN_COUNT_ODD
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        cell.layer.cornerRadius = cell.layer.frame.width / 2
        cell.layer.borderWidth = 1.0
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.masksToBounds = true
        cell.layer.backgroundColor = UIColor.gray.withAlphaComponent(CGFloat(0.3)).cgColor
        
        //cell.size
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath)
    }
}

