//
//  EditProfileViewController.swift
//  DKE
//
//  Created by Romain Boudet on 02/08/16.
//  Copyright © 2016 Romain Boudet. All rights reserved.
//

import UIKit
import Firebase
import BRYXBanner


class EditProfileViewController: UIViewController {
    @IBOutlet weak var NewMajorTextField: UITextField!
    
    @IBOutlet weak var SnapchatTextField: UITextField!
    @IBOutlet weak var CitiesTextField: UITextField!
    @IBOutlet weak var EmailLabel: UILabel!
    
    @IBOutlet weak var AdressTextField: UITextField!
    @IBOutlet weak var NameLabel: UILabel!
    
    var isGoogleAccount = false
    var currentEmail = ""
                     
    let Faculties =  ["Science", "Managment", "Arts", "Dentistry", "Education", "Engineering", "Law", "Medecine", "School of Music", "Agriculture and Environmental Sciences", "Continuing Studies", "Graduate and Postdoctoral Studies", "Other"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.EmailLabel.text = Data.currentUser?.email
        self.NameLabel.text = (Data.currentUser?.firstName)! + " " + (Data.currentUser?.lastName)!
        self.NewMajorTextField.text = Data.currentUser?.major
        self.AdressTextField.text = Data.currentUser?.Address
        self.CitiesTextField.text = Data.currentUser?.Cities
        self.SnapchatTextField.text = Data.currentUser?.snapchat

        
        
    /*    _ = Data.ref.child("users").child(Data.userID!).observeEventType(FIRDataEventType.Value, withBlock: { (snapshot) in
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
        }) */
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }

    @IBAction func SaveProfileButtonTapped(_ sender: AnyObject) {
        
        let newEmail = EmailLabel.text
        let newMajor = NewMajorTextField.text
        let Address = AdressTextField.text
        let cities = CitiesTextField.text
        var snapchat = SnapchatTextField.text
        if (snapchat == nil){
            snapchat = "Not Provided"
        }
        if(newMajor != "" && newMajor != "Not provided" && cities != "" && Address != ""){
            if(!self.isGoogleAccount){
                Data.user?.updateEmail(newEmail!) { error in
                    if error != nil {
                    }
                    else {
                        HomePageViewController.justEditedProfil = true
                        self.performSegue(withIdentifier: "EditProfilToProfil", sender: nil)
                        Data.ref.child("users").child(Data.userID!).updateChildValues(["email" : newEmail!, "major" : newMajor!, "profileCompleted" : "true", "address" : Address!, "cities" : cities!, "snapchat" : snapchat!])
                        Data.currentUser?.setCities(cities!)
                        Data.currentUser?.setAddress(Address!)
                        Data.currentUser?.setMajor(newMajor!)
                        Data.currentUser?.setSnapchat(snapchat!)
                        
                    }
                }
            }
            else{
                Data.ref.child("users").child(Data.userID!).updateChildValues(["major" : newMajor!, "profileCompleted" : "true", "address" : Address!, "cities" : cities!, "snapchat" : snapchat!])
                
                Data.currentUser?.setCities(cities!)
                Data.currentUser?.setAddress(Address!)
                Data.currentUser?.setMajor(newMajor!)
                
                if(newEmail! != self.currentEmail){
                    let alert = UIAlertController(title: "Warning", message: "You are logged in with gmail, you cannot change your email. The rest of your information has been updated", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.default, handler: nil))
                    HomePageViewController.justEditedProfil = true
                    self.present(alert, animated: true, completion: goToProfil)

                }
                else{
                    HomePageViewController.justEditedProfil = true
                    self.performSegue(withIdentifier: "EditProfilToProfil", sender: nil)
                }
                
                
            }
        }
        else{
            let banner = Banner(title: "Error", subtitle: "Some mandatory fields were left empty", image: UIImage(named: "AppIcon"), backgroundColor: UIColor(red:174.00/255.0, green:48.0/255.0, blue:51.5/255.0, alpha:1.000))
            banner.dismissesOnTap = true
            banner.show(duration: 3.0)
        }
    }
    
 
    
    func goToProfil(){
        self.performSegue(withIdentifier: "EditProfilToProfil", sender: nil)
    }
    
    @IBAction func BackButtonTapped(_ sender: AnyObject) {
        
        goToProfil()
    }
    
}
