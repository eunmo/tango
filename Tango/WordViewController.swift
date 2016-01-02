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
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    
    var showDetails = false
    var words = [Word]()
    var correct = [Word]()
    var incorrect = [Word]()
    var index = 0
    var pass = 0
    var prevWrongCount = 0
    var text = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if words.count > 0 {
            words.shuffleInPlace()
            setWord(words[0])
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateUI() {
        title = text
        statusLabel.text = "Pass \(pass + 1)" + (pass > 0 ? " - \(prevWrongCount)/\(words.count) wrongs" : "")
        progressLabel.text = "\(index + 1)/\(words.count)"
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
        meaningLabel.text = word.meaing
        
        updateUI()
    }
    
    func nextWord() -> Word? {
        if index + 1 < words.count {
            index++
            return words[index]
        } else {
            assert(correct.count + incorrect.count == words.count)
        }
        
        return nil
    }
    
    func next() {
        if let word = nextWord() {
            setWord(word)
        } else if incorrect.count > 0 {
            let alertController = UIAlertController(title: "Done", message: "\(incorrect.count) wrongs", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Restart", style: UIAlertActionStyle.Default, handler: restart))
            presentViewController(alertController, animated: true, completion: nil)
        } else {
            let alertController = UIAlertController(title: "Done", message: "Number of passes: \(pass + 1)", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: dismiss))
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func restart(action: UIAlertAction!) -> Void {
        pass++
        prevWrongCount = incorrect.count
        index = 0
        correct = [Word]()
        incorrect = [Word]()
        words.shuffleInPlace()
        setWord(words[index])
    }
    
    func dismiss(action: UIAlertAction!) -> Void {
        navigationController!.popViewControllerAnimated(true)
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
