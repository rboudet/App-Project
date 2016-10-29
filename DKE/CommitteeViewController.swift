//
//  CommitteeViewController.swift
//  DKE
//
//  Created by Romain Boudet on 28/10/16.
//  Copyright © 2016 Romain Boudet. All rights reserved.
//

import UIKit
import Firebase


class CommitteeViewController: UIViewController {

    @IBOutlet weak var Open: UIBarButtonItem!
    @IBOutlet weak var memberLabel : UILabel!
    
    static var toPass : String?
    var committee : String?
    var chair : String?
    var members = [""] 
    var currentMembers : String = " "
    var membersLabel : UILabel?
    var chairLabel : UILabel?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        membersLabel = UILabel(frame: CGRect(x: 10.0, y: 100.0, width: 200.0, height: 30.0))
        chairLabel = UILabel(frame: CGRect(x: 10.0, y: 150.0, width: 200.0, height: 30.0))
        membersLabel?.font = UIFont(name: "Arial", size: 9.0)
        chairLabel?.font = UIFont(name: "Arial", size: 9.0)
        membersLabel?.numberOfLines = 0
        chairLabel?.numberOfLines = 0
        self.view.addSubview(membersLabel!)
        self.view.addSubview(chairLabel!)
        
        self.committee = CommitteeViewController.toPass!
        self.title = CommitteeViewController.toPass!
        
        if (self.revealViewController() != nil){
            Open.target = self.revealViewController()
            Open.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        Data.ref.observe(FIRDataEventType.value, with: { (snapshot) in
            let data = snapshot.value as! [String : AnyObject]
            if (data[self.committee!] != nil){
                if (data[self.committee!]?["Chair"] != nil){
                    self.chair = data[self.committee!]?["Chair"] as? String
                    self.chairLabel?.text = self.chair
                }
                if (data[self.committee!]?["Members"] != nil){
                    self.members = data[self.committee!]?["Members"] as! [String]
                // we retreive all the members of the committee and go fetch their names in the database
                    for i in 0...self.members.count-1 {
                        Data.ref.child("users").child(self.members[i]).observe(FIRDataEventType.value, with: { (snapshot) in
                            if (snapshot.value != nil){
                                let data2 = snapshot.value as! [String : AnyObject]
                                let firstName = data2["firstName"] as! String
                                let lastName = data2["lastName"] as! String
                                self.currentMembers += " - " + firstName + " "  + lastName + "\r"
                                if (i == self.members.count-1){
                                    self.membersLabel?.text = "members : " + self.currentMembers
                                    
                                }
                            }
                        })
                    }
                }
            }
            else {
                self.membersLabel?.text = "No members registered in this committee "

            }
        })
        
        
       // Data.ref.child(

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
