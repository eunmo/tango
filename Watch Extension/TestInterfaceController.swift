//
//  TestInterfaceController.swift
//  Watch Extension
//
//  Created by Eunmo Yang on 5/29/18.
//  Copyright © 2018 Eunmo Yang. All rights reserved.
//

import WatchKit
import Foundation


class TestInterfaceController: WKInterfaceController {

    @IBOutlet var wordLabel: WKInterfaceLabel!
    @IBOutlet var yomiganaLabel: WKInterfaceLabel!
    @IBOutlet var meaningLabel: WKInterfaceLabel!
    
    @IBOutlet var trueButton: WKInterfaceButton!
    @IBOutlet var falseButton: WKInterfaceButton!
    
    var showMeaning = false {
        didSet {
            trueButton.setBackgroundColor(UIColor.darkGray)
            falseButton.setBackgroundColor(UIColor.darkGray)
            
            if word!.result == true {
                trueButton.setBackgroundColor(UIColor(red: 4/255, green: 222/255, blue: 113/255, alpha: 1))
            } else if word!.result == false {
                falseButton.setBackgroundColor(UIColor(red: 255/255, green: 59/255, blue: 48/255, alpha: 1))
            }
            
            if showMeaning {
                yomiganaLabel.setAlpha(1.0)
                meaningLabel.setAlpha(1.0)
            } else {
                yomiganaLabel.setAlpha(0.0)
                meaningLabel.setAlpha(0.0)
            }
        }
    }
    
    func formatMeaningString(meaning: String) -> String {
        var string = meaning
        
        for i in 2...5 {
            string = string.replacingOccurrences(of: " \(i))", with: "\n\(i))")
        }
        
        return string;
    }
    
    var word: TestWord? {
        didSet {
            wordLabel.setText(word!.word)
            yomiganaLabel.setText(word!.yomigana)
            meaningLabel.setText(formatMeaningString(meaning: word!.meaning))
            
            if (word!.yomigana == "") {
                yomiganaLabel.setText(" ")
            }
        }
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        word = context as? TestWord
        showMeaning = false
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        showMeaning = false
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        showMeaning = false
    }

    @IBAction func checkTruePressed() {
        word!.result = true
        showMeaning = !showMeaning
    }
    
    @IBAction func checkFalsePressed() {
        word!.result = false
        showMeaning = !showMeaning
    }
}
