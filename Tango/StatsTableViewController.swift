//
//  StatsTableViewController.swift
//  Tango
//
//  Created by Eunmo Yang on 4/9/16.
//  Copyright © 2016 Eunmo Yang. All rights reserved.
//

import UIKit

class StatsTableViewController: UITableViewController {
    
    var allWords = [Word]()
    var wordsToReview = [Word]()
    var learnedCount = [Int]()
    var reviewCount = [Int]()
    var max = 0
    var min = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        for word in allWords {
            if (word.streak > max) {
                max = word.streak
            }
            
            if (word.streak < min) {
                min = word.streak
            }
        }
        
        learnedCount = [Int](repeating: 0, count: max - min + 1)
        
        for word in allWords {
            learnedCount[word.streak - min] += 1
        }
        
        reviewCount = [Int](repeating: 0, count: max - min + 1)
        
        for word in wordsToReview {
            reviewCount[word.streak - min] += 1
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return max - min + 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "StatsTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        // Configure the cell...
        let index = indexPath.row
        let streak = index + min
        cell.textLabel?.text = "\(streak)"
        
        if streak > 0 {
            cell.detailTextLabel?.text = "\(reviewCount[index])/\(learnedCount[index])"
            cell.backgroundColor = UIColor.clear
        } else {
            cell.detailTextLabel?.text = "\(learnedCount[index])"
            cell.backgroundColor = UIColor.init(red: 0.5, green: 0.0, blue: 0.0, alpha: 1.0)
        }
        
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
