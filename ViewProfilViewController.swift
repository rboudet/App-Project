//
//  ViewProfilViewController.swift
//  DKE
//
//  Created by Romain Boudet on 03/08/16.
//  Copyright © 2016 Romain Boudet. All rights reserved.
//

import UIKit
import Firebase

class ViewProfilViewController: UIViewController {
    var toPass = ""
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var MajorLabel: UILabel!
    @IBOutlet weak var EmailLabel: UILabel!
    @IBOutlet weak var HobbyLabel: UILabel!
    @IBOutlet weak var InterestLabel: UILabel!
    var Hobbies : [String]?
    var Interests : [String]?
    var HobbyString = ""
    var InterestString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.EmailLabel.isHidden = true
        self.NameLabel.isHidden = true
        self.MajorLabel.isHidden = true
//        self.HobbiesLabel.hidden = true
//        self.InterestsLabel.hidden = true
        

        _ = Data.ref.child("users").child(toPass).observe(FIRDataEventType.value, with: { (snapshot) in
            let data = snapshot.value as! [String : AnyObject]
            
            self.EmailLabel.text = "Email : " + (data["email"] as? String)!
            self.NameLabel.text = "Name : " + ((data["firstName"]) as? String)! + " " + ((data["lastName"]) as? String)!
            
            if(data["major"] == nil){
                self.MajorLabel.text = "Major : Not provided"
            }
            else {
                self.MajorLabel.text = "Major : " + (data["major"] as? String)!
            }
            
            if(data["Interests"] != nil){
                self.Interests = data["Interests"] as? [String]
                
            }
            if(data["Hobbies"] != nil){
                self.Hobbies = data["Hobbies"] as? [String]
                
            }
            if ( self.Hobbies != nil){
                for i in 0...(self.Hobbies?.count)! - 1 {
                    self.HobbyString = self.HobbyString + "\n" + (self.Hobbies?[i])!
                }
            }
            
            
            if(self.Interests != nil){
                for i in 0...(self.Interests?.count)! - 1 {
                    self.InterestString = self.InterestString + "\n" + (self.Interests?[i])!
                }
            }
            
//            self.hobbiesTextView.bounds = self.view.bounds
//            self.hobbiesTextView.editable = false
//            self.hobbiesTextView.contentInset = UIEdgeInsets(top: 200, left: 100, bottom: 200, right: 100)
//            self.hobbiesTextView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
//            self.hobbiesTextView.text = self.HobbyString
//            self.view.addSubview(self.hobbiesTextView);
            
//            self.HobbyLabel.sizeToFit()
            self.HobbyLabel.text = self.HobbyString
//            self.InterestLabel.sizeToFit()
            self.InterestLabel.text = self.InterestString
            
            self.EmailLabel.sizeToFit()
            self.NameLabel.sizeToFit()
            self.MajorLabel.sizeToFit()
            
            self.EmailLabel.isHidden = false
            self.NameLabel.isHidden = false
            self.MajorLabel.isHidden = false
//            self.HobbiesLabel.hidden = false
//            self.InterestsLabel.hidden = false

        })
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
