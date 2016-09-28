//
//  LoginPageViewController.swift
//  DKE
//
//  Created by Romain Boudet on 31/07/16.
//  Copyright © 2016 Romain Boudet. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import GoogleAPIClient


class LoginPageViewController: UIViewController, GIDSignInUIDelegate{
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    private let kKeychainItemName = "Google Calendar API"
    
    private let kClientID = "464162409429-k3kb5k3ldic0knqbt5ad8h3olfd67va6.apps.googleusercontent.com"
    var accessToken = ""
    var currentList = [] as [String]
    
    static var isSignedIn = false
    
    private let service = GTLServiceCalendar()

    var userLoggedIn = false
    
    var buttonTapped = ""
    static var indicator = UIActivityIndicatorView()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        
        GIDSignIn.sharedInstance().uiDelegate = self
        
        FIRAuth.auth()?.addAuthStateDidChangeListener { auth, user in
            if(Data.googleUser != nil){
                self.performSegueWithIdentifier("FirstSegue", sender: nil)
            }
        }

    }
    
        
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
        
    }
    
    
    
    @IBAction func loginButtonTapped(sender: AnyObject) {
        self.buttonTapped = "emailLogin"
        let email = emailTextField.text
        let password = passwordTextField.text
        
        if(email != nil && password != nil) {
            FIRAuth.auth()?.signInWithEmail(email!, password: password!) { (user, error) in
                if error != nil{
                    let alert = UIAlertController(title: "Error", message: "email or password is incorrect", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                }
                else {
                    Data.user = user
                    Data.userID = user?.uid
                    self.performSegueWithIdentifier("LoginToTabMenu", sender: nil)
                }
            }
        }
        
    }
    
    
        
    
    func activityIndicator() {
        LoginPageViewController.indicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 40, 40))
       LoginPageViewController.indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        LoginPageViewController.indicator.center = self.view.center
        self.view.addSubview(LoginPageViewController.indicator)
        LoginPageViewController.indicator.hidden = true
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "LoginToTabMenu") {
            LoginPageViewController.indicator.stopAnimating()
            LoginPageViewController.indicator.hidesWhenStopped = true
            
        }
    }


    
    

}
