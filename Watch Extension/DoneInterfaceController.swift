//
//  DoneInterfaceController.swift
//  Watch Extension
//
//  Created by Eunmo Yang on 5/30/18.
//  Copyright © 2018 Eunmo Yang. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class DoneInterfaceController: WKInterfaceController {
    
    @IBOutlet var commitButton: WKInterfaceButton!
    
    var words: [TestWord]?

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        words = context as? [TestWord]
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        var trueCount = 0
        
        for word in words! {
            if word.result == true {
                trueCount += 1
            }
        }
        
        commitButton.setTitle("Commit \(trueCount)/\(words!.count)")
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func commitButtonPressed() {
        let session = WCSession.default
        
        var message = [String: Any]()
        message["request"] = "commit"
        
        var commitWords = [[String: Any]]()
        for word in words! {
            var commitWord = [String: Any]()
            commitWord["result"] = word.result
            commitWord["level"] = word.level
            commitWord["index"] = word.levelIndex
            commitWord["streak"] = word.streak
            commitWords.append(commitWord)
        }
        message["words"] = commitWords as Any
        
        session.sendMessage(message, replyHandler: { (reply) in
            self.dismiss()
        }) { (error) in
            print(error)
        }
    }
}
