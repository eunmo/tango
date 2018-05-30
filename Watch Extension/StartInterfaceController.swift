//
//  StartInterfaceController.swift
//  Watch Extension
//
//  Created by Eunmo Yang on 5/29/18.
//  Copyright © 2018 Eunmo Yang. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class TestWord {
    
    let index: Int
    let word: String
    let level: String
    let levelIndex: Int
    let yomigana: String
    let meaning: String
    let streak: Int
    var result: Bool?
    
    init(index: Int, word: String, level: String, levelIndex: Int, yomigana: String, meaning: String, streak: Int) {
        self.index = index
        self.word = word
        self.level = level
        self.levelIndex = levelIndex
        self.yomigana = yomigana
        self.meaning = meaning
        self.streak = streak
    }
}

class StartInterfaceController: WKInterfaceController {

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    @IBAction func startButtonPressed() {
        let session = WCSession.default
        
        session.sendMessage(["request": "test"], replyHandler: { (reply) in
            if let value = reply["words"] {
                let array = value as! [[String: Any]]
                var controllers = [String]()
                var contexts = [Any]()
                for (index, word) in array.enumerated() {
                    controllers.append("Test")
                    let level = word["level"] as! String
                    let levelIndex = word["index"] as! Int
                    let yomigana = word["yomigana"] as! String
                    let meaning = word["meaning"] as! String
                    let streak = word["streak"] as! Int
                    let word = word["word"] as! String
                    contexts.append(TestWord(index: index, word: word, level: level, levelIndex: levelIndex, yomigana: yomigana, meaning: meaning, streak: streak))
                }
                controllers.append("Done")
                contexts.append(contexts)
                self.presentController(withNames: controllers, contexts: contexts)
            }
        }) { (error) in
            print(error)
        }
    }
}
