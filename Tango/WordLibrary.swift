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
    
    func getWords(indexPath: NSIndexPath) -> [Word] {
        let row = indexPath.row
        
        if row < levels.count {
            return levels[row].words
        } else {
            return [Word]()
        }
    }
}