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
    
    init() {
        load()
    }
    
    func load() {
        if let path = NSBundle.mainBundle().pathForResource("data", ofType: "json"), data = NSData(contentsOfFile: path) {
            loadData(data)
        } else if let path = NSBundle.mainBundle().pathForResource("dummyData", ofType: "json"), data = NSData(contentsOfFile: path) {
            loadData(data)
        }
    }
    
    func loadData(data: NSData) {
        if let jsonData = try! NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? NSArray {
            for levelJson in jsonData as! [NSDictionary] {
                if let level = Level(json: levelJson) {
                    levels.append(level)
                }
            }
        }
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
    
    func getWords(indexPath: NSIndexPath) -> [Word] {
        var words = [Word]()
        let row = indexPath.row
        
        if row < levels.count {
            words = levels[row].words.shuffle()
            
            let count = words.count
            if count > 30 {
                words.removeRange(30..<count)
            }
        }
        
        return words
    }
}

extension CollectionType {
    /// Return a copy of `self` with its elements shuffled
    func shuffle() -> [Generator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
}