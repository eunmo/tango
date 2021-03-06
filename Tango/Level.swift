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
                addWordFromDict(dict: word)
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
            addWord(word: word)
        }
    }
    
    func getWord(index: Int) -> Word? {
        return wordIndices[index]
    }
    
    func update(words: [Word]) {
        for newWord in words {
            if let oldWord = getWord(index: newWord.index) {
                oldWord.update(newWord: newWord)
            } else {
                addWord(word: newWord)
            }
        }
        
        // delete words not in datafile
        var newWords = [Word]()
        var newWordIndices = [Int:Word]()
        
        for newWord in words {
            let word = getWord(index: newWord.index)!
            newWords.append(word)
            newWordIndices[word.index] = word
        }
        
        self.words = newWords
        self.wordIndices = newWordIndices
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(words, forKey: PropertyKey.wordsKey)
        aCoder.encode(name, forKey: PropertyKey.nameKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let words = aDecoder.decodeObject(forKey: PropertyKey.wordsKey) as! [Word]
        let name = aDecoder.decodeObject(forKey: PropertyKey.nameKey) as! String
        
        self.init(name: name)
        
        for word in words {
            addWord(word: word)
        }
    }
    
    func getLearnedCount() -> Int {
        var count = 0
        
        for word in words {
            if word.learned {
                count += 1;
            }
        }
        
        return count
    }
    
    func getNotLearnedCount() -> Int {
        var count = 0
        
        for word in words {
            if !word.learned {
                count += 1;
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
