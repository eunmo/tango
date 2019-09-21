//
//  WordViewController.swift
//  Tango
//
//  Created by Eunmo Yang on 1/2/16.
//  Copyright © 2016 Eunmo Yang. All rights reserved.
//

import UIKit

class WordViewController: UIViewController {

    // MARK: Properties
    @IBOutlet weak var yomiganaLabel: UILabel!
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var meaningLabel: UILabel!
    @IBOutlet weak var progressButton: UIButton!
    @IBOutlet weak var upperView: UIView!
    
    @IBOutlet weak var trueButton: UIButton!
    @IBOutlet weak var falseButton: UIButton!
    
    var review = false
    var words = [Word]()
    var correct = [Word]()
    var incorrect = [Word]()
    var index = 0
    var text = ""
    var wordLibrary: WordLibrary?
    var startTime: Date?
    
    var layers = [CAShapeLayer]()
    
    var showDetails = false {
        didSet {
            yomiganaLabel.isHidden = !showDetails
            meaningLabel.isHidden = !showDetails
        }
    }
    
    let red = CommonUI.red.cgColor
    let yellow = CommonUI.yellow.cgColor
    let orange = CommonUI.orange.cgColor
    let blue = CommonUI.blue.cgColor
    let green = CommonUI.green.cgColor
    
    var curResult: Bool? = nil {
        didSet {
            
            if let result = curResult {
                if result == false {
                    // system red
                    upperView.layer.borderColor = orange
                } else {
                    // system green
                    upperView.layer.borderColor = blue
                }
            } else {
                upperView.layer.borderColor = UIColor.clear.cgColor
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = text
        
        upperView.layer.borderWidth = 10
        upperView.layer.cornerRadius = 25
        
        CommonUI.setViewMask(view: trueButton, isHollow: true)
        CommonUI.setViewMask(view: falseButton, isHollow: true)
        setupProgressView()
        

        // Do any additional setup after loading the view.
        if words.count > 0 {
            words.shuffle()
            startTime = Date()
            setWord(word: words[0])
        }
    }
    
    @objc func upKey() {
        prev()
    }
    
    @objc func leftKey() {
        handleFalse()
    }
    
    @objc func rightKey() {
        handleTrue()
    }
    
    override var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand(input: "4", modifierFlags: .numericPad, action: #selector(leftKey), discoverabilityTitle: "Left(4)"),
            UIKeyCommand(input: "6", modifierFlags: .numericPad, action: #selector(rightKey), discoverabilityTitle: "Right(6)"),
            UIKeyCommand(input: "8", modifierFlags: .numericPad, action: #selector(upKey), discoverabilityTitle: "Up(8)")
        ]
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    func setupProgressView() {
        let diameter: CGFloat = 30
        let space: CGFloat = 15
        let offset = progressButton.bounds.width - (CGFloat(words.count) * diameter) - ((CGFloat(words.count) - 1) * space)
        
        for i in 0..<words.count {
            let layer = CAShapeLayer()
            let x = CGFloat(i) * (diameter + space) + offset / 2
            let rect = CGRect(x: x, y: 10, width: diameter, height: diameter)
            layer.path = UIBezierPath(ovalIn: rect).cgPath
            layer.fillColor = UIColor.systemGray.cgColor
            layers.append(layer)
            progressButton.layer.addSublayer(layer)
        }
    }
    
    func updateUI() {
        for (index, word) in words.enumerated() {
            let layer = layers[index]
            
            if correct.contains(word) {
                layer.fillColor = blue
            } else if incorrect.contains(word) {
                layer.fillColor = orange
            } else if index == self.index {
                layer.fillColor = UIColor.label.cgColor
            } else {
                layer.fillColor = UIColor.systemGray.cgColor
            }
        }
    }
    
    func getWord() -> Word {
        return words[index]
    }
    
    func formatMeaningString(meaning: String) -> String {
        var string = meaning
        
        for i in 2...5 {
            string = string.replacingOccurrences(of: " \(i))", with: "\n\(i))")
        }
        
        return string;
    }
    
    func setWord(word: Word) {
        showDetails = false
        curResult = nil
        
        wordLabel.text = word.word
        yomiganaLabel.text = "\(word.yomigana)  "
        meaningLabel.text = formatMeaningString(meaning: word.meaning)
        
        updateUI()
    }
    
    func nextWord() -> Word? {
        if index + 1 < words.count {
            index += 1
            return words[index]
        } else {
            assert(correct.count + incorrect.count == words.count)
        }
        
        return nil
    }
    
    func prev() {
        if index > 0 {
            index -= 1
            let word = words[index]
            
            if correct.contains(word) {
                correct.removeLast()
            } else if incorrect.contains(word) {
                incorrect.removeLast()
            }
            
            setWord(word: word)
        }
    }
    
    func next() {
        if let word = nextWord() {
            setWord(word: word)
        } else if review || incorrect.count == 0 {
            index += 1
            let title = getTitleString()
            let endWord = Word(index: 0, word: title, yomigana: "", meaning: "")!
            setWord(word: endWord)
        } else {
            let alertController = UIAlertController(title: "\(incorrect.count)/\(words.count) wrong", message: "", preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "Restart", style: UIAlertAction.Style.default, handler: restart))
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func prevHandler(action: UIAlertAction!) -> Void {
        let word = words[index]
        
        if correct.contains(word) {
            correct.removeLast()
        } else if incorrect.contains(word) {
            incorrect.removeLast()
        }
        
        setWord(word: word)
    }
    
    func restart(action: UIAlertAction!) -> Void {
        correct = [Word]()
        incorrect = [Word]()
        words.shuffle()
        index = 0
        setWord(word: words[index])
    }
    
    func dismiss() {
        if review {
            for word in correct {
                word.correct()
            }
            
            for word in incorrect {
                word.incorrect()
            }
        }
        
        wordLibrary!.record(words: words)
        navigationController!.popViewController(animated: true)
    }
    
    func getTitleString() -> String {
        let duration = Int(-startTime!.timeIntervalSinceNow)
        return String(format: "%d/%d correct in %02d:%02d", arguments: [correct.count, words.count, duration / 60, duration % 60])
    }

    // MARK: - Navigation

    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func handleTrue() {
        if index == words.count {
            dismiss()
        } else if curResult == true {
            correct.append(getWord())
            next()
        } else {
            curResult = true
            showDetails = true
        }
    }
    
    func handleFalse() {
        if index == words.count {
        } else if curResult == false {
            incorrect.append(getWord())
            next()
        } else {
            curResult = false
            showDetails = true
        }
    }

    // MARK: Actions
    
    
    @IBAction func negativeButtonPressed(_ sender: UIButton) {
        handleFalse()
    }
    
    @IBAction func positivieButtonPressed(_ sender: UIButton) {
        handleTrue()
    }
    
    @IBAction func prevButtonPressed(_ sender: UIButton) {
        prev()
    }
}

extension MutableCollection where Indices.Iterator.Element == Index {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (unshuffledCount, firstUnshuffled) in zip(stride(from: c, to: 1, by: -1), indices) {
            let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            guard d != 0 else { continue }
            let i = index(firstUnshuffled, offsetBy: d)
            self.swapAt(firstUnshuffled, i)
        }
    }
}
