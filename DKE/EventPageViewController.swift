//
//  EventPageViewController.swift
//  DKE
//
//  Created by Romain Boudet on 03/10/16.
//  Copyright © 2016 Romain Boudet. All rights reserved.
//

import UIKit
import Firebase

class EventPageViewController: UIViewController {

    
    var event = ""
    
    
    @IBOutlet weak var UsersAttendingLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
     @IBOutlet weak var LocationLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        Data.ref.child("Events").child(event).observe(FIRDataEventType.value, with: { (snapshot) in
            if (snapshot.value != nil){
                let data = snapshot.value as! [String : AnyObject]
                let startDateString =  data["startDate"] as? String
                let endDateString = data["endDate"] as? String
                let location = data["location"] as? String
                let startDateComponents = startDateString?.components(separatedBy: "T")
                let actualStartDate = startDateComponents![0]
                let startTime = startDateComponents![1]
                let endDateComponents = endDateString?.components(separatedBy: "T")
                let actualEndDate =  endDateComponents![0]
                let endTime =  endDateComponents![1]
                
                var users : [String]
                var attending = ""
                if (data["Attending"] != nil){
                    users = (data["Attending"] as! [String])
                    for i in 0...users.count-1 {
                        Data.ref.child("users").child(users[i]).observe(FIRDataEventType.value, with: { (snapshot) in
                            let data2 = snapshot.value as! [String : AnyObject]
                            let firstName = data2["firstName"] as! String
                            let lastName = data2["lastName"] as! String
                            attending += " - " + firstName + " "  + lastName + "\r"
                            if (i == users.count-1){
                                self.UsersAttendingLabel.text = "users attending : " + attending
                                
                            }
                        })
                    }
                }
                self.LocationLabel.text = "location of the event : " + location!
                self.startDateLabel.text = "Event start date : " + actualStartDate + " at " + startTime
                self.endDateLabel.text = "Event end date : " + actualEndDate + " at " + endTime
                
            }
            

            
            
            
        })
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    

}
