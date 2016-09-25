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
        
        NotificationCenter.default.addObserver(self, selector: #selector(LevelTableViewController.receiveNotification), name: NSNotification.Name(rawValue: WordLibrary.notificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LevelTableViewController.receiveNetNotification), name: NSNotification.Name(rawValue: WordLibrary.networkNotificationKey), object: nil)
    }
    
    func receiveNotification() {
        DispatchQueue.main.async(execute: { () -> Void in
            self.tableView.reloadData()
        })
    }
    
    func receiveNetNotification() {
        DispatchQueue.main.async(execute: { () -> Void in
            let alertController = UIAlertController(title: "Sync done", message: "", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
            self.tableView.reloadData()
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return wordLibrary!.getLearnedCount() > 0 ? 2 : 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return section == 0 ? wordLibrary!.getLevelCount() : 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "LevelTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = getCellText(indexPath: indexPath as NSIndexPath)
        cell.detailTextLabel?.text = getCellDetail(indexPath: indexPath as NSIndexPath)
        cell.isUserInteractionEnabled = getCellEnabled(indexPath: indexPath as NSIndexPath)

        return cell
    }
    
    func getCellText(indexPath: NSIndexPath) -> String {
        if indexPath.section == 0 {
            return wordLibrary!.getLevelName(indexPath: indexPath)
        } else {
            return "復習"
        }
    }
    
    func getCellDetail(indexPath: NSIndexPath) -> String {
        if indexPath.section == 0 {
            return wordLibrary!.getLevelDetail(indexPath: indexPath)
        } else {
            return wordLibrary!.getReviewDetail()
        }
    }
    
    func getCellEnabled(indexPath: NSIndexPath) -> Bool {
        if indexPath.section == 0 {
            return wordLibrary!.getLevelRemainCount(indexPath: indexPath) > 0
        } else {
            return wordLibrary!.getReviewRemainCount() > 0
        }
    }
    
    @IBAction func refresh(_ sender: UIBarButtonItem) {
        tableView.reloadData()
    }

    @IBAction func sync(_ sender: UIBarButtonItem) {
        wordLibrary!.sync()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let identifier = segue.identifier {
            switch identifier {
            case "Show Words":
                if let vc = segue.destination as? WordViewController {
                    let path = tableView.indexPathForSelectedRow!
                    vc.text = getCellText(indexPath: path as NSIndexPath)
                    vc.words = wordLibrary!.getWords(indexPath: path as NSIndexPath)
                    vc.wordLibrary = wordLibrary
                    vc.review = path.section == 1
                }
            case "Show Statistics":
                print("show statistics!!")
                if let vc = segue.destination as? StatsTableViewController {
                    print("show statistics")
                    vc.allWords = wordLibrary!.getAllLearnedWords()
                    vc.wordsToReview = wordLibrary!.getWordsForReview()
                }
            default: break
            }
        }
    }
}
