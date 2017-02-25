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
    
    var levels: [Level] = []
    private let SEQGUE_TO_GAMEPLAY = "levelSelectToGame"
    private var levelName: String = ""
    private let COL_COUNT = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector((tapGesture))))
        levels = storageManager.getLevels()
        self.collectionView?.backgroundColor = UIColor.clear
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func sectionCount() -> Int {
        return Int(ceil(Double(levels.count) / Double(COL_COUNT)))
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
        
        let remainder = levels.count % COL_COUNT
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
        cell.layer.masksToBounds = true
        
        let index = indexPath.section * COL_COUNT + indexPath.row
        if index < levels.count {
            cell.label.text = levels[index].levelName
            cell.initCell(stars: levels[index].getStars())
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
            performSegue(withIdentifier: SEQGUE_TO_GAMEPLAY, sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SEQGUE_TO_GAMEPLAY  {
            guard let gameController = segue.destination as? GameplayController else {
                return
            }
            gameController.playWithLevelName(levelName)
        }
    }
}
