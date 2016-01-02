//
//  Level.swift
//  Tango
//
//  Created by Eunmo Yang on 1/3/16.
//  Copyright © 2016 Eunmo Yang. All rights reserved.
//

import Foundation

class Level {
    
    // MARK: Properties
    var words = [Word]()
    var name = ""
    
    init?(json: NSDictionary) {
        if let name = json["level"] as? String {
            self.name = name
            
            if let array = json["words"] as? [NSDictionary] {
                for word in array {
                    addWord(word)
                }
            }
        }
        
        if self.name.isEmpty || words.isEmpty {
            return nil
        }
        
        print(self.name)
    }
    
    func addWord(dict: NSDictionary) {
        if let word = Word(dict: dict) {
            words.append(word)
        }
    }
}