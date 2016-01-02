//
//  Word.swift
//  Tango
//
//  Created by Eunmo Yang on 1/2/16.
//  Copyright © 2016 Eunmo Yang. All rights reserved.
//

import Foundation

class Word {
    
    let index: Int
    var word: String
    var yomigana: String
    var meaing: String
    
    init?(index: Int, word: String, yomigana: String, meaning: String) {
        self.index = index
        self.word = word
        self.yomigana = yomigana
        self.meaing = meaning
        
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
}