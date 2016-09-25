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
    var lastCorrect: Date?
    
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
        if let index = dict["index"] as? Int, let word = dict["word"] as? String, let yomigana = dict["yomigana"] as? String, let meaning = dict["meaning"] as? String {
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
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(word, forKey: PropertyKey.wordKey)
        aCoder.encode(index, forKey: PropertyKey.indexKey)
        aCoder.encode(yomigana, forKey: PropertyKey.yomiganaKey)
        aCoder.encode(meaning, forKey: PropertyKey.meaningKey)
        aCoder.encode(learned, forKey: PropertyKey.learnedKey)
        aCoder.encode(streak, forKey: PropertyKey.streakKey)
        aCoder.encode(lastCorrect, forKey: PropertyKey.lastCorrectKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let word = aDecoder.decodeObject(forKey: PropertyKey.wordKey) as! String
        let index = aDecoder.decodeInteger(forKey: PropertyKey.indexKey)
        let yomigana = aDecoder.decodeObject(forKey: PropertyKey.yomiganaKey) as? String ?? ""
        let meaning = aDecoder.decodeObject(forKey: PropertyKey.meaningKey) as? String ?? ""
        
        self.init(index: index, word: word, yomigana: yomigana, meaning: meaning)
        
        self.streak = aDecoder.decodeInteger(forKey: PropertyKey.streakKey)
        self.lastCorrect = aDecoder.decodeObject(forKey: PropertyKey.lastCorrectKey) as? Date
        self.learned = aDecoder.decodeBool(forKey: PropertyKey.learnedKey)
    }
    
    func correct() {
        streak += 1
        lastCorrect = Date()
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
