//
//  SignUpPageViewController.swift
//  DKE
//
//  Created by Romain Boudet on 31/07/16.
//  Copyright © 2016 Romain Boudet. All rights reserved.
//


import UIKit
import FirebaseAuth
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }

    
    
    @IBAction func SignUpButtonTapped(_ sender: AnyObject) {
        
        let email = emailTextField.text
        let password = passwordTextField.text
        let firstName = firstNameTextField.text
        let lastName = lastNameTextField.text
        
        FIRAuth.auth()?.createUser(withEmail: email!, password: password!) { (user, error) in
            if (error == nil){
                
                Data.userID = user?.uid
                Data.currentUser = CurrentUser(Lastname: lastName!, Firstname: firstName!, email: email!)
                Data.ref.child("users").child(Data.userID!).updateChildValues(["firstName": firstName!, "lastName" : lastName!, "email": email!, "uid": Data.userID!])
                
                Data.ref.child("users").child(Data.userID!).observe(FIRDataEventType.value, with: { (snapshot) in
                    // we display the info that the user has already put on his profil
                    let data = snapshot.value as! [String : AnyObject]
                    if( data["ProfilePicture"] != nil){
                        let photoString = data["ProfilePicture"] as! String
                        Data.currentUser?.setEncodedString(photoString)
                        let decodedData = Foundation.Data(base64Encoded: photoString, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
                        let decodedImage = UIImage(data: decodedData!)
                        Data.currentUser?.setPhoto(decodedImage!)
                        
                    }
                    else {
                       
                        // the encodedString is what will be stored in firebase (cannot store images)
                        let photo = #imageLiteral(resourceName: "User-50")
                        let photoData = UIImagePNGRepresentation(photo)
                        let encodedString = photoData?.base64EncodedString(options: .lineLength64Characters)
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
                    // here we ensure that the data has been retreived before we can display it
                    HomePageViewController.isReady = true
                    HomePageViewController.load()
                    self.performSegue(withIdentifier: "SignUpToWelcomePage", sender: nil)

                })

                
                
                
            }
                
                
                
            else {
                
                let alert = UIAlertController(title: "Error", message: "Your inputs are invalid, please enter valid information", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)

                
            }
        }
    }

    func goToHome(){
        let HomePage = self.storyboard?.instantiateViewController(withIdentifier: "HomePageViewController") as! HomePageViewController
        let HomePageNav = UINavigationController(rootViewController: HomePage)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = HomePageNav
        
    }

}

