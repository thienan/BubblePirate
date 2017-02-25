//
//  LevelSelectCollectionController.swift
//  GameEngine
//
//  Created by limte on 19/2/17.
//  Copyright © 2017 nus.cs3217.a0101010. All rights reserved.
//

import UIKit

class LevelSelectCollectionController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    public let storageManager = StorageManager()
    
    var levelNames: [String] = []
    private let SEQ_TO_GAMEPLAY = "levelSelectToGame"
    private var levelName: String = ""
    private let COL_COUNT = 3
    
    //var levelNames = ["a", "b", "c"]
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector((tapGesture))))
        levelNames = storageManager.getLevelNames()
        //self.collectionView?.backgroundColor = UIColor.clear
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func sectionCount() -> Int {
        return Int(ceil(Double(levelNames.count) / 2.0))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            return UIEdgeInsets(top: 20, left: 60, bottom: 20, right: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.size.width/4, height: UIScreen.main.bounds.size.height/6)
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sectionCount()
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (sectionCount()-1) != section {
            return COL_COUNT
        }
        
        let remainder = levelNames.count % COL_COUNT
        if  remainder == 0 {
            return COL_COUNT
        } else {
            return remainder
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? LevelSelectCell else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        }
        
        //cell.layer.cornerRadius = cell.layer.frame.width / 6
        //cell.layer.borderWidth = CGFloat(4.0)
        //cell.layer.borderColor = UIColor.brown.cgColor
        cell.layer.masksToBounds = true
        
        cell.scaleImage()
        
        let index = indexPath.section * COL_COUNT + indexPath.row
        
        if index < levelNames.count {
            cell.label.text = levelNames[index]
        }
        
        return cell
    }
    
    func tapGesture(gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            let position = gesture.location(in: collectionView)
            guard let indexPath = collectionView?.indexPathForItem(at: position) else { return }
            guard let cell = collectionView?.cellForItem(at: indexPath) as? LevelSelectCell else { return }
            guard let levelName = cell.label.text else { return }
            
            self.levelName = levelName
            performSegue(withIdentifier: SEQ_TO_GAMEPLAY, sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SEQ_TO_GAMEPLAY  {
            guard let gameController = segue.destination as? GameplayController else {
                return
            }
            gameController.playWithLevelName(levelName)
        }
    }


    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
