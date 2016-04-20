//
//  WordLibrary.swift
//  Tango
//
//  Created by Eunmo Yang on 1/3/16.
//  Copyright © 2016 Eunmo Yang. All rights reserved.
//

import Foundation

class WordLibrary {
    
    // MARK: Properties
    var levels = [Level]()
    var testLimit = 30
    
    // MARK: Archiving Paths
    
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("words")
    
    // MARK: Notification Key
    
    static let notificationKey = "songLibraryNotificationKey"
    
    init() {
        load()
        save()
    }
    
    func save() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(levels, toFile: WordLibrary.ArchiveURL.path!)
        print ("save")
        if !isSuccessfulSave {
            print("Failed to save songs...")
        }
    }
    
    func load() {
        let savedLevels = NSKeyedUnarchiver.unarchiveObjectWithFile(WordLibrary.ArchiveURL.path!) as? [Level]
        
        if savedLevels != nil {
            levels = savedLevels!
        }
        
        if let path = NSBundle.mainBundle().pathForResource("data", ofType: "json"), data = NSData(contentsOfFile: path) {
            loadData(data)
        } else if let path = NSBundle.mainBundle().pathForResource("dummyData", ofType: "json"), data = NSData(contentsOfFile: path) {
            loadData(data)
        }
    }
    
    func loadData(data: NSData) {
        var newLevels = [Level]()
        
        if let jsonData = try! NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? NSArray {
            for levelJson in jsonData as! [NSDictionary] {
                if let newlevel = Level(json: levelJson) {
                    if let oldLevel = getLevelByName(newlevel.name) {
                        oldLevel.update(newlevel.words)
                        newLevels.append(oldLevel)
                    } else {
                        newLevels.append(newlevel)
                    }
                }
            }
        }
        
        levels = newLevels
    }
    
    func getLevelByName(name: String) -> Level? {
        for level in levels {
            if level.name == name {
                return level
            }
        }
        
        return nil
    }
    
    func getLevelCount() -> Int {
        return levels.count
    }
    
    func getLevelFromIndexPath(indexPath: NSIndexPath) -> Level? {
        let row = indexPath.row
        
        if row < levels.count {
            return levels[row]
        } else {
            return nil
        }
    }
    
    func getLevelName(indexPath: NSIndexPath) -> String {
        return getLevelFromIndexPath(indexPath)?.name ?? ""
    }
    
    func getLevelSize(indexPath: NSIndexPath) -> Int {
        return getLevelFromIndexPath(indexPath)?.words.count ?? 0
    }
    
    func getLevelRemainCount(indexPath: NSIndexPath) -> Int {
        if let level = getLevelFromIndexPath(indexPath) {
            return level.words.count - level.getLearnedCount()
        } else {
            return 0
        }
    }
    
    func getLevelDetail(indexPath: NSIndexPath) -> String {
        if let level = getLevelFromIndexPath(indexPath) {
            let count = level.words.count
            let learnedCount = level.getLearnedCount()
            
            return "\(learnedCount)/\(count) words"
        } else {
            return ""
        }
    }
    
    func getReviewRemainCount() -> Int {
        return getWordsForReview().count
    }
    
    func getReviewNegativeSum() -> Int {
        let words = getWordsForReview()
        var sum = 0
        
        for word in words {
            if word.streak < 0 {
                sum -= word.streak
            }
        }
        
        return sum
    }
    
    func getReviewDetail() -> String {
        let learnedCount = getLearnedCount()
        let remainCount = getReviewRemainCount()
        let negativeSum = getReviewNegativeSum()
        
        if negativeSum > 0 {
            return "\(remainCount)+\(negativeSum)/\(learnedCount) words"
        } else {
            return "\(remainCount)/\(learnedCount) words"
        }
    }
    
    func getLearnedCount() -> Int {
        var count = 0
        
        for level in levels {
            count += level.getLearnedCount()
        }
        
        return count
    }
    
    func getWordsForReview() -> [Word] {
        var words = [Word]()
        var wordsForReview = [Word]()
        let curDate = NSDate()
        
        assert(getLearnedCount() > 0)
        
        for level in levels {
            words.appendContentsOf(level.getWordsToReview())
        }
        
        for word in words {
            var add = true
            
            if let interval = word.lastCorrect?.timeIntervalSinceDate(curDate) {
                let timeLimit = Double(word.streak) * -86400
                if (timeLimit < interval || word.streak > 10) {
                    add = false
                }
            }
            
            if add {
                wordsForReview.append(word)
            }
        }
        
        return wordsForReview
    }
    
    func getAllLearnedWords() -> [Word] {
        var words = [Word]()
        
        for level in levels {
            words.appendContentsOf(level.getWordsToReview())
        }
        
        return words
    }
    
    func getWords(indexPath: NSIndexPath) -> [Word] {
        var words = [Word]()
        let section = indexPath.section
        
        if section == 0 {
            if let level = getLevelFromIndexPath(indexPath) {
                words = level.getWordsToLearn()
            }
        } else {
            words = getWordsForReview()
        }
        
        words.shuffleInPlace()
        
        let count = words.count
        
        if count > testLimit {
            words.removeRange(testLimit..<count)
        }
        
        return words
    }
    
    func record(words: [Word]) {
        for word in words {
            word.learned = true
        }
        
        save()
        notify()
    }
    
    func notify() {
        NSNotificationCenter.defaultCenter().postNotificationName(WordLibrary.notificationKey, object: self)
    }
}