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
    
    @IBOutlet var EventTableView: UITableView!
    
    var event = WelcomePageTableViewController.toPass
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.EventTableView.contentInset = UIEdgeInsetsMake(44,0,0,0);
        self.navigationController?.navigationBar.isTranslucent = true
        
    
        
        let width = EventTableView.frame.width
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 140.0))
        let ImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: 140.0))
        ImageView.image = UIImage(named: "DKE_flag")
        //ImageView.contentMode = .scaleAspectFit
        ImageView.contentMode = .scaleToFill
        headerView.addSubview(ImageView)
 
        self.EventTableView.tableHeaderView = headerView
        self.EventTableView.tableFooterView = UIView()
    
        Data.ref.child("Events").child(event).observe(FIRDataEventType.value, with: { (snapshot) in
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
                
            }
        })
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        WelcomePageTableViewController.indicator.stopAnimating()
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
        var rows = 0
        if (self.isReady){
            rows = 1
        }
        return rows
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = EventTableView.dequeueReusableCell(withIdentifier: "EventCell") as! MyCustomCell2
        if (self.isReady){
            // we wait until the data has loaded then we output the cells
            let section = indexPath.section
            if(section == 0){
                if(indexPath.row == 0) {
                    cell.DayLabel.text = self.day!
                    cell.MonthLabel.text = self.month!
                    cell.EventTitleLabel.text = self.event
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
            }
        }


        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = EventTableView.cellForRow(at: indexPath)
        cell?.setSelected(false, animated: true)
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
