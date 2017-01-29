//
//  LoginPageViewController.swift
//  DKE
//
//  Created by Romain Boudet on 31/07/16.
//  Copyright © 2016 Romain Boudet. All rights reserved.
//

import UIKit
import Firebase
import SystemConfiguration
//import BRYXBanner




class LoginPageViewController: UIViewController{
    
    @IBOutlet weak var EmailTextField: UITextField!
    
    @IBOutlet weak var PasswordTextField: UITextField!
    
    
    var indicator = UIActivityIndicatorView()
    static var isReady = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

 
    }
    override func viewDidAppear(_ animated: Bool) {
       if (!LoginPageViewController.connectedToNetwork()){
      
          /*  let banner = Banner(title: "No Internet Connection", subtitle: "", image: UIImage(named: "AppIcon"), backgroundColor: UIColor(red:174.00/255.0, green:48.0/255.0, blue:51.5/255.0, alpha:1.000))
            banner.dismissesOnTap = true
            banner.show(duration: 10.0)
            
            return*/

        }
        else {
           FIRAuth.auth()?.addStateDidChangeListener { auth, user in
                if(user != nil){
                    
                    
                    // if the user is already logged in, we go straight in the app
                    self.activityIndicator()
                    self.indicator.startAnimating()
                    Data.user = user
                    Data.userID = user?.uid
                    self.loadInformation(ID: (user?.uid)!)
                  
                }
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
           /* let banner = Banner(title: "No internet Connection", subtitle: "", image: UIImage(named: "AppIcon"), backgroundColor: UIColor(red:174.00/255.0, green:48.0/255.0, blue:51.5/255.0, alpha:1.000))
            banner.dismissesOnTap = true
            banner.show(duration: 10.0)
            answer = false */
        }
        return answer
        
        
    }
    
    @IBAction func LogInButtonTapped(_ sender: Any) {
        let email = EmailTextField.text
        let password = PasswordTextField.text
        
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
                    self.activityIndicator()
                    self.indicator.startAnimating()
                    self.loadInformation(ID: Data.userID!)
                    
                }
            }
        }
        
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    
    func loadInformation(ID : String){
        
        Data.ref.child("users").child(ID).observe(FIRDataEventType.value, with: { (snapshot) in
            // we display the info that the user has already put on his profil
            let data = snapshot.value as! [String : AnyObject]
            let email = data["email"] as! String
            let firstName = data["firstName"] as! String
            let lastName = data["lastName"] as! String
            Data.setCurrentUser(firstName: firstName, lastName: lastName, email: email)
            
            if( data["ProfilePicture"] != nil){
                let photoString = data["ProfilePicture"] as! String
                Data.currentUser?.setEncodedString(photoString)
                let decodedData = Foundation.Data(base64Encoded: photoString, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
                let decodedImage = UIImage(data: decodedData!)
                            
                Data.currentUser?.setPhoto(decodedImage!)
                _ = Data.currentUser
                
            }
            else {
                
                let photo = #imageLiteral(resourceName: "User-50")
                let data = UIImagePNGRepresentation(photo)
                let encodedString = data?.base64EncodedString(options: .lineLength64Characters)
                Data.ref.child("users").child(Data.userID!).updateChildValues(["ProfilePicture" : encodedString!])
                Data.currentUser?.setEncodedString(encodedString!)
                Data.currentUser?.setPhoto(photo)
            }
            if(data["major"] != nil){
                Data.currentUser?.setMajor(data["major"] as! String)
            }
            
            if(data["cities"] != nil){
                Data.currentUser?.setCities(data["cities"] as! String)
            }
            if(data["address"] != nil){
                Data.currentUser?.setAddress(data["address"] as! String)
            }
            if(data["snapchat"] != nil){
                Data.currentUser?.setSnapchat(data["snapchat"] as! String)
            }
            if(data["Committee"] != nil){
                Data.currentUser?.setCommittee(data["Committee"] as! String)
            }
            if(data["CommitteeProject"] != nil){
                Data.currentUser?.setCurrentProject(data["CommitteeProject"] as! String)
            }
            if(data["Active"] != nil){
                Data.currentUser?.setActive(data["Active"] as! Bool)
            }
            if(data["Chair"] != nil){
                Data.currentUser?.setChair(data["Chair"] as! Bool)
            }
            Data.currentUser?.setUid(uid: Data.userID!)
           

            
            // here we ensure that the data has been retreived before we can display it
            HomePageViewController.isReady = true
            HomePageViewController.load()
            
           
           self.performSegue(withIdentifier: "FirstSegue", sender: nil)
     

        })

        
        
        
    }
    
    
   
    


    
    

}
