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
//import GoogleAPIClient


class LoginPageViewController: UIViewController, GIDSignInUIDelegate{
    
    static var indicator = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signInSilently()
        
        FIRAuth.auth()?.addStateDidChangeListener { auth, user in
            if(user != nil){
                self.performSegue(withIdentifier: "FirstSegue", sender: nil)
            }
        }

    }
    
        
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
        
    }
    
    
    
  /*  @IBAction func loginButtonTapped(_ sender: AnyObject) {
        self.buttonTapped = "emailLogin"
        let email = emailTextField.text
        let password = passwordTextField.text
        
        if(email != nil && password != nil) {
            FIRAuth.auth()?.signIn(withEmail: email!, password: password!) { (user, error) in
                if error != nil{
                    let alert = UIAlertController(title: "Error", message: "email or password is incorrect", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                }
                else {
                    Data.user = user
                    Data.userID = user?.uid
                    self.performSegue(withIdentifier: "LoginToTabMenu", sender: nil)
                }
            }
        }
        
    }*/
    
    
        
    
    func activityIndicator() {
        LoginPageViewController.indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
       LoginPageViewController.indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        LoginPageViewController.indicator.center = self.view.center
        self.view.addSubview(LoginPageViewController.indicator)
        LoginPageViewController.indicator.isHidden = true
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "LoginToTabMenu") {
            LoginPageViewController.indicator.stopAnimating()
            LoginPageViewController.indicator.hidesWhenStopped = true
            
        }
    }


    
    

}
