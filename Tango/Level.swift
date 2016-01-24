//
//  Level.swift
//  Tango
//
//  Created by Eunmo Yang on 1/3/16.
//  Copyright © 2016 Eunmo Yang. All rights reserved.
//

import Foundation

class Level: NSObject, NSCoding {
    
    // MARK: Properties
    
    var words = [Word]()
    var wordIndices = [Int:Word]()
    var name = ""
    
    // MARK: Types
    
    struct PropertyKey {
        static let wordsKey = "words"
        static let nameKey = "name"
    }
    
    init?(name: String) {
        self.name = name
        
        super.init()
        
        if self.name.isEmpty {
            return nil
        }
    }
    
    convenience init?(json: NSDictionary) {
        let name = json["level"] as? String ?? ""
        
        self.init(name: name)
        
        if let array = json["words"] as? [NSDictionary] {
            for word in array {
                addWordFromDict(word)
            }
        }
        
        if words.isEmpty {
            return nil
        }
    }
    
    func addWord(word: Word) {
        words.append(word)
        wordIndices[word.index] = word
    }
    
    func addWordFromDict(dict: NSDictionary) {
        if let word = Word(dict: dict) {
            addWord(word)
        }
    }
    
    func getWord(index: Int) -> Word? {
        return wordIndices[index]
    }
    
    func update(words: [Word]) {
        for newWord in words {
            if let oldWord = getWord(newWord.index) {
                oldWord.update(newWord)
            } else {
                addWord(newWord)
            }
        }
        
        // delete words not in datafile
        var newWords = [Word]()
        var newWordIndices = [Int:Word]()
        
        for newWord in words {
            let word = getWord(newWord.index)!
            newWords.append(word)
            newWordIndices[word.index] = word
        }
        
        self.words = newWords
        self.wordIndices = newWordIndices
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(words, forKey: PropertyKey.wordsKey)
        aCoder.encodeObject(name, forKey: PropertyKey.nameKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let words = aDecoder.decodeObjectForKey(PropertyKey.wordsKey) as! [Word]
        let name = aDecoder.decodeObjectForKey(PropertyKey.nameKey) as! String
        
        self.init(name: name)
        
        for word in words {
            addWord(word)
        }
    }
    
    func getLearnedCount() -> Int {
        var count = 0
        
        for word in words {
            if word.learned {
                count++;
            }
        }
        
        return count
    }
    
    func getWordsToReview() -> [Word] {
        var learnedWords = [Word]()
        
        for word in words {
            if word.learned {
                learnedWords.append(word)
            }
        }
        
        return learnedWords
    }
    
    func getWordsToLearn() -> [Word] {
        var wordsToLearn = [Word]()
        
        for word in words {
            if !word.learned {
                wordsToLearn.append(word)
            }
        }
        
        return wordsToLearn
    }
}