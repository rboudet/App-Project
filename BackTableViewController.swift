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
    
    
    var isCommitteesDeployed = false
    var isDKEHistoryListOpen = false
    var numberOfCells = 7
    var DeployedCells = 0
    var DeployedCommitteeCells = 0
    var cellChosen = ""
    var committees = ["Finance", "Betterment", "Internal", "External", "Philanthropy", "Social", "House", "Rush"]
    
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
            cell = tableView.dequeueReusableCell(withIdentifier: "cell7", for: indexPath) as UITableViewCell
            if(isCommitteesDeployed){
                cell?.textLabel?.text = "-  Committees "
            }
            else {
                cell?.textLabel?.text = "+  Committees"
            }
        }
        
        if (isCommitteesDeployed){
            if ((5 + DeployedCells < indexPath.row) && (indexPath.row < 6 + DeployedCells + committees.count)){
                cell = tableView.dequeueReusableCell(withIdentifier: "cell7bis", for: indexPath) as UITableViewCell
                print(indexPath.row - 6 - DeployedCells)
                
                if (committees[indexPath.row - 6 - DeployedCells] == Data.currentUser?.committee){
                    cell?.textLabel?.text = "       - " + committees[indexPath.row - 6 - DeployedCells] + " *"
                }
                else {
                    cell?.textLabel?.text = "       - " + committees[indexPath.row - 6 - DeployedCells]
                }
                cell?.backgroundView?.tintColor = UIColor.lightGray
                
            }
           
        }
        
        if( (indexPath as NSIndexPath).row == 6 + DeployedCells + DeployedCommitteeCells){
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
        else{
        
            if((indexPath as NSIndexPath).row == 3){
                if(!isDKEHistoryListOpen){
                
                    isDKEHistoryListOpen = true
                    isCommitteesDeployed = false
                    DeployedCommitteeCells = 0
                    self.DeployedCells = 4
                    self.numberOfCells = 7 + DeployedCells
                    LinkCellTableView.reloadData()
                }
                else{
                    isCommitteesDeployed = false
                    isDKEHistoryListOpen = false
                    self.numberOfCells = 7
                    self.DeployedCells = 0
                    self.DeployedCommitteeCells = 0
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
            
            else if (isCommitteesDeployed && indexPath.row > 5 && indexPath.row < 14){
                CommitteeViewController.toPass = self.committees[indexPath.row - 6]
                isCommitteesDeployed = false
                self.DeployedCommitteeCells = 0
            }
            
            else if (indexPath.row == 5 + DeployedCells){
                if (!isCommitteesDeployed){
                
                    self.numberOfCells = 7 + self.committees.count
                    isCommitteesDeployed = true
                    isDKEHistoryListOpen = false
                    self.DeployedCells = 0
                    self.DeployedCommitteeCells = self.committees.count
                    LinkCellTableView.reloadData()
                }
                else{
                    isCommitteesDeployed = false
                    isDKEHistoryListOpen = false
                    self.DeployedCells = 0
                    self.numberOfCells = 7
                    self.DeployedCommitteeCells = 0
                    LinkCellTableView.reloadData()
                }
            }
            
            else {
                isCommitteesDeployed = false
                isDKEHistoryListOpen = false
                self.numberOfCells = 7
                self.DeployedCells = 0
                self.DeployedCommitteeCells = 0
                LinkCellTableView.reloadData()
            }
        }
    }
    
}
