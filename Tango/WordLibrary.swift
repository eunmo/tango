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
    var levelsToLearn = [Level]()
    var testLimit = 30
    let refHour = 5
    let dateFormatter: DateFormatter = DateFormatter()
    
    // MARK: Archiving Paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("words")
    
    // MARK: Notification Key
    
    static let notificationKey = "wordLibraryNotificationKey"
    static let networkNotificationKey = "wordLibraryNetworkNotificationKey"
    
    static let serverAddress = "http://1.235.106.140:3010"
    static let languageCount = 3
    static let reviewNames = ["Review", "Revoir", "復習"]
    static let levelToLanguage: [Character: Int] = ["E": 0, "F": 1, "J": 2, "N": 2]
    /*
    static let serverAddress = "http://211.200.135.97:3011"
    static let languageCount = 1
    static let reviewNames = ["Review"]
    static let levelToLanguage: [Character: Int] = ["S": 0]
    */
    
    init() {
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        load()
        save()
    }
    
    func save() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(levels, toFile: WordLibrary.ArchiveURL.path)
        print ("save")
        if !isSuccessfulSave {
            print("Failed to save songs...")
        }
        
        levelsToLearn.removeAll()
        for level in levels {
            if level.getWordsToLearn().count > 0 {
                levelsToLearn.append(level)
            }
        }
    }
    
    func load() {
        let savedLevels = NSKeyedUnarchiver.unarchiveObject(withFile: WordLibrary.ArchiveURL.path) as? [Level]
        
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
        
        if let level = Level(name: name) {
            levels.append(level)
            levels.sort (by: { $0.name < $1.name })
            return level
        }
        
        return nil
    }
    
    func getLevelCount() -> Int {
        return levelsToLearn.count
    }
    
    func getLevelFromIndexPath(indexPath: NSIndexPath) -> Level? {
        let row = indexPath.row
        
        if row < levelsToLearn.count {
            return levelsToLearn[row]
        } else {
            return nil
        }
    }
    
    func getLevelName(indexPath: NSIndexPath) -> String {
        return getLevelFromIndexPath(indexPath: indexPath)?.name ?? ""
    }
    
    func getReviewName(indexPath: NSIndexPath) -> String {
        return WordLibrary.reviewNames[indexPath.row]
    }
    
    func getLevelSize(indexPath: NSIndexPath) -> Int {
        return getLevelFromIndexPath(indexPath: indexPath)?.words.count ?? 0
    }
    
    func getLevelRemainCount(indexPath: NSIndexPath) -> Int {
        if let level = getLevelFromIndexPath(indexPath: indexPath) {
            return level.getNotLearnedCount()
        } else {
            return 0
        }
    }
    
    func getLevelDetail(indexPath: NSIndexPath) -> String {
        if let level = getLevelFromIndexPath(indexPath: indexPath) {
            let notLearnedCount = level.getNotLearnedCount()
            
            return "\(notLearnedCount) new words"
        } else {
            return ""
        }
    }
    
    func getLevelsToReview(indexPath: NSIndexPath) -> [Level] {
        var levelsToReview = [Level]()
        
        for level in levels {
            let lang = level.name[level.name.startIndex];
            
            if (indexPath.row == WordLibrary.levelToLanguage[lang]) {
               levelsToReview.append(level)
            }
        }
        
        return levelsToReview
    }
    
    func getReviewRemainCount(indexPath: NSIndexPath) -> Int {
        return getWordsForReview(indexPath: indexPath).count
    }
    
    func getReviewNegativeSum(indexPath: NSIndexPath) -> Int {
        let words = getWordsForReview(indexPath: indexPath)
        var sum = 0
        
        for word in words {
            if word.streak <= 0 {
                sum += 1
            }
        }
        
        return sum
    }
    
    func getReviewDetail(indexPath: NSIndexPath) -> String {
        let learnedCount = getLearnedCount(indexPath: indexPath)
        let doneCount = getDoneCount(indexPath: indexPath)
        let remainCount = getReviewRemainCount(indexPath: indexPath)
        let negativeSum = getReviewNegativeSum(indexPath: indexPath)
        
        if negativeSum > 0 {
            return "\(remainCount - negativeSum)+\(negativeSum)/\(learnedCount - doneCount)+\(doneCount) words"
        } else {
            return "\(remainCount)/\(learnedCount - doneCount)+\(doneCount) words"
        }
    }
    
    func getLearnedCount(indexPath: NSIndexPath) -> Int {
        let levelsToReview = getLevelsToReview(indexPath: indexPath)
        var count = 0
        
        for level in levelsToReview {
            count += level.getLearnedCount()
        }
        
        return count
    }
    
    func getDoneCount(indexPath: NSIndexPath) -> Int {
        let levelsToReview = getLevelsToReview(indexPath: indexPath)
        var count = 0
        
        for level in levelsToReview {
            for word in level.words {
                if (word.streak > 10) {
                    count += 1
                }
            }
        }
        
        return count
    }
    
    func getWordsForReview(indexPath: NSIndexPath? = nil) -> [Word] {
        let levelsToReview = (indexPath != nil) ? getLevelsToReview(indexPath: indexPath!) : levels
        var words = [Word]()
        var wordsForReview = [Word]()
        let curDate = Date()
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents(Set<Calendar.Component>([.day, .month, .year, .hour]), from: curDate)
        
        if (dateComponents.hour! < refHour) {
            dateComponents.hour = refHour
        }
        else {
            dateComponents.hour = refHour
            dateComponents.day = dateComponents.day! + 1
        }
        let refDate = calendar.date(from: dateComponents)!
        
        for level in levelsToReview {
            words.append(contentsOf: level.getWordsToReview())
        }
        
        for word in words {
            var add = true
            
            if let interval = word.lastCorrect?.timeIntervalSince(refDate) {
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
            words.append(contentsOf: level.getWordsToReview())
        }
        
        return words
    }
    
    func getWords(indexPath: NSIndexPath) -> [Word] {
        var words = [Word]()
        let section = indexPath.section
        
        if section == 0 {
            if let level = getLevelFromIndexPath(indexPath: indexPath) {
                words = level.getWordsToLearn()
            }
        } else {
            words = getWordsForReview(indexPath: indexPath)
        }
        
        words.shuffle()
        
        let count = words.count
        
        if count > testLimit {
            words.removeSubrange(testLimit..<count)
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
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: WordLibrary.notificationKey), object: self)
    }
    
    func toJSON() -> String {
        var json = "["
        
        for level in levels {
            for word in level.words {
                
                json += "{\"Level\":\"\(level.name)\",\"index\":\(word.index),\"streak\":\(word.streak),\"learned\":\(word.learned)"
                
                if let lastCorrect = word.lastCorrect {
                    json += ",\"lastCorrect\":\"\(dateFormatter.string(from: lastCorrect))\""
                }
                
                json += "}\n,"
            }
        }
        
        json += "{}]"
        
        return json
    }
    
    func getWord(levelName: String, index: Int) -> Word? {
        for level in levels {
            if (level.name == levelName) {
                return level.getWord(index: index)
            }
        }
        
        return nil
    }
    
    func sync() {
        let urlAsString = WordLibrary.serverAddress + "/sync"
        let url = URL(string: urlAsString)!
        let urlSession = URLSession.shared
        
        var request = URLRequest(url: url as URL)
        request.httpMethod = "PUT"
        request.httpBody = toJSON().data(using: String.Encoding.utf8)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = urlSession.dataTask(with: request, completionHandler: { data, response, error -> Void in
            if error != nil {
                print ("\(String(describing: error))")
            } else {
                print ("put successful")
                
                let jsonData = JSON(data: data!)
                var words = [String:[Word]]()
                
                for (_, json) in jsonData {
                    let level = json["Level"].stringValue
                    let index = json["index"].intValue
                    let word = json["word"].stringValue
                    let yomigana = json["yomigana"].stringValue
                    let meaning = json["meaning"].stringValue
                    
                    if words[level] == nil {
                        words[level] = []
                    }
                    
                    let newWord = Word(index: index, word: word, yomigana: yomigana, meaning: meaning)!
                    
                    if (json["learned"].boolValue) {
                        newWord.learned = true
                        newWord.streak = json["streak"].intValue
                        newWord.lastCorrect = self.dateFormatter.date(from: json["lastCorrect"].stringValue)
                    }
                    
                    words[level]!.append(newWord)
                }
                
                for (level, array) in words {
                    self.getLevelByName(name: level)?.update(words: array)
                }
                
                self.levels = self.levels.filter { words[$0.name] != nil }
                
                self.save()
                self.notifyNetworkDone()
            }
        })
        task.resume()
    }
    
    func notifyNetworkDone() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: WordLibrary.networkNotificationKey), object: self)
    }
    
    func getTestMaterial() -> [[String: Any]] {
        var words = [[String: Any]]()
        
        if levelsToLearn.count > 0 {
            let level = levelsToLearn[0]
            let wordsToLearn = level.getWordsToLearn()
            let limit = min(10, wordsToLearn.count)
            
            for i in 0..<limit {
                let word = wordsToLearn[i]
                var testWord = [String: Any]()
                testWord["level"] = level.name
                testWord["index"] = word.index
                testWord["word"] = word.word
                testWord["yomigana"] = word.yomigana
                testWord["meaning"] = word.meaning
                words.append(testWord)
            }
        } else {
            //
        }
        words.shuffle()
        
        return words
    }
    
    func commitWatchTest(words:[[String: Any]]) {
        var allCorrect = true
        for word in words {
            let result = word["result"] as! Bool
            if result != true {
                allCorrect = false
                break
            }
        }
        
        for word in words {
            let result = word["result"] as! Bool
            let levelName = word["level"] as! String
            let index = word["index"] as! Int
            
            for level in levels {
                if (level.name == levelName) {
                    if let word = level.getWord(index: index) {
                        if word.learned {
                            if result == true {
                                word.correct()
                            } else {
                                word.incorrect()
                            }
                        } else if allCorrect {
                            word.learned = true
                        }
                    }
                    
                    break
                }
            }
        }
        
        save()
        notify()
    }
}
