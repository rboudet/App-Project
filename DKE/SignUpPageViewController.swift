//
//  SignUpPageViewController.swift
//  DKE
//
//  Created by Romain Boudet on 31/07/16.
//  Copyright © 2016 Romain Boudet. All rights reserved.
//


import UIKit
import Firebase


class SignUpPageViewController: UIViewController {
    
    var ref = FIRDatabase.database().reference()
    
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
  
    @IBOutlet weak var passwordTextField: UITextField!
   
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
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

    
    
    @IBAction func SignUpButtonTapped(sender: AnyObject) {
        
        let email = emailTextField.text
        let password = passwordTextField.text
        let firstName = firstNameTextField.text
        let lastName = lastNameTextField.text
        
        FIRAuth.auth()?.createUserWithEmail(email!, password: password!) { (user, error) in
            if (error == nil){
                self.ref.child("users").child(user!.uid).setValue(["firstName": firstName!, "lastName" : lastName!, "email": email!])
                self.ref.observeSingleEventOfType(FIRDataEventType.Value, withBlock: { (snapshot) in
                    let userID = FIRAuth.auth()?.currentUser?.uid
                    let data = snapshot.value as! [String : AnyObject]
                    if(data["list"] == nil){
                        let list = [userID!]
                        self.ref.updateChildValues(["list" : list])
                    }
                    else {
                        var currentList = data["list"] as! [String]
                        currentList.append(userID!)
                        self.ref.updateChildValues(["list" : currentList])
                    }
                    

                    })
               
                self.performSegueWithIdentifier("SignUpToTabMenu", sender: nil)

            }
            else {
                
                let alert = UIAlertController(title: "Error", message: "Your inputs are invalid, please enter valid information", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)

                
            }
        }
    }

    func goToHome(){
        let HomePage = self.storyboard?.instantiateViewControllerWithIdentifier("HomePageViewController") as! HomePageViewController
        let HomePageNav = UINavigationController(rootViewController: HomePage)
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.window?.rootViewController = HomePageNav
        
    }

}

