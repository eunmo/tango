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
        
        print(getLearnedCount())
    }
    
    func loadData(data: NSData) {
        if let jsonData = try! NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? NSArray {
            for levelJson in jsonData as! [NSDictionary] {
                if let newlevel = Level(json: levelJson) {
                    if let oldLevel = getLevelByName(newlevel.name) {
                        oldLevel.update(newlevel.words)
                    } else {
                        levels.append(newlevel)
                    }
                }
            }
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
    
    func getLevelName(indexPath: NSIndexPath) -> String {
        let row = indexPath.row
        
        if row < levels.count {
            return levels[row].name
        } else {
            return ""
        }
    }
    
    func getLevelSize(indexPath: NSIndexPath) -> Int {
        let row = indexPath.row
        
        if row < levels.count {
            return levels[row].words.count
        } else {
            return 0
        }
    }
    
    func getLevelDetail(indexPath: NSIndexPath) -> String {
        let row = indexPath.row
        
        if row < levels.count {
            let level = levels[row]
            let count = level.words.count
            let learnedCount = level.getLearnedCount()
            
            return "\(learnedCount)/\(count) words"
        } else {
            return ""
        }
    }
    
    func getLearnedCount() -> Int {
        var count = 0
        
        for level in levels {
            count += level.getLearnedCount()
        }
        
        return count
    }
    
    func getWords(indexPath: NSIndexPath) -> [Word] {
        var words = [Word]()
        let section = indexPath.section
        let row = indexPath.row
        
        if section == 0 {
            if row < levels.count {
                words = levels[row].getWordsToLearn()
            }
        } else {
            assert(getLearnedCount() > 0)
            
            for level in levels {
                words.appendContentsOf(level.getWordsToReview())
            }
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
            if word.learned {
                
            } else {
                word.learned = true
            }
        }
        
        save()
        notify()
    }
    
    func notify() {
        NSNotificationCenter.defaultCenter().postNotificationName(WordLibrary.notificationKey, object: self)
    }
}