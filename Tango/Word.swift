//
//  Word.swift
//  Tango
//
//  Created by Eunmo Yang on 1/2/16.
//  Copyright © 2016 Eunmo Yang. All rights reserved.
//

import Foundation

class Word: NSObject, NSCoding {
    
    // MARK: Properties
    
    let index: Int
    var word: String
    var yomigana: String
    var meaning: String
    var learned: Bool
    var streak: Int
    var lastCorrect: NSDate?
    
    // MARK: Types
    
    struct PropertyKey {
        static let wordKey = "word"
        static let indexKey = "index"
        static let yomiganaKey = "yomigana"
        static let meaningKey = "meaning"
        static let learnedKey = "learned"
        static let streakKey = "streak"
        static let lastCorrectKey = "lastCorrect"
    }
    
    init?(index: Int, word: String, yomigana: String, meaning: String) {
        self.index = index
        self.word = word
        self.yomigana = yomigana
        self.meaning = meaning
        self.learned = false
        self.streak = 0
        
        super.init()
        
        if word.isEmpty {
            return nil
        }
    }
    
    convenience init?(dict: NSDictionary) {
        if let index = dict["index"] as? Int, word = dict["word"] as? String, yomigana = dict["yomigana"] as? String, meaning = dict["meaning"] as? String {
            self.init(index: index, word: word, yomigana: yomigana, meaning: meaning)
        } else {
            return nil
        }
    }
    
    func update(newWord: Word) {
        word = newWord.word
        yomigana = newWord.yomigana
        meaning = newWord.meaning
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(word, forKey: PropertyKey.wordKey)
        aCoder.encodeInteger(index, forKey: PropertyKey.indexKey)
        aCoder.encodeObject(yomigana, forKey: PropertyKey.yomiganaKey)
        aCoder.encodeObject(meaning, forKey: PropertyKey.meaningKey)
        aCoder.encodeBool(learned, forKey: PropertyKey.learnedKey)
        aCoder.encodeInteger(streak, forKey: PropertyKey.streakKey)
        aCoder.encodeObject(lastCorrect, forKey: PropertyKey.lastCorrectKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let word = aDecoder.decodeObjectForKey(PropertyKey.wordKey) as! String
        let index = aDecoder.decodeIntegerForKey(PropertyKey.indexKey)
        let yomigana = aDecoder.decodeObjectForKey(PropertyKey.yomiganaKey) as? String ?? ""
        let meaning = aDecoder.decodeObjectForKey(PropertyKey.meaningKey) as? String ?? ""
        
        self.init(index: index, word: word, yomigana: yomigana, meaning: meaning)
        
        self.streak = aDecoder.decodeIntegerForKey(PropertyKey.streakKey)
        self.lastCorrect = aDecoder.decodeObjectForKey(PropertyKey.lastCorrectKey) as? NSDate
        self.learned = aDecoder.decodeBoolForKey(PropertyKey.learnedKey)
    }
    
    func correct() {
        streak += 1
        lastCorrect = NSDate()
    }
    
    func incorrect() {
        if (streak > 0) {
            streak = -1
        } else {
            streak -= 1
        }
        lastCorrect = nil
    }
}