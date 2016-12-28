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
import SystemConfiguration
import BRYXBanner




class LoginPageViewController: UIViewController, GIDSignInUIDelegate{
    
    @IBOutlet weak var EmailTextField: UITextField!
    
    @IBOutlet weak var PasswordTextField: UITextField!
    
    
    var indicator = UIActivityIndicatorView()
    static var isReady = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signInSilently()
        
        
      /*  if (connectedToNetwork()){
        
            FIRAuth.auth()?.addStateDidChangeListener { auth, user in
                if(user != nil){
                    self.activityIndicator()
                    self.indicator.startAnimating()
                    // if the user is a googleUser, add here a check that will wait until the data is loaded from google, ie a while loop that terminates once the information is here, or when we have passed the limit time. (find a way to do that)
                    self.performSegue(withIdentifier: "FirstSegue", sender: nil)
                }
            }
        }*/
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (!LoginPageViewController.connectedToNetwork()){
      
            let banner = Banner(title: "No Internet Connection", subtitle: "", image: UIImage(named: "AppIcon"), backgroundColor: UIColor(red:174.00/255.0, green:48.0/255.0, blue:51.5/255.0, alpha:1.000))
            banner.dismissesOnTap = true
            banner.show(duration: 10.0)
            
            return

        }
            
        else {
            login()
        }

    }
    
    func login(){
        FIRAuth.auth()?.addStateDidChangeListener { auth, user in
            if(user != nil){
                self.activityIndicator()
                self.indicator.startAnimating()
                // if the user is a googleUser, add here a check that will wait until the data is loaded from google, ie a while loop that terminates once the information is here, or when we have passed the limit time. (find a way to do that)
                self.performSegue(withIdentifier: "FirstSegue", sender: nil)
            }
        }

    }
    // this method will return true if the user has aninternet connection
    static func connectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
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
        indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        indicator.center = self.view.center
        self.view.addSubview(indicator)
        indicator.isHidden = true
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
       
    }
    
    
    static func checkConnection() -> Bool{
        var answer = true
        if(!connectedToNetwork()){
            let banner = Banner(title: "No internet Connection", subtitle: "", image: UIImage(named: "AppIcon"), backgroundColor: UIColor(red:174.00/255.0, green:48.0/255.0, blue:51.5/255.0, alpha:1.000))
            banner.dismissesOnTap = true
            banner.show(duration: 10.0)
            answer = false
        }
        return answer
        
        
    }
    
    @IBAction func LogInButtonTapped(_ sender: Any) {
    }
    
    
   
    


    
    

}
