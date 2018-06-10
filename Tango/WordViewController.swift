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
    var pass = 0
    var prevWrongCount = 0
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
    
    let green = UIColor(red: 86/255, green: 215/255, blue: 43/255, alpha: 1).cgColor
    let red = UIColor(red: 252/255, green: 33/255, blue: 37/255, alpha: 1).cgColor
    let yellow = UIColor(red: 254/255, green: 195/255, blue: 9/255, alpha: 1).cgColor
    
    var curResult: Bool? = nil {
        didSet {
            
            if let result = curResult {
                if result == false {
                    // system red
                    upperView.layer.borderColor = red
                } else {
                    // system green
                    upperView.layer.borderColor = green
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
        
        setViewMask(view: trueButton, isHollow: true)
        setViewMask(view: falseButton, isHollow: true)
        setupProgressView()

        // Do any additional setup after loading the view.
        if words.count > 0 {
            words.shuffle()
            startTime = Date()
            setWord(word: words[0])
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersHomeIndicatorAutoHidden() -> Bool {
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
            layer.fillColor = UIColor.gray.cgColor
            layers.append(layer)
            progressButton.layer.addSublayer(layer)
        }
    }
    
    func setViewMask(view: UIView, isHollow: Bool) {
        let width = view.bounds.width
        let height = view.bounds.height
        let radius: CGFloat = 25
        let diameter = radius * 2
        let borderWidth: CGFloat = 10
        
        let path = UIBezierPath(roundedRect: view.bounds, cornerRadius: radius)
        
        if (isHollow) {
            let innerRect = CGRect(x: borderWidth, y: borderWidth, width: width - 2 * borderWidth, height: height - 2 * borderWidth)
            let innerPath = UIBezierPath(roundedRect: innerRect, cornerRadius: radius - borderWidth)
            path.append(innerPath)
            
            let rect = CGRect(x: width / 2 - radius, y: height / 2 - radius, width: diameter, height: diameter)
            let circlePath  = UIBezierPath(ovalIn: rect)
            path.append(circlePath)
        }
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = view.bounds
        maskLayer.fillRule = kCAFillRuleEvenOdd
        maskLayer.path = path.cgPath
        
        view.layer.mask = maskLayer
    }
    
    func updateUI() {
        for (index, word) in words.enumerated() {
            let layer = layers[index]
            
            if correct.contains(word) {
                layer.fillColor = green
            } else if incorrect.contains(word) {
                layer.fillColor = red
            } else if index == self.index {
                layer.fillColor = yellow
            } else {
                layer.fillColor = UIColor.lightGray.cgColor
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
            let alertController = UIAlertController(title: "\(incorrect.count)/\(words.count) wrong", message: "", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Restart", style: UIAlertActionStyle.default, handler: restart))
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
    
    func finishReview() {
        for word in correct {
            word.correct()
        }
        
        for word in incorrect {
            word.incorrect()
        }
        
        dismiss()
    }
    
    func restart(action: UIAlertAction!) -> Void {
        pass = 1
        prevWrongCount = incorrect.count
        index = 0
        
        correct = [Word]()
        incorrect = [Word]()
        words.shuffle()
        setWord(word: words[index])
    }
    
    func dismiss() {
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

    // MARK: Actions
    
    @IBAction func negativeButtonPressed(_ sender: UIButton) {
        if index == words.count {
        } else if curResult == false {
            incorrect.append(getWord())
            next()
        } else {
            curResult = false
            showDetails = true
        }
    }
    
    @IBAction func positivieButtonPressed(_ sender: UIButton) {
        if index == words.count {
            finishReview()
        } else if curResult == true {
            correct.append(getWord())
            next()
        } else {
            curResult = true
            showDetails = true
        }
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
