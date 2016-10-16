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
        LinkCellTableView.backgroundColor = UIColor.gray
        LinkCellTableView.tableFooterView = UIView()
        LinkCellTableView.tableHeaderView = UIView()
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell?
        if ((indexPath as NSIndexPath).row == 0){
            cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as UITableViewCell
        }
        else if ((indexPath as NSIndexPath).row == 1){
            cell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as UITableViewCell
        }
        else if ((indexPath as NSIndexPath).row == 2){
            cell = tableView.dequeueReusableCell(withIdentifier: "cell3", for: indexPath) as UITableViewCell
        }
        else if((indexPath as NSIndexPath).row == 3){
            cell = tableView.dequeueReusableCell(withIdentifier: "cell4", for: indexPath) as UITableViewCell
            if (!isDKEHistoryListOpen){
                cell?.textLabel!.text = "+ DKE History"
            }
            else{
                cell?.textLabel!.text = "- DKE History"
            }
        }
        
        if( self.isDKEHistoryListOpen){
            if ((indexPath as NSIndexPath).row == 4){
                cell = tableView.dequeueReusableCell(withIdentifier: "cell5", for: indexPath) as UITableViewCell
                cell?.textLabel?.text = "       - Founding Fathers"
            }
            if ((indexPath as NSIndexPath).row == 5){
                cell = tableView.dequeueReusableCell(withIdentifier: "cell5", for: indexPath) as UITableViewCell
                cell?.textLabel?.text = "       - First Chapters"
               
            }
            if ((indexPath as NSIndexPath).row == 6){
                cell = tableView.dequeueReusableCell(withIdentifier: "cell5", for: indexPath) as UITableViewCell
                cell?.textLabel?.text = "       - Objects of DKE"
            }
            if ((indexPath as NSIndexPath).row == 7){
                cell = tableView.dequeueReusableCell(withIdentifier: "cell5", for: indexPath) as UITableViewCell
                cell?.textLabel?.text = "       - TA History"
            }

        }
        
        if ((indexPath as NSIndexPath).row == 4 + DeployedCells){
            // add Event
            cell = tableView.dequeueReusableCell(withIdentifier: "cell6", for: indexPath) as UITableViewCell
            
            
        }
        
        if( (indexPath as NSIndexPath).row == 5 + DeployedCells){
            // Logout
            cell = tableView.dequeueReusableCell(withIdentifier: "cell7", for: indexPath) as UITableViewCell
        }
        if( (indexPath as NSIndexPath).row == 6 + DeployedCells){
            // Logout
            cell = tableView.dequeueReusableCell(withIdentifier: "cell8", for: indexPath) as UITableViewCell
        }
        
        
        cell?.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfCells
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if((indexPath as NSIndexPath).row == 3){
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
        
        else if ((indexPath as NSIndexPath).row > 3 && (indexPath as NSIndexPath).row < 7 && isDKEHistoryListOpen){
            if ((indexPath as NSIndexPath).row == 4){
                HistoryDataViewController.toPass = "DKEFoundingFathers"
            }
            if ((indexPath as NSIndexPath).row == 5){
                HistoryDataViewController.toPass = "DKEFirstChapters"
            }
            
            if ((indexPath as NSIndexPath).row == 6){
                 HistoryDataViewController.toPass = "objects"
            }
            if ((indexPath as NSIndexPath).row == 7){
                HistoryDataViewController.toPass = "TAHistory"
            }
            
            
        }
        else {
            isDKEHistoryListOpen = false
            self.numberOfCells = 7
            self.DeployedCells = 0
            LinkCellTableView.reloadData()
        }
        
        if ((indexPath as NSIndexPath).row == 6 + DeployedCells){
            // the user decides to log out
            let alert = UIAlertController(title: "Logging out", message: "Are you sure you want to sign out of your account", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: {  (action: UIAlertAction!) in
                GIDSignIn.sharedInstance().signOut()
                try! FIRAuth.auth()!.signOut()
                self.performSegue(withIdentifier: "HomeToLogin", sender: nil)
            }))
            
            alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)

        }
    }
    
}
