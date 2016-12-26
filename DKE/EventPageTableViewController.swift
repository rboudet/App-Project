//
//  EventPageTableViewController.swift
//  DKE
//
//  Created by romain boudet on 2016-11-13.
//  Copyright © 2016 Romain Boudet. All rights reserved.
//

import UIKit
import Firebase

class EventPageTableViewController: UITableViewController {

    var startDate : [String]?
    var endDate : [String]?
    var day : String?
    var month : String?
    var organisator : String?
    var location : String?
    var users = [] as [String]
    var usersName = [String]()
    var isReady = false
    
    var indexPathToEdit : IndexPath?
    
    static var willEdit = false
    
    
    var elementSelected = 0
    
    // we set up an array of dictionaries to keep track of the messages posted by the users, it will be [[message : userID]]
    static var messages = [[String : String]]()
    
    
    @IBOutlet var EventTableView: UITableView!
    
   static var event = WelcomePageTableViewController.toPass
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isTranslucent = true
        
        let eventTitle = EventPageTableViewController.event
        
        let width = EventTableView.frame.width
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 140.0))
        let ImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: 140.0))
        ImageView.image = UIImage(named: "DKE_flag")
        ImageView.contentMode = .scaleToFill
        headerView.addSubview(ImageView)
 
        self.EventTableView.tableHeaderView = headerView
        self.EventTableView.tableFooterView = UIView()
    
        Data.ref.child("Events").child(eventTitle).observe(FIRDataEventType.value, with: { (snapshot) in
            if (snapshot.value != nil){
                let data = snapshot.value as! [String : AnyObject]
                let startDateString =  data["startDate"] as? String
                let endDateString = data["endDate"] as? String
                self.location = data["location"] as? String
                self.startDate = startDateString?.components(separatedBy: "T")
                self.endDate = endDateString?.components(separatedBy: "T")
                self.day = data["Day"] as? String
                self.month = data["Month"] as? String
                self.organisator = data["Creator"] as? String
                
                if (data["Attending"] != nil){
                    self.users = (data["Attending"] as! [String])
                    for i in 0...self.users.count-1 {
                        Data.ref.child("users").child(self.users[i] ).observe(FIRDataEventType.value, with: { (snapshot) in
                            if (snapshot.value != nil){
                                let data2 = snapshot.value as! [String : AnyObject]
                                let firstName = data2["firstName"] as! String
                                let lastName = data2["lastName"] as! String
                                self.usersName.append(firstName + " "  + lastName)
                                
                                if (i == self.users.count-1){
                                    self.isReady = true
                                    self.EventTableView.reloadData()
                                }
                            }
                            
                        })
                    }
                }
                else {
                    self.isReady = true
                    self.EventTableView.reloadData()
                }
                
                if (data["Messages"] != nil){
                    EventPageTableViewController.messages = data["Messages"] as! [[String : String]]
                }
                
                
            }
        })
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        WelcomePageTableViewController.indicator.stopAnimating()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        EventTableView.reloadData()
    }

    

    override func viewWillDisappear(_ animated: Bool) {
        // each time we come back to this view, we want to reset the title of the navigation par to its original text
        let navigationBar = self.navigationController?.navigationBar
        let subviews = navigationBar?.subviews
        let label = subviews?[3]
        if let _ = label  as? UILabel {
            (label as! UILabel).text = "Upcoming Events"
        }
        else {
            // bug if the user clicks too quickly on 'back' then the subviews dont have to change, and the label is in the 2nd position not 3rd
            let label = subviews?[2]
            if let _ = label  as? UILabel {
                (label as! UILabel).text = "Upcoming Events"
            }

        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        var rows = 0
        if (self.isReady && section == 0){
            rows = 3
        }
        else if(self.isReady && section == 1){
            rows = EventPageTableViewController.messages.count
        }
       
        return rows
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var titleHeader = ""
        
        if (section == 1 && EventPageTableViewController.messages.count != 0){
            titleHeader = "Discussion"
        }
        return titleHeader
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = EventTableView.dequeueReusableCell(withIdentifier: "EventCell") as! MyCustomCell2
        var cell2 : UITableViewCell
        
        if (self.isReady){
            // we wait until the data has loaded then we output the cells
            let section = indexPath.section
            if(section == 0){
                cell.DayLabel.isHidden = false
                cell.EventTitleLabel.isHidden = false
                cell.OrganisatorLabel.isHidden = false
                cell.MonthLabel.isHidden = false
            
                if(indexPath.row == 0) {
                    cell.DayLabel.text = self.day!
                    cell.MonthLabel.text = self.month!
                    cell.EventTitleLabel.text = EventPageTableViewController.event
                    var text = ""
                    if (usersName.count == 0){
                        text = "No brother is currently attending this event"
                    }
                    else if(usersName.count == 1){
                        text = usersName[0] + "  is attending the event"
                    }
                    else if(usersName.count == 2){
                        text = usersName[0] + " and " + usersName[1] + " are attending the event"
                    }
                    else {
                        // ie there are more then 2 
                        // we want to find 2 random numbers in the array, 
                        let index1 = Int(arc4random_uniform(UInt32(usersName.count)))
                        var index2 = Int(arc4random_uniform(UInt32(usersName.count)))
                        while (index2 == index1){
                            // in case we get twice the same index
                            index2 = Int(arc4random_uniform(UInt32(usersName.count)))
                        }
                        text = usersName[index1] + " , " + usersName[index2] + "and \(users.count-2)  other brothers are going"
                    }
                    cell.OrganisatorLabel.text = text
                
                }
                else if (indexPath.row == 1){
                    cell = EventTableView.dequeueReusableCell(withIdentifier: "SelectionCell") as! MyCustomCell2
                }
                else if (indexPath.row == 2){
                    if (elementSelected == 0){
                        cell2 = EventTableView.dequeueReusableCell(withIdentifier: "AboutCell")!
                        cell2.textLabel?.text = "The creator of the event has not specified more information, contact him for more"
                        let x = cell2.frame.maxX
                        let y = cell2.frame.maxY
                        
                        cell2.textLabel?.font = UIFont(name: "Arial", size: 12.0)
                        let button = UIButton(frame: CGRect(x: x-20, y: y-20, width: 20, height: 20))
                        button.setTitle("see More", for: UIControlState.normal)
                        cell2.addSubview(button)
                        return cell2
                    }
                    else{
                        cell = EventTableView.dequeueReusableCell(withIdentifier: "DiscussionCell") as! MyCustomCell2
                        cell.profilePicture.image = Data.currentUser?.profilePicture
                        
                    }
                }
            }
                
            else if(section == 1){
                // these are the message cells,they have a title that takes the name of the user who wrote the message, and a subtitle that has the messsage itself
                let length = EventPageTableViewController.messages.count - 1
                cell2 = EventTableView.dequeueReusableCell(withIdentifier: "MessageCell")!
                cell2.textLabel?.text = EventPageTableViewController.messages[length - indexPath.row]["User"]! + " :"
                cell2.detailTextLabel?.text = EventPageTableViewController.messages[length - indexPath.row]["Message"]
                // we show the last messages first, as they will be the most recent ones
                cell2.detailTextLabel?.numberOfLines = 0
                cell2.textLabel?.font = UIFont(name: "Arial-Bold", size: 12.0 )
                cell2.detailTextLabel?.font = UIFont(name: "Arial", size: 12.0)
               
                
                // we need to add a 'see more' button in the cell, in case the text is too long and doesnt fit in the label
                // then we would need to expand the size of the cell if the user clicks on that button
                
                 return cell2
                
            }

            
        }


        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height = 70.0
        let section = indexPath.section
        if(section == 0 && indexPath.row == 1){
            height = 27.0
        }
        else if (indexPath.row > 2){
            return UITableViewAutomaticDimension
        }
        
        return CGFloat(height)
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = EventTableView.cellForRow(at: indexPath) as! MyCustomCell2
        cell.setSelected(false, animated: true)
        
        let section = indexPath.section
        let row = indexPath.row
        if(section == 1){
            let name = EventPageTableViewController.messages[row]["User"]
            if(Data.currentUser?.fullName == name){
                // then the message was written by the current user, and therefore should be editable and deletable
                // when the user taps on the message, we present a menu comming up, that asks him what he wants to do
                // if he chooses edit, we send him back to the textView page, where he can modify and save his message
                // if he chooses delete, then we take the message out of the list, and we update the data in firebase
                
                
                let optionMenu = UIAlertController(title: nil, message: "", preferredStyle: .actionSheet)
                let editAction = UIAlertAction(title: "Edit Message", style: .default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    EventPageTableViewController.willEdit = true
                    self.indexPathToEdit = indexPath
                    self.performSegue(withIdentifier: "EditMessage", sender: nil)
                    
                    
                })
                
                let deleteAction = UIAlertAction(title: "Delete Message", style: .destructive, handler: {
                    (alert: UIAlertAction!) -> Void in
                    let length = EventPageTableViewController.messages.count - 1
                    
                    
                    // first we make sure the user is certain he wants to delete his message
                    
                    let alert = UIAlertController(title: "", message: "Are you sure you want to delete this message?", preferredStyle: UIAlertControllerStyle.alert)
                    
                    
                    
                    alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: {  (action: UIAlertAction!) in
                        // we do nothing
                        return
                    }))
                    
                    alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: {  (action: UIAlertAction!) in
                        // we take the current messages and append the new message
                        
                        // first we delete the message from the array
                        EventPageTableViewController.messages.remove(at: length - indexPath.row)
                        
                        // and then we update the data in the database
                        Data.ref.child("Events").child(EventPageTableViewController.event).updateChildValues(["Messages" : EventPageTableViewController.messages])
                        return
                    }))
                    
                    
                    self.present(alert, animated: true, completion: nil)
                    
                })
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
                    (alert: UIAlertAction!) -> Void in
                })
                
            
                optionMenu.addAction(editAction)
                optionMenu.addAction(cancelAction)
                optionMenu.addAction(deleteAction)
                
                self.present(optionMenu, animated: true, completion: nil)
            }
        }
    }
    
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        let section = indexPath.section
        let row = indexPath.row
        var shouldHighlight = false
        
        if(section == 1){
            let name = EventPageTableViewController.messages[row]["User"]
            if(Data.currentUser?.fullName == name){
                // then the row should be highlited (it is the current user who wrote it)
                shouldHighlight = true
            }
        }
        
        return shouldHighlight
        
    }
    
    
    
    @IBAction func SelectionIndexChanged(_ sender: Any) {
        let indexPath = IndexPath(row: 1, section: 0)
        let indexPath2 = IndexPath(row: 2, section: 0)
        let cell = EventTableView.cellForRow(at: indexPath) as! MyCustomCell2
        elementSelected = cell.Selection.selectedSegmentIndex
        EventTableView.reloadRows(at: [indexPath2], with: UITableViewRowAnimation.none)
        
        EventTableView.reloadData()
        
    }
    
    
    

    /*
    // Override to support conditional editing of the table view.
    
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

    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let svc = segue.destination as! DiscussionTableViewController
        if (segue.identifier == "EditMessage" && EventPageTableViewController.willEdit){
            let cell = EventTableView.cellForRow(at: indexPathToEdit!)
            svc.messageToEdit = cell?.detailTextLabel?.text
            // and we send the index at which we need to modify the text
            svc.index = indexPathToEdit?.row
        }
        
        
    }
 

}
