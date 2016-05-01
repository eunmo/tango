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
    
    @IBOutlet weak var progressCollectionView: UICollectionView!
    
    var review = false
    var showDetails = false
    var words = [Word]()
    var correct = [Word]()
    var incorrect = [Word]()
    var index = 0
    var pass = 0
    var prevWrongCount = 0
    var text = ""
    var wordLibrary: WordLibrary?
    var startTime: NSDate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressCollectionView.delegate = self
        progressCollectionView.dataSource = self

        // Do any additional setup after loading the view.
        if words.count > 0 {
            words.shuffleInPlace()
            startTime = NSDate()
            if review {
                for word in words {
                    if word.lastCorrect != nil {
                        print("\(word.word)\t\(word.streak)\t\(word.lastCorrect!)\t\(word.lastCorrect!.timeIntervalSinceDate(startTime!))")
                    }
                }
            }
            setWord(words[0])
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
    
    func setWord(word: Word) {
        showDetails = false;
        
        yomiganaLabel.hidden = true;
        meaningLabel.hidden = true;
        
        wordLabel.text = word.word
        yomiganaLabel.text = word.yomigana
        meaningLabel.text = word.meaning
        
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
            
            setWord(word)
        }
    }
    
    func next() {
        if let word = nextWord() {
            setWord(word)
        } else if review {
            for word in correct {
                word.correct()
            }
            
            for word in incorrect {
                word.incorrect()
            }
            
            finish()
        } else if incorrect.count > 0 {
            let alertController = UIAlertController(title: "\(incorrect.count) wrong", message: "", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Restart", style: UIAlertActionStyle.Default, handler: restart))
            presentViewController(alertController, animated: true, completion: nil)
        } else {
            finish()
        }
    }
    
    func finish() {
        let duration = Int(-startTime!.timeIntervalSinceNow)
        let title = String(format: "%d correct in %02d:%02d", arguments: [correct.count, duration / 60, duration % 60])
        let message = getStreakString()
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.Default, handler: dismiss))
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func restart(action: UIAlertAction!) -> Void {
        pass = 1
        prevWrongCount = incorrect.count
        index = 0
        
        correct = [Word]()
        incorrect = [Word]()
        words.shuffleInPlace()
        setWord(words[index])
    }
    
    func dismiss(action: UIAlertAction!) -> Void {
        wordLibrary!.record(words)
        navigationController!.popViewControllerAnimated(true)
    }
    
    func getStreakString() -> String {
        
        if !review {
            return ""
        }
        
        var maxStreak = 0
        var minStreak = 0
        
        for word in words {
            if maxStreak < word.streak {
                maxStreak = word.streak
            }
            
            if minStreak > word.streak {
                minStreak = word.streak
            }
        }
        
        var streaks = [Int](count: maxStreak - minStreak + 1, repeatedValue: 0)
        
        for word in words {
            streaks[maxStreak - word.streak] += 1
        }
        
        var string = "Streaks"
        
        for (index, streak) in streaks.enumerate() {
            if streak != 0 {
                string += String(format: "\n%02d:\t%02d", arguments: [maxStreak - index, streak])
            }
        }
        
        return string
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
    
    @IBAction func viewTapped(sender: UITapGestureRecognizer) {
        if !showDetails {
            showDetails = true;
            
            yomiganaLabel.hidden = false;
            meaningLabel.hidden = false;
        } else {
            showDetails = false;
            
            yomiganaLabel.hidden = true;
            meaningLabel.hidden = true;
        }
    }
    
    @IBAction func negativeButtonPressed(sender: UIButton) {
        incorrect.append(getWord())
        next()
    }
    
    @IBAction func positivieButtonPressed(sender: UIButton) {
        correct.append(getWord())
        next()
    }
    
    @IBAction func prevButtonPressed(sender: UIBarButtonItem) {
        prev()
    }
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return pass + 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return words.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ProgressCollectionViewCell", forIndexPath: indexPath)
        
        // Configure the cell
        var shrink = false
        
        if indexPath.section < pass {
            if indexPath.row < prevWrongCount {
                cell.backgroundColor = UIColor.orangeColor()
            } else {
                cell.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 1.0, alpha: 1.0)
            }
            
            shrink = true
        } else {
            let word = words[indexPath.row]
            
            if indexPath.row == index {
                cell.backgroundColor = UIColor.darkGrayColor()
            } else if incorrect.contains(word) {
                cell.backgroundColor = UIColor.orangeColor()
            } else if correct.contains(word) {
                cell.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 1.0, alpha: 1.0)
                
                shrink = true
            } else {
                cell.backgroundColor = UIColor.lightGrayColor()
                
                shrink = true
            }
        }
        
        if shrink {
            cell.layer.bounds = CGRect(x: 1.0, y: 1.0, width: 4.5, height: 4.5)
            cell.layer.cornerRadius = 2.25
        } else {
            cell.layer.bounds = CGRect(x: 0, y: 0, width: 6.5, height: 6.5)
            cell.layer.cornerRadius = 3.25
        }
        
        return cell
    }
}

extension MutableCollectionType where Index == Int {
    /// Shuffle the elements of `self` in-place.
    mutating func shuffleInPlace() {
        // empty and single-element collections don't shuffle
        if count < 2 { return }
        
        for i in 0..<count - 1 {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            guard i != j else { continue }
            swap(&self[i], &self[j])
        }
    }
}
