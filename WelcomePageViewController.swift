//
//  WelcomePageViewController.swift
//  DKE
//
//  Created by Romain Boudet on 05/08/16.
//  Copyright © 2016 Romain Boudet. All rights reserved.
//

import UIKit
import GoogleAPIClient
import Firebase
import GoogleSignIn


class WelcomePageViewController: UIViewController {
    
    var toPass = ""
    var accessToken = ""
    var currentList = [] as [String]
    var eventString = ""
    var isGoogleAccount = false

    
    let output = UITextView()
    var iterations = 0
    
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        output.frame = view.bounds
        output.editable = false
        output.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        output.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        
        view.addSubview(output);
        
        
     
        _ = Data.ref.child("users").child(Data.userID!).observeEventType(FIRDataEventType.Value, withBlock: { (snapshot) in
            let data = snapshot.value as! [String : AnyObject]
            
            Data.googleUser = GIDSignIn.sharedInstance().currentUser
            
            
            if(data["ProfilePicture"] != nil){
                Data.currentUser?.setEncodedString(data["ProfilePicture"] as! String)
                let dataDecoded = NSData(base64EncodedString: (data["ProfilePicture"] as! String), options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)!
                let photo = UIImage(data: dataDecoded)
                Data.currentUser?.setPhoto(photo!)
            }
        })
         
        
        
        
        if (self.revealViewController() != nil){
    
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    
    
    
    // When the view appears, ensure that the Google Calendar API service is authorized
    // and perform API calls
    override func viewDidAppear(animated: Bool) {
        
        if(CreateEventPageViewController.arrGoogleCalendars == nil){
                // this led to a bug, if we  change users, the new calendats would not load
            loadCalendars()
        }
    }
    
    // Construct a query and get a list of upcoming events from the user calendar
    func fetchEvents(calendarId : String) {
        
        
     /*   let maxEvents = 10
        
        let calendar = NSCalendar.currentCalendar()
        let startDateComponents = calendar.components([.Day, .Month, .Year, .Hour, .Minute, .Second], fromDate: NSDate())
        
        let startDateString = "\(startDateComponents.year)-\(startDateComponents.month)-\(startDateComponents.day)T\(startDateComponents.hour):\(startDateComponents.minute):\(startDateComponents.second)"
        print(startDateString)
        let localTimeZone = NSTimeZone.localTimeZone()
        let startTime = GTLDateTime(date: NSDate(), timeZone:localTimeZone)
        
        
        
        let urlString = "https://www.googleapis.com/calendar/v3/calendars/\(calendarId)/events?maxResults=10&timeMax=2016-09-28T10:00:00-04:00&timeMin=2016-09-26T10:00:00-04:00&access_token=" + Data.accessToken
        
        let url = NSURL(string : urlString)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "GET"
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
            
            if(error != nil){
                print(error)
                return
            }
            do{
                if let calendarInfoDict = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary{
                    for i in 0...calendarInfoDict.count - 1 {
                        print(calendarInfoDict[i])
                        print(calendarInfoDict[i]!["summary"])
                    }
                }
                
            } catch {
                print("there was an error")
            }
            
        }
        
        task.resume()
        
        */
        
        
        
        // this is the code to get the calendar list
        
    }
    
    func loadCalendars(){
        
        let urlString = "https://www.googleapis.com/calendar/v3/users/me/calendarList?access_token=" + Data.accessToken
        let url = NSURL(string : urlString)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "GET"
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
            if(error != nil){
                print(error)
                return
            }
            do{
                if let calendarInfoDict = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary{
                    
                    let calendarsInfo = calendarInfoDict["items"] as! NSArray
                    
                    if(CreateEventPageViewController.arrGoogleCalendars == nil){
                        CreateEventPageViewController.arrGoogleCalendars = []
                    }
                    
                    for i in 0...(calendarsInfo.count - 1){
                        
                        // we store each calendar in a temporary dictionary
                        let currentCalDict = calendarsInfo[i] as! NSDictionary
                        
                        let accessRole = currentCalDict["accessRole"] as! String
                        
                        
                        // we only keep the calendars where the user can actually add events
                        if(accessRole == "writer" || accessRole == "owner"){
                            // we create an array which contains the desired data
                            let values = [currentCalDict["id"]!,currentCalDict["summary"]!]
                            
                            self.fetchEvents(currentCalDict["id"] as! String)
                            // we create an array with keys regarding the values of the previous array
                            
                            let keys = ["id", "summary"]
                            
                            
                            
                            // then we add the key-value pais in a dictionary and then add this dictionary to the arrGooglCalendas array
                            
                            CreateEventPageViewController.arrGoogleCalendars?.addObject(NSMutableDictionary.init(objects: values, forKeys: keys))
                        }
                    }
                    
                    // then we set the first calendar to be the selected one
                    CreateEventPageViewController.dictCurrentCalendar = CreateEventPageViewController.arrGoogleCalendars![0] as? NSDictionary
                }
            } catch {
                print("there was an error")
            }
            
        }
        
        task.resume()
        

        
        
    }

    
    // Display the start dates and event summaries in the UITextView
    func displayResultWithTicket(ticket: GTLServiceTicket,finishedWithObject response : GTLCalendarEvents,error : NSError?) {
        
        iterations = iterations + 1
        if let error = error {
            showAlert("Error", message: error.localizedDescription)
            return
        }
        
        
        if let events = response.items() where !events.isEmpty {
            for event in events as! [GTLCalendarEvent] {
                let start : GTLDateTime! = event.start.dateTime ?? event.start.date
                let startString = NSDateFormatter.localizedStringFromDate(
                    start.date,
                    dateStyle: .ShortStyle,
                    timeStyle: .ShortStyle
                )
                eventString += "\(startString) - \(event.summary)\n"
            }
        }
        if(iterations == 6){
            if (eventString == ""){
                eventString = "No upcoming events found."
            }
            output.text = eventString
        }
    }
    
