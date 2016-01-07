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
    var meaing: String
    var learned: Bool
    
    // MARK: Types
    
    struct PropertyKey {
        static let wordKey = "word"
        static let indexKey = "index"
        static let learnedKey = "learned"
    }
    
    init?(index: Int, word: String, yomigana: String, meaning: String) {
        self.index = index
        self.word = word
        self.yomigana = yomigana
        self.meaing = meaning
        self.learned = false
        
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
        meaing = newWord.meaing
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(word, forKey: PropertyKey.wordKey)
        aCoder.encodeInteger(index, forKey: PropertyKey.indexKey)
        aCoder.encodeBool(learned, forKey: PropertyKey.learnedKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let word = aDecoder.decodeObjectForKey(PropertyKey.wordKey) as! String
        let index = aDecoder.decodeIntegerForKey(PropertyKey.indexKey)
        let learned = aDecoder.decodeBoolForKey(PropertyKey.learnedKey)
        
        self.init(index: index, word: word, yomigana: "", meaning: "")
        
        self.learned = learned
    }
}