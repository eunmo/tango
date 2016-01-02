//
//  Word.swift
//  Tango
//
//  Created by Eunmo Yang on 1/2/16.
//  Copyright © 2016 Eunmo Yang. All rights reserved.
//

import Foundation

class Word {
    var word: String
    var yomigana: String
    var meaing: String
    
    init?(word: String, yomigana: String, meaning: String) {
        self.word = word
        self.yomigana = yomigana
        self.meaing = meaning
        
        if word.isEmpty {
            return nil
        }
    }
}