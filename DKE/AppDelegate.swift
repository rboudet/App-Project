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
import GoogleAPIClient


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

    var window: UIWindow?
    var currentList = [] as [String]
    private let kKeychainItemName = "Google Calendar API"
    
    private let kClientID = "464162409429-k3kb5k3ldic0knqbt5ad8h3olfd67va6.apps.googleusercontent.com"

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        FIRApp.configure()
        
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().signInSilently()
        GIDSignIn.sharedInstance().scopes.append(kGTLAuthScopeCalendar)
        GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/userinfo.profile")
        FIRDatabase.database().persistenceEnabled = true

        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, options: [String: AnyObject]) -> Bool {
        return GIDSignIn.sharedInstance().handleURL(url,sourceApplication: options[UIApplicationOpenURLOptionsSourceApplicationKey] as? String, annotation: options[UIApplicationOpenURLOptionsAnnotationKey])
        
    }
    
    func application(application: UIApplication,openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        var options : [String: AnyObject] = [UIApplicationOpenURLOptionsSourceApplicationKey: sourceApplication!, UIApplicationOpenURLOptionsAnnotationKey: annotation]
        return GIDSignIn.sharedInstance().handleURL(url, sourceApplication: sourceApplication, annotation: annotation)
    }
    

    
    
    
    
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject],
                     fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // Print message ID.
        print("Message ID: \(userInfo["gcm.message_id"]!)")
        
        // Print full message.
        print("%@", userInfo)
    }
    
    
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError!) {
        LoginPageViewController.indicator.hidden = false
        LoginPageViewController.indicator.startAnimating()
        LoginPageViewController.indicator.backgroundColor = UIColor.whiteColor()
        
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
     
        let authentication = user.authentication
        let givenName = user.profile.givenName
        let familyName = user.profile.familyName
        let email = user.profile.email
        
        let photoUrl = user.profile.imageURLWithDimension(70)
        let photoData = NSData(contentsOfURL: photoUrl)
        // the encodedString is what will be stored in firebase (cannot store images)
        let photo = UIImage(data: photoData!)
        let encodedString = photoData?.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
        
        
        Data.currentUser = CurrentUser(Lastname: familyName!, Firstname: givenName!, email: email!, profilePic : photo! )
        Data.accessToken = authentication.accessToken
        Data.refreshToken = authentication.refreshToken
        Data.expires = authentication.accessTokenExpirationDate
        Data.googleUser = user
        
        let credential = FIRGoogleAuthProvider.credentialWithIDToken(authentication.idToken,accessToken: authentication.accessToken)
        
        FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
            Data.userID = FIRAuth.auth()?.currentUser?.uid
            if error != nil{
                print(error)
            }
            
            else {
                Data.ref.observeSingleEventOfType(FIRDataEventType.Value, withBlock: { (snapshot) in
                    let data = snapshot.value as! [String : AnyObject]
                    
                    print(data["list"])
                    if(data["list"] == nil){
                        let list = [Data.userID!]
                        Data.ref.updateChildValues(["list" : list])
                        Data.ref.child("users").child(Data.userID!).setValue(["firstName": givenName!, "lastName" : familyName!, "email": email!, "AccountType" : "Google", "ProfilePicture" : encodedString!, "uid": Data.userID!])
                        
                    }
                    else {
                        self.currentList = data["list"] as! [String]
                        if( !(self.currentList.contains(Data.userID!))){
                            self.currentList.append(Data.userID!)
                            print("current list : ")
                            print(self.currentList)
                            print(Data.userID!)
                            Data.ref.updateChildValues(["list" : self.currentList])
                            Data.ref.child("users").child(Data.userID!).setValue(["firstName": givenName!, "lastName" : familyName!, "email": email!, "AccountType" : "Google", "ProfilePicture" : encodedString!, "uid": Data.userID!])
                            
                        }
                        
                       
                    }
                })
            }
            
            
        }
        
    }
    
    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user:GIDGoogleUser!,
                withError error: NSError!) {
        print("user has disconnected")
        // Perform any operations when the user disconnects from app here.
        // ...
    }

    
    
    
  

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

