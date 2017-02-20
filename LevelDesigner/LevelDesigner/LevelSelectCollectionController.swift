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
    
    //var levelNames = ["a", "b", "c"]
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector((tapGesture))))
        levelNames = storageManager.getLevelNames()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func sectionCount() -> Int {
        return Int(ceil(Double(levelNames.count) / 2.0))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            return UIEdgeInsets(top: 80, left: 80, bottom: 40, right: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.size.width/3, height: UIScreen.main.bounds.size.height/3)
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sectionCount()
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (sectionCount()-1) == section && levelNames.count % 2 != 0 {
            return 1
        } else {
            return 2
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? LevelSelectCell else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        }

        let index = indexPath.section * 2 + indexPath.row
        
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
