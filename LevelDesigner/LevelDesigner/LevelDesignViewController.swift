//
//  LevelDesignViewController.swift
//  LevelDesigner
//
//  Created by limte on 1/2/17.
//  Copyright © 2017 nus.cs3217.a0101010. All rights reserved.
//

import UIKit

class LevelDesignViewController: UIViewController {
    private let BUTTON_FADE_ALPHA = 0.3
    private let BUTTON_ACTIVE_ALPHA = 1.0
    private let BUTTON_TITLE_CANCEL = "Cancel"
    private let BUTTON_TITLE_SAVE = "Save"
    private let ALERT_TITLE_SAVE_AS = "Save As"
    private let SEQ_GRID = "embed"
    private let SEQ_TO_GAMEPLAY = "levelDesignerToGame"
    
    @IBOutlet weak private var blueButton: UIButton!
    @IBOutlet weak private var greenButton: UIButton!
    @IBOutlet weak private var orangeButton: UIButton!
    @IBOutlet weak private var redButton: UIButton!
    @IBOutlet weak private var eraseButton: UIButton!
    @IBOutlet weak private var blackButton: UIButton!
    @IBOutlet weak private var bombButton: UIButton!
    @IBOutlet weak private var lightingButton: UIButton!
    @IBOutlet weak private var starButton: UIButton!
    
    @IBOutlet weak var testImage: UIImageView!
    private var buttonList: [UIButton] = []
    private var currentButton: UIButton? = nil
    private var embedController : DesignerGridCollectionController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonList.append(blueButton)
        buttonList.append(greenButton)
        buttonList.append(orangeButton)
        buttonList.append(redButton)
        buttonList.append(eraseButton)
        buttonList.append(blackButton)
        buttonList.append(bombButton)
        buttonList.append(lightingButton)
        buttonList.append(starButton)
        
        fadeAllButton()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true);
        navigationController?.navigationBar.isHidden = true // for navigation bar hide
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction private func blueButtonPressed(_ sender: Any) {
        selectBubble(GridBubble.BubbleColor.blue)
        colorButtonPressed(sender)
    }

    @IBAction private func greenButtonPressed(_ sender: Any) {
        selectBubble(GridBubble.BubbleColor.green)
        colorButtonPressed(sender)
    }
    
    @IBAction private func orangeButtonPressed(_ sender: Any) {
        selectBubble(GridBubble.BubbleColor.purple)
        colorButtonPressed(sender)
    }
    
    @IBAction private func redButtonPressed(_ sender: Any) {
        selectBubble(GridBubble.BubbleColor.red)
        colorButtonPressed(sender)
    }
    
    @IBAction private func eraseButtonPressed(_ sender: Any) {
        embedController?.setEraseMode()
        colorButtonPressed(sender)
    }
    
    @IBAction func blackButtonPressed(_ sender: Any) {
        selectBubble(GridBubble.BubbleColor.black)
        colorButtonPressed(sender)
    }
    
    @IBAction func bombButtonPressed(_ sender: Any) {
        selectBubble(GridBubble.BubbleColor.bomb)
        colorButtonPressed(sender)
    }

    @IBAction func lightingButtonPressed(_ sender: Any) {
        selectBubble(GridBubble.BubbleColor.lightning)
        colorButtonPressed(sender)
    }
    
    @IBAction func starButtonPressed(_ sender: Any) {
        selectBubble(GridBubble.BubbleColor.star)
        colorButtonPressed(sender)
    }
    
    private func colorButtonPressed(_ sender: Any) {
        guard let button = sender as? UIButton else {
            return
        }
        
        // if button is pressed again when selected, set the button to unactive
        if currentButton == button {
            currentButton = nil
            fadeAllButton()
            embedController?.setIdleMode()
            return
        }
        
        currentButton = button
        fadeAllButton()
        button.alpha = CGFloat(BUTTON_ACTIVE_ALPHA)
    }
    
    private func fadeAllButton() {
        for button in buttonList {
            button.alpha = CGFloat(BUTTON_FADE_ALPHA)
        }
    }
    
    @IBAction func startButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: SEQ_TO_GAMEPLAY, sender: self)
    }
    
    @IBAction private func resetButtonPressed(_ sender: Any) {
        embedController?.resetGrid()
    }

    @IBAction private func loadLevelPressed(_ sender: Any) {
        embedController?.load()
    }

    @IBAction private func saveLevelPressed(_ sender: Any) {
        let window: UIWindow! = UIApplication.shared.keyWindow
        let windowImage = window.capture()
        testImage.image = windowImage
        createSaveAlert(title: ALERT_TITLE_SAVE_AS)
    }

    private func selectBubble(_ bubbleColor: GridBubble.BubbleColor) {
        embedController?.selectBubble(bubbleColor: bubbleColor)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SEQ_GRID {
            embedController = segue.destination as? DesignerGridCollectionController
        } else if segue.identifier == SEQ_TO_GAMEPLAY  {
            guard let gameController = segue.destination as? GameplayController else {
                return
            }
            guard let embedController = embedController else {
                return
            }
            gameController.playWithBubbles(embedController.getGridBubbles())
        }
    }
    
    // create an alert message to save with text in textfield
    private func createSaveAlert(title: String) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField(configurationHandler: {(textField) in})
        alert.addAction(UIAlertAction(title: BUTTON_TITLE_CANCEL, style: UIAlertActionStyle.cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: BUTTON_TITLE_SAVE, style: UIAlertActionStyle.default, handler: {(action) in
            alert.dismiss(animated: true, completion: nil)

            guard  let text = alert.textFields?[0].text else {
                return
            }
            
            self.embedController?.save(levelName: text)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}

public extension UIWindow {
    func capture() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: self.frame.width, height: self.frame.height/4 * 3), self.isOpaque, UIScreen.main.scale)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
