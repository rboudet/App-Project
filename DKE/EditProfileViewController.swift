//
//  EditProfileViewController.swift
//  DKE
//
//  Created by Romain Boudet on 02/08/16.
//  Copyright © 2016 Romain Boudet. All rights reserved.
//

import UIKit
import Firebase


class EditProfileViewController: UIViewController {
    @IBOutlet weak var NewMajorTextField: UITextField!
    
    @IBOutlet weak var SnapchatTextField: UITextField!
    @IBOutlet weak var CitiesTextField: UITextField!
    @IBOutlet weak var EmailLabel: UILabel!
    
    @IBOutlet weak var AdressTextField: UITextField!
    @IBOutlet weak var NameLabel: UILabel!
    
    @IBOutlet weak var errorLabel: UILabel!
    var isGoogleAccount = false
    var currentEmail = ""
                     
    let Faculties =  ["Science", "Managment", "Arts", "Dentistry", "Education", "Engineering", "Law", "Medecine", "School of Music", "Agriculture and Environmental Sciences", "Continuing Studies", "Graduate and Postdoctoral Studies", "Other"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.errorLabel.hidden = true
        
        _ = Data.ref.child("users").child(Data.userID!).observeEventType(FIRDataEventType.Value, withBlock: { (snapshot) in
            var data = snapshot.value as! [String : AnyObject]
            
    
            if(data["major"] == nil){
                self.NewMajorTextField.text = "Not provided"
            }
            else {
                self.NewMajorTextField.text = (data["major"] as! String)
            }
            
            
            self.EmailLabel.text = (data["email"] as? String)!
            self.currentEmail = data["email"] as! String
            self.NameLabel.text = ((data["firstName"]) as? String)! + " " + ((data["lastName"]) as? String)!
            
            if(data["AccountType"] != nil && data["AccountType"] as! String == "Google" ){
                self.isGoogleAccount = true
            }
        })
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }

    @IBAction func SaveProfileButtonTapped(sender: AnyObject) {
        
        let newEmail = EmailLabel.text
        let newMajor = NewMajorTextField.text
        let Adress = AdressTextField.text
        let cities = CitiesTextField.text
        let snapchat = SnapchatTextField.text
        if(newMajor != "" && newMajor != "Not provided"){
            if(!self.isGoogleAccount){
                Data.user?.updateEmail(newEmail!) { error in
                    if error != nil {
                        print(ErrorType)
                        let alert = UIAlertController(title: "Error", message: "could not update email", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                    else {
                        HomePageViewController.justEditedProfil = true
                        self.performSegueWithIdentifier("EditProfilToProfil", sender: nil)
                        Data.ref.child("users").child(Data.userID!).updateChildValues(["email" : newEmail!, "major" : newMajor!, "profileCompleted" : "true"])
                    }
                }
            }
            else{
                Data.ref.child("users").child(Data.userID!).updateChildValues(["major" : newMajor!, "profileCompleted" : "true"])
                if(newEmail! != self.currentEmail){
                    let alert = UIAlertController(title: "Warning", message: "You are logged in with gmail, you cannot change your email. The rest of your information has been updated", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.Default, handler: nil))
                    HomePageViewController.justEditedProfil = true
                    self.presentViewController(alert, animated: true, completion: goToProfil)

                }
                else{
                    HomePageViewController.justEditedProfil = true
                    self.performSegueWithIdentifier("EditProfilToProfil", sender: nil)
                }
                
                
            }
        }
        else{
            self.errorLabel.hidden = false
        }
    }
    
 
    
    func goToProfil(){
        self.performSegueWithIdentifier("EditProfilToProfil", sender: nil)
    }
    
    @IBAction func BackButtonTapped(sender: AnyObject) {
        
        goToProfil()
    }
    
}
