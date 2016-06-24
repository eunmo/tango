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
    let refHour = 5
    let dateFormatter: NSDateFormatter = NSDateFormatter()
    
    // MARK: Archiving Paths
    
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("words")
    
    // MARK: Notification Key
    
    static let notificationKey = "wordLibraryNotificationKey"
    static let networkNotificationKey = "wordLibraryNetworkNotificationKey"
    static let serverAddress = "http://211.200.135.97:3010"
    
    init() {
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
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
        let doneCount = getDoneCount()
        let remainCount = getReviewRemainCount()
        let negativeSum = getReviewNegativeSum()
        
        if negativeSum > 0 {
            return "\(remainCount)+\(negativeSum)/\(learnedCount - doneCount)+\(doneCount) words"
        } else {
            return "\(remainCount)/\(learnedCount - doneCount)+\(doneCount) words"
        }
    }
    
    func getLearnedCount() -> Int {
        var count = 0
        
        for level in levels {
            count += level.getLearnedCount()
        }
        
        return count
    }
    
    func getDoneCount() -> Int {
        var count = 0
        
        for level in levels {
            for word in level.words {
                if (word.streak > 10) {
                    count += 1
                }
            }
        }
        
        return count
    }
    
    func getWordsForReview() -> [Word] {
        var words = [Word]()
        var wordsForReview = [Word]()
        let curDate = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let dateComponents = calendar.components([NSCalendarUnit.Day, NSCalendarUnit.Month, NSCalendarUnit.Year, NSCalendarUnit.Hour], fromDate: curDate)
        
        if (dateComponents.hour < refHour) {
            dateComponents.hour = refHour
        }
        else {
            dateComponents.hour = refHour
            dateComponents.day += 1
        }
        let refDate = calendar.dateFromComponents(dateComponents)!
        
        for level in levels {
            words.appendContentsOf(level.getWordsToReview())
        }
        
        for word in words {
            var add = true
            
            if let interval = word.lastCorrect?.timeIntervalSinceDate(refDate) {
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
    
    func toJSON() -> String {
        var json = "["
        var first = true
        
        for level in levels {
            for word in level.words {
                
                if (first) {
                    json += "\n{"
                    first = false
                } else {
                    json += "},\n{"
                }
                
                json += "\"Level\":\"\(level.name)\",\"index\":\(word.index),\"streak\":\(word.streak),\"learned\":\(word.learned)"
                
                if let lastCorrect = word.lastCorrect {
                    json += ",\"lastCorrect\":\"\(dateFormatter.stringFromDate(lastCorrect))\""
                }
            }
        }
        
        json += "}]"
        
        return json
    }
    
    func getWord(levelName: String, index: Int) -> Word? {
        for level in levels {
            if (level.name == levelName) {
                return level.getWord(index)
            }
        }
        
        return nil
    }
    
    func sync() {
        let urlAsString = WordLibrary.serverAddress + "/sync"
        let url = NSURL(string: urlAsString)!
        let urlSession = NSURLSession.sharedSession()
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "PUT"
        request.HTTPBody = toJSON().dataUsingEncoding(NSUTF8StringEncoding)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = urlSession.dataTaskWithRequest(request, completionHandler: { data, response, error -> Void in
            if error != nil {
                print ("\(error)")
            } else {
                print ("put successful")
                
                let jsonData = JSON(data: data!)
                
                for (_, json) in jsonData {
                    let level = json["Level"].stringValue
                    let index = json["index"].intValue
                    let word = json["word"].stringValue
                    let yomigana = json["yomigana"].stringValue
                    let meaning = json["meaning"].stringValue
                    
                    let newWord = Word(index: index, word: word, yomigana: yomigana, meaning: meaning)!
                    
                    if let foundWord = self.getWord(level, index: index) {
                        foundWord.update(newWord)
                    } else {
                        print (newWord.index)
                        if let lv = self.getLevelByName(level) {
                            lv.addWord(newWord)
                        } else if let newLevel = Level(name: level) {
                            newLevel.addWord(newWord)
                            self.levels.insert(newLevel, atIndex: 0)
                        }
                    }
                }
                
                self.save()
                self.notifyNetworkDone()
            }
        })
        task.resume()
    }
    
    func notifyNetworkDone() {
        NSNotificationCenter.defaultCenter().postNotificationName(WordLibrary.networkNotificationKey, object: self)
    }
}