//
//  InitViewController.swift
//  Tango
//
//  Created by Eunmo Yang on 6/14/18.
//  Copyright © 2018 Eunmo Yang. All rights reserved.
//

import UIKit

class InitViewController: UIViewController {
    
    @IBOutlet weak var engButton: UIButton!
    @IBOutlet weak var fraButton: UIButton!
    @IBOutlet weak var japButton: UIButton!
    @IBOutlet weak var engNewButton: UIButton!
    @IBOutlet weak var fraNewButton: UIButton!
    @IBOutlet weak var japNewButton: UIButton!
    @IBOutlet weak var engReviewButton: UIButton!
    @IBOutlet weak var fraReviewButton: UIButton!
    @IBOutlet weak var japReviewButton: UIButton!
    
    @IBOutlet weak var syncButton: UIButton!
    @IBOutlet weak var statButton: UIButton!
    @IBOutlet weak var goButton: UIButton!
    
    var selectedLevel: NSIndexPath? {
        didSet {
            updateUI()
        }
    }
    
    var wordLibrary: WordLibrary?
    var rowCount = 3
    var sectionCount = 2

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        wordLibrary = appDelegate.wordLibrary
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.receiveNotification), name: NSNotification.Name(rawValue: WordLibrary.notificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.receiveNetNotification), name: NSNotification.Name(rawValue: WordLibrary.networkNotificationKey), object: nil)
        
        CommonUI.setViewMask(view: syncButton, isHollow: true)
        CommonUI.setViewMask(view: statButton, isHollow: true)
        CommonUI.setViewMask(view: goButton, isHollow: true)
        
        CommonUI.setViewMask(view: engButton, isHollow: false)
        CommonUI.setViewMask(view: fraButton, isHollow: false)
        CommonUI.setViewMask(view: japButton, isHollow: false)
        CommonUI.setViewMask(view: engNewButton, isHollow: false)
        CommonUI.setViewMask(view: fraNewButton, isHollow: false)
        CommonUI.setViewMask(view: japNewButton, isHollow: false)
        CommonUI.setViewMask(view: engReviewButton, isHollow: false)
        CommonUI.setViewMask(view: fraReviewButton, isHollow: false)
        CommonUI.setViewMask(view: japReviewButton, isHollow: false)
        
        updateUI()
    }
    
    func updateSelectedLevel(rowDiff: Int, sectionDiff: Int) {
        if let cur = selectedLevel {
            let row = (cur.row + rowDiff + rowCount) % rowCount
            let section = (cur.section + sectionDiff + sectionCount) % sectionCount
            selectedLevel = NSIndexPath(row: row, section: section)
        } else {
            selectedLevel = NSIndexPath(row: 0, section: 0)
        }
    }
    
    @objc func upKey() {
        updateSelectedLevel(rowDiff: -1, sectionDiff: 0)
    }
    
    @objc func leftKey() {
        updateSelectedLevel(rowDiff: 0, sectionDiff: -1)
    }
    
    @objc func rightKey() {
        updateSelectedLevel(rowDiff: 0, sectionDiff: 1)
    }
    
    @objc func downKey() {
        updateSelectedLevel(rowDiff: 1, sectionDiff: 0)
    }
    
    @objc func enterKey() {
        go()
    }
    
    override var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand(input: "2", modifierFlags: .numericPad, action: #selector(downKey), discoverabilityTitle: "Down(2)"),
            UIKeyCommand(input: "4", modifierFlags: .numericPad, action: #selector(leftKey), discoverabilityTitle: "Left(4)"),
            UIKeyCommand(input: "5", modifierFlags: .numericPad, action: #selector(enterKey), discoverabilityTitle: "Enter(5)"),
            UIKeyCommand(input: "6", modifierFlags: .numericPad, action: #selector(rightKey), discoverabilityTitle: "Right(6)"),
            UIKeyCommand(input: "8", modifierFlags: .numericPad, action: #selector(upKey), discoverabilityTitle: "Up(8)")
        ]
    }
    
    @objc func receiveNotification() {
        DispatchQueue.main.async(execute: { () -> Void in
            self.updateUI()
        })
    }
    
    @objc func receiveNetNotification() {
        DispatchQueue.main.async(execute: { () -> Void in
            
            self.syncButton.backgroundColor = CommonUI.yellow
            self.syncButton.isEnabled = true
            self.updateUI()
        })
    }
    
    func updateUI() {
        if let library = wordLibrary {
            let newButtons = [engNewButton, fraNewButton, japNewButton]
            
            for (index, button) in newButtons.enumerated() {
                let path = NSIndexPath(row: index, section: 0)
                let text = "\(library.getLearnRemainCount(indexPath: path)) new"
                button?.setTitle(text, for: .normal)
                button?.backgroundColor = (path == selectedLevel) ? UIColor.systemBlue : UIColor.systemGray
            }
            
            let reviewButtons = [engReviewButton, fraReviewButton, japReviewButton]
            
            for (index, button) in reviewButtons.enumerated() {
                let path = NSIndexPath(row: index, section: 1)
                let text = "\(library.getReviewRemainCount(indexPath: path))"
                button?.setTitle(text, for: .normal)
                button?.backgroundColor = (path == selectedLevel) ? UIColor.systemBlue : UIColor.systemGray
            }
        }
    }
    
    func go() {
        if let path = selectedLevel {
            let words = wordLibrary!.getWords(indexPath: path)
            
            if words.count > 0 {
                performSegue(withIdentifier: "Show Words", sender: self)
            }
        }
    }
    
    @IBAction func engNewButtonPressed(_ sender: UIButton) {
        selectedLevel = NSIndexPath(row: 0, section: 0)
    }
    
    @IBAction func fraNewButtonPressed(_ sender: UIButton) {
        selectedLevel = NSIndexPath(row: 1, section: 0)
    }
    
    @IBAction func japNewButtonPressed(_ sender: UIButton) {
        selectedLevel = NSIndexPath(row: 2, section: 0)
    }
    
    @IBAction func engReviewButtonPressed(_ sender: UIButton) {
        selectedLevel = NSIndexPath(row: 0, section: 1)
    }
    
    @IBAction func fraReviewButtonPressed(_ sender: UIButton) {
        selectedLevel = NSIndexPath(row: 1, section: 1)
    }
    
    @IBAction func japReviewButtonPressed(_ sender: UIButton) {
        selectedLevel = NSIndexPath(row: 2, section: 1)
    }
    
    @IBAction func syncButtonPressed(_ sender: UIButton) {
        syncButton.backgroundColor = CommonUI.red
        syncButton.isEnabled = false
        wordLibrary!.sync()
    }
    
    @IBAction func goButtonPressed(_ sender: UIButton) {
        go()
    }
    
    func getCellText(indexPath: NSIndexPath) -> String {
        if indexPath.section == 0 {
            return wordLibrary!.getLevelName(indexPath: indexPath)
        } else {
            return wordLibrary!.getReviewName(indexPath: indexPath)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let identifier = segue.identifier {
            switch identifier {
            case "Show Words":
                if let vc = segue.destination as? WordViewController {
                    let path = selectedLevel!
                    vc.text = getCellText(indexPath: path)
                    vc.words = wordLibrary!.getWords(indexPath: path)
                    vc.wordLibrary = wordLibrary
                    vc.review = path.section == 1
                }
            case "Show Statistics":
                if let vc = segue.destination as? StatsTableViewController {
                    vc.allWords = wordLibrary!.getAllLearnedWords(indexPath: selectedLevel)
                    vc.wordsToReview = wordLibrary!.getWordsForReview(indexPath: selectedLevel)
                }
            default: break
            }
        }
    }

}
