//
//  LevelTableViewController.swift
//  Tango
//
//  Created by Eunmo Yang on 1/2/16.
//  Copyright © 2016 Eunmo Yang. All rights reserved.
//

import UIKit

class LevelTableViewController: UITableViewController {
    
    var wordLibrary: WordLibrary?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        wordLibrary = WordLibrary()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receiveNotification", name: WordLibrary.notificationKey, object: nil)
    }
    
    func receiveNotification() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadData()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return wordLibrary!.getLearnedCount() > 0 ? 2 : 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return section == 0 ? wordLibrary!.getLevelCount() : 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "LevelTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)

        // Configure the cell...
        cell.textLabel?.text = getCellText(indexPath)
        cell.detailTextLabel?.text = getCellDetail(indexPath)
        cell.userInteractionEnabled = getCellEnabled(indexPath)

        return cell
    }
    
    func getCellText(indexPath: NSIndexPath) -> String {
        if indexPath.section == 0 {
            return wordLibrary!.getLevelName(indexPath)
        } else {
            return "復習"
        }
    }
    
    func getCellDetail(indexPath: NSIndexPath) -> String {
        if indexPath.section == 0 {
            return wordLibrary!.getLevelDetail(indexPath)
        } else {
            return wordLibrary!.getReviewDetail()
        }
    }
    
    func getCellEnabled(indexPath: NSIndexPath) -> Bool {
        if indexPath.section == 0 {
            return wordLibrary!.getLevelRemainCount(indexPath) > 0
        } else {
            return wordLibrary!.getReviewRemainCount() > 0
        }
    }
    
    @IBAction func refresh(sender: UIBarButtonItem) {
        tableView.reloadData()
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let identifier = segue.identifier {
            switch identifier {
            case "Show Words":
                if let vc = segue.destinationViewController as? WordViewController {
                    let path = tableView.indexPathForSelectedRow!
                    vc.text = getCellText(path)
                    vc.words = wordLibrary!.getWords(path)
                    vc.wordLibrary = wordLibrary
                    vc.review = path.section == 1
                }
            default: break
            }
        }
    }
}
