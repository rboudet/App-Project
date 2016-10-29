//
//  AppDelegate.swift
//  DKE
//
//  Created by Romain Boudet on 31/07/16.
//  Copyright © 2016 Romain Boudet. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

    var window: UIWindow?
    var currentList = [] as [String]
    fileprivate let kKeychainItemName = "Google Calendar API"
    
    fileprivate let kClientID = "464162409429-k3kb5k3ldic0knqbt5ad8h3olfd67va6.apps.googleusercontent.com"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        application.registerUserNotificationSettings(settings)
        
        FIRApp.configure()
        
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().signInSilently()
        GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/userinfo.profile")
        FIRDatabase.database().persistenceEnabled = true

        return true
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url,sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        
    }
    
    func application(_ application: UIApplication,open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        var options : [String: AnyObject] = [UIApplicationOpenURLOptionsKey.sourceApplication.rawValue: sourceApplication! as AnyObject, UIApplicationOpenURLOptionsKey.annotation.rawValue: annotation as AnyObject]
        return GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation)
    }
    

    
    
    
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // Print message ID.
        print("Message ID: \(userInfo["gcm.message_id"]!)")
        
        // Print full message.
        print("%@", userInfo)
    }
    
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        LoginPageViewController.indicator.isHidden = false
        LoginPageViewController.indicator.startAnimating()
        LoginPageViewController.indicator.backgroundColor = UIColor.white
        
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
     
        let authentication = user.authentication
        let givenName = user.profile.givenName
        let familyName = user.profile.familyName
        let email = user.profile.email
        Data.currentUser = CurrentUser(Lastname: familyName!, Firstname: givenName!, email: email!)
        Data.accessToken = (authentication?.accessToken)!
        Data.refreshToken = (authentication?.refreshToken)!
        Data.expires = authentication!.accessTokenExpirationDate
        Data.googleUser = user
        
        let credential = FIRGoogleAuthProvider.credential(withIDToken: (authentication?.idToken)!,accessToken: (authentication?.accessToken)!)
        
        FIRAuth.auth()?.signIn(with: credential) { (user, error) in
            Data.userID = FIRAuth.auth()?.currentUser?.uid
            if error != nil{
                print(error)
            }
            
            else {
                Data.ref.child("users").child(Data.userID!).updateChildValues(["firstName": givenName!, "lastName" : familyName!, "email": email!, "AccountType" : "Google", "uid": Data.userID!])
            }
            
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
                    let photoUrl = Data.googleUser!.profile.imageURL(withDimension: 70)
                    let photoData = try? Foundation.Data(contentsOf: photoUrl!)
                    // the encodedString is what will be stored in firebase (cannot store images)
                    let photo = UIImage(data: photoData!)
                    let encodedString = photoData?.base64EncodedString(options: .lineLength64Characters)
                    Data.ref.child("users").child(Data.userID!).updateChildValues(["ProfilePicture" : encodedString!])
                    
                    Data.currentUser?.setEncodedString(encodedString!)
                    Data.currentUser?.setPhoto(photo!)
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
            })
            
          }
        

        }
        
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user:GIDGoogleUser!,
                withError error: Error!) {
        print("user has disconnected")
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    
  
 /*    func tokenRefreshNotification(_ notification: Notification) {
        if let refreshedToken = FIRInstanceID.instanceID().token() {
            print("InstanceID token: \(refreshedToken)")
        }
        
        // Connect to FCM since connection may have failed when attempted before having a token.
        connectToFcm()
    }*/
 
    
    
    
    
    
    
  

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

