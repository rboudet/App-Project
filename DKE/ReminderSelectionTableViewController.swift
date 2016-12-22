//
//  ReminderSelectionTableViewController.swift
//  DKE
//
//  Created by Romain Boudet on 28/10/16.
//  Copyright © 2016 Romain Boudet. All rights reserved.
//

import UIKit

class ReminderSelectionTableViewController: UITableViewController {

    @IBOutlet var ReminderTableView: UITableView!
    var reminderArray = ["test"]
    var compareWith = " "
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ReminderTableView.tableHeaderView = UIView()
        ReminderTableView.tableFooterView = UIView()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
        return (reminderArray.count)
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.font = UIFont(name: "Arial", size: 12.0)
        cell.textLabel?.text = reminderArray[indexPath.row]
        if(reminderArray[indexPath.row] ==  compareWith ){
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryType.none
        }
        // Configure the cell...
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (reminderArray[0] == "Finance"){
            // ie we are choosing who to select
            CreateEventPageViewController.whoToRemind = reminderArray[indexPath.row]
            if (indexPath.row == reminderArray.count - 1){
                CreateEventPageViewController.isReminderCustom = true
            }
            else {
                CreateEventPageViewController.isReminderCustom = false
            }
        }
        else {
            // then we are choosing what form of reminder
            CreateEventPageViewController.currentReminder = reminderArray[indexPath.row]
        }
        
        CreateEventPageViewController.tblPostData2?.reloadData()
        
        _ = navigationController?.popViewController(animated: true)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
