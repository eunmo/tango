//
//  WordViewController.swift
//  Tango
//
//  Created by Eunmo Yang on 1/2/16.
//  Copyright © 2016 Eunmo Yang. All rights reserved.
//

import UIKit

class WordViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    // MARK: Properties
    @IBOutlet weak var yomiganaLabel: UILabel!
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var meaningLabel: UILabel!
    @IBOutlet weak var meaningBackground: UIVisualEffectView!
    @IBOutlet weak var progressCollectionView: UICollectionView!
    
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
    
    var showDetails = false {
        didSet {
            yomiganaLabel.isHidden = !showDetails
            meaningLabel.isHidden = !showDetails
            meaningBackground.isHidden = !showDetails
        }
    }
    
    var curResult: Bool? = nil {
        didSet {
            trueButton.backgroundColor = UIColor.gray
            falseButton.backgroundColor = UIColor.gray
            
            if let result = curResult {
                if result == false {
                    falseButton.backgroundColor = UIColor(red: 252/255, green: 33/255, blue: 37/255, alpha: 1)
                } else {
                    trueButton.backgroundColor = UIColor(red: 86/255, green: 215/255, blue: 43/255, alpha: 1)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressCollectionView.delegate = self
        progressCollectionView.dataSource = self

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
    
    func updateUI() {
        title = text
        progressCollectionView.reloadData()
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
        } else if review {
            let title = getTitleString()
            
            let alertController = UIAlertController(title: title, message: "", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Prev", style: UIAlertActionStyle.default, handler: prevHandler))
            alertController.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.default, handler: finishReview))
            alertController.preferredAction = alertController.actions[1] // Done
            present(alertController, animated: true, completion: nil)
        } else if incorrect.count > 0 {
            let alertController = UIAlertController(title: "\(incorrect.count)/\(words.count) wrong", message: "", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Restart", style: UIAlertActionStyle.default, handler: restart))
            present(alertController, animated: true, completion: nil)
        } else {
            let title = getTitleString()
            
            let alertController = UIAlertController(title: title, message: "", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.default, handler: dismiss))
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
    
    func finishReview(action: UIAlertAction!) -> Void {
        for word in correct {
            word.correct()
        }
        
        for word in incorrect {
            word.incorrect()
        }
        
        dismiss(action: action)
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
    
    func dismiss(action: UIAlertAction!) -> Void {
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
        if curResult != nil {
            incorrect.append(getWord())
            next()
        } else {
            curResult = false
            showDetails = !showDetails
        }
    }
    
    @IBAction func positivieButtonPressed(_ sender: UIButton) {
        if curResult != nil {
            correct.append(getWord())
            next()
        } else {
            curResult = true
            showDetails = !showDetails
        }
    }
    
    @IBAction func lowerPrevButtonPressed(_ sender: UIButton) {
        prev()
    }
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return pass + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return words.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProgressCollectionViewCell", for: indexPath as IndexPath)
        
        // Configure the cell
        var shrink = false
        
        if indexPath.section < pass {
            if indexPath.row < prevWrongCount {
                cell.backgroundColor = UIColor.orange
            } else {
                cell.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 1.0, alpha: 1.0)
            }
            
            shrink = true
        } else {
            let word = words[indexPath.row]
            
            if indexPath.row == index {
                cell.backgroundColor = UIColor.darkGray
            } else if incorrect.contains(word) {
                cell.backgroundColor = UIColor.orange
            } else if correct.contains(word) {
                cell.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 1.0, alpha: 1.0)
                
                shrink = true
            } else {
                cell.backgroundColor = UIColor.lightGray
                
                shrink = true
            }
        }
        
        if shrink {
            cell.layer.bounds = CGRect(x: 1.0, y: 1.0, width: 4.5, height: 4.5)
            cell.layer.cornerRadius = 2.25
        } else {
            cell.layer.bounds = CGRect(x: 0, y: 0, width: 6, height: 6)
            cell.layer.cornerRadius = 3
        }
        
        return cell
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