    // Handle completion of the authorization process, and update the Google Calendar API
    // with the new credentials.
   /* func viewController(vc : UIViewController,
                        finishedWithAuth authResult : GTMOAuth2Authentication, error : NSError?) {
        
        if let error = error {
            service.authorizer = nil
            showAlert("Authentication Error", message: error.localizedDescription)
            return
        }
        
        self.isGoogleAccount = true
        
        service.authorizer = authResult
        accessToken = authResult.accessToken
        Data.accessToken = accessToken
        Data.refreshToken = authResult.refreshToken
        Data.expires = authResult.expirationDate
        dismissViewControllerAnimated(true, completion: nil)
        
       do{
            let url = NSURL(string: "https://www.googleapis.com/oauth2/v1/userinfo?alt=json&access_token=" + accessToken)
            let data = NSData(contentsOfURL: url!)
            let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions())
            let email = (json as! NSDictionary)["email"] as! String
            let firstName = (json as! NSDictionary)["given_name"] as! String
            let lastName = (json as! NSDictionary)["family_name"] as! String
            
        }catch{
            print("Something went wrong")
        }
        
    } */
    
    // Helper for showing an alert
    func showAlert(title : String, message: String) {
       
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.Alert
        )
        let ok = UIAlertAction(
            title: "OK",
            style: UIAlertActionStyle.Default,
            handler: nil
        )
        alert.addAction(ok)
        presentViewController(alert, animated: true, completion: nil)
        
    } 
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
//    @IBAction func LogOutButtonTapped(sender: AnyObject) {
//        GIDSignIn.sharedInstance().disconnect()
//        try! FIRAuth.auth()!.signOut()
//        CreateEventPageViewController.arrGoogleCalendars = nil
//        self.performSegueWithIdentifier("HomeToLogin", sender: nil)
//        
//    }
    
    
    func goToLogin(){
        self.performSegueWithIdentifier("HomeToLogin", sender: nil)
    }
    
    
   
    
    
    
}
