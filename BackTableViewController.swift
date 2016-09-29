//
//  BackTableViewController.swift
//  DKE
//
//  Created by Romain Boudet on 18/09/16.
//  Copyright © 2016 Romain Boudet. All rights reserved.
//

import Foundation
import Firebase
import GoogleSignIn

class BackTableViewController: UITableViewController {
    @IBOutlet var LinkCellTableView: UITableView!
    
    var isDKEHistoryListOpen = false
    var numberOfCells = 7
    var DeployedCells = 0
    var cellChosen = ""
    override func viewDidLoad() {
        LinkCellTableView.backgroundColor = UIColor.grayColor()
        LinkCellTableView.tableFooterView = UIView()
        LinkCellTableView.tableHeaderView = UIView()
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell?
        if (indexPath.row == 0){
            cell = tableView.dequeueReusableCellWithIdentifier("cell1", forIndexPath: indexPath) as UITableViewCell
        }
        else if (indexPath.row == 1){
            cell = tableView.dequeueReusableCellWithIdentifier("cell2", forIndexPath: indexPath) as UITableViewCell
        }
        else if (indexPath.row == 2){
            cell = tableView.dequeueReusableCellWithIdentifier("cell3", forIndexPath: indexPath) as UITableViewCell
        }
        else if(indexPath.row == 3){
            cell = tableView.dequeueReusableCellWithIdentifier("cell4", forIndexPath: indexPath) as UITableViewCell
            if (!isDKEHistoryListOpen){
                cell?.textLabel!.text = "+ DKE History"
            }
            else{
                cell?.textLabel!.text = "- DKE History"
            }
        }
        
        if( self.isDKEHistoryListOpen){
            if (indexPath.row == 4){
                cell = tableView.dequeueReusableCellWithIdentifier("cell5", forIndexPath: indexPath) as UITableViewCell
                cell?.textLabel?.text = "       - Founding Fathers"
            }
            if (indexPath.row == 5){
                cell = tableView.dequeueReusableCellWithIdentifier("cell5", forIndexPath: indexPath) as UITableViewCell
                cell?.textLabel?.text = "       - First Chapters"
               
            }
            if (indexPath.row == 6){
                cell = tableView.dequeueReusableCellWithIdentifier("cell5", forIndexPath: indexPath) as UITableViewCell
                cell?.textLabel?.text = "       - Objects of DKE"
            }
            if (indexPath.row == 7){
                cell = tableView.dequeueReusableCellWithIdentifier("cell5", forIndexPath: indexPath) as UITableViewCell
                cell?.textLabel?.text = "       - TA History"
            }

        }
        
        if (indexPath.row == 4 + DeployedCells){
            // add Event
            cell = tableView.dequeueReusableCellWithIdentifier("cell6", forIndexPath: indexPath) as UITableViewCell
            
            
        }
        
        if( indexPath.row == 5 + DeployedCells){
            // Logout
            cell = tableView.dequeueReusableCellWithIdentifier("cell7", forIndexPath: indexPath) as UITableViewCell
        }
        if( indexPath.row == 6 + DeployedCells){
            // Logout
            cell = tableView.dequeueReusableCellWithIdentifier("cell8", forIndexPath: indexPath) as UITableViewCell
        }
        
        
        cell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfCells
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(indexPath.row == 3){
            if(!isDKEHistoryListOpen){
                self.numberOfCells = self.numberOfCells + 4
                isDKEHistoryListOpen = true
                self.DeployedCells = 4
                LinkCellTableView.reloadData()
            }
            else{
                isDKEHistoryListOpen = false
                self.numberOfCells = 7
                self.DeployedCells = 0
                LinkCellTableView.reloadData()
            }
        }
        
        else if (indexPath.row > 3 && indexPath.row < 7 && isDKEHistoryListOpen){
            if (indexPath.row == 4){
                HistoryDataViewController.toPass = "DKEFoundingFathers"
            }
            if (indexPath.row == 5){
                HistoryDataViewController.toPass = "DKEFirstChapters"
            }
            
            if (indexPath.row == 6){
                 HistoryDataViewController.toPass = "objects"
            }
            if (indexPath.row == 7){
                HistoryDataViewController.toPass = "TAHistory"
            }
            
            
        }
        else {
            isDKEHistoryListOpen = false
            self.numberOfCells = 7
            self.DeployedCells = 0
            LinkCellTableView.reloadData()
        }
        
        if (indexPath.row == 6 + DeployedCells){
            // the user decides to log out
            let alert = UIAlertController(title: "Logging out", message: "Are you sure you want to sign out of your account", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: {  (action: UIAlertAction!) in
                GIDSignIn.sharedInstance().signOut()
                try! FIRAuth.auth()!.signOut()
                CreateEventPageViewController.arrGoogleCalendars = nil
                self.performSegueWithIdentifier("HomeToLogin", sender: nil)
            }))
            
            alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)

        }
    }
    
}