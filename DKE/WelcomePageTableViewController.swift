
//
//  WelcomePageTableViewController.swift
//  DKE
//
//  Created by Romain Boudet on 05/10/16.
//  Copyright © 2016 Romain Boudet. All rights reserved.
//

import UIKit
import Firebase
import BRYXBanner



class WelcomePageTableViewController: UITableViewController {

    
    static var toPass = ""
    var accessToken = ""
    var currentList = [] as [String]
    var eventString = ""
    
    var events = [[String : String ]]()
    let output = UITextView()
    var iterations = 0
    
    var todayEvent = [[String : String ]]()
    var thisWeek = [[String : String ]]()
    
    var eventsAttending = [String]()
    var eventsAttendingComplete = [[String : String ]]() // this will keep track of more precise information about the event
    
    
    var eventsCreated = [String]()
    var AllEvents = true
    var noEvents = false
    
    static var indicator = UIActivityIndicatorView()

    static var eventJustCreated = false
    static var isReady = false
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var EventTableView: UITableView!

    @IBOutlet weak var EventTypeButton: UIBarButtonItem!
    
    var DayLabel : UILabel?
    var MonthLabel : UILabel?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        EventTableView.tableFooterView = UIView()
        eventsAttendingComplete = [[String : String ]]()
        
        // we want to set up a waiting system to make sure that all the user's info has been loaded, and that the user cannot do anything while the information has not been retreived
        
        //print(Data.currentUser!)
        
        // if an event has just been created succesfully, a green banner displays
        if (WelcomePageTableViewController.eventJustCreated){
            let banner = Banner(title: "Success", subtitle: "The event has been added", image: UIImage(named: "AppIcon"), backgroundColor: UIColor(red:48.00/255.0, green:174.0/255.0, blue:51.5/255.0, alpha:1.000))
            banner.dismissesOnTap = true
            banner.show(duration: 3.0)
            WelcomePageTableViewController.eventJustCreated = false
        }
        
        
        _ = Data.currentUser
        
        
        EventTableView.tableFooterView = UIView()
        EventTableView.tableHeaderView = UIView()
        
        let navigationBar = self.navigationController?.navigationBar
        let frame = CGRect(x: (navigationBar?.frame.width)!/5, y: 0, width: (navigationBar?.frame.width)!/2, height: (navigationBar?.frame.height)!)
        let titleLabel = UILabel(frame: frame)
        titleLabel.text = "Upcoming Events"
        titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.font = UIFont(name: "Avenir", size: 14)
        navigationBar?.addSubview(titleLabel)
        navigationBar?.isTranslucent = true
        
        
        
        activityIndicator()
        WelcomePageTableViewController.indicator.startAnimating()
        
        // here we go fetch all the information about the users and store it in a dictionary, to be able to use it at different places in the app
        
        if(SearchPage.dict.count == 0){
            // we check if we have not already filled the data structure with the users
            
            Data.ref.child("users").observe(.childAdded, with: { (snapshot) -> Void in
                let data = snapshot.value as! [String : AnyObject]
                let firstName = data["firstName"] as! String
                let lastName = data["lastName"] as! String
                let name = firstName + " " + lastName
                let firstChar = firstName[firstName.startIndex]
                let firstLetter = String(firstChar).uppercased()
                let uid = data["uid"] as! String
                // we check if the user is already in the data structure
                
                let major : String?
                if (data["major"] == nil){
                    major = "Major not provided"
                }
                else{
                    major = data["major"] as? String
                }
                
                print(uid)
                
                SearchPage.dict.append(["firstLetter" : firstLetter, "uid": uid, "name" : name, "major" : major! , "EncodedString" : data["ProfilePicture"] as! String])
                
                SearchPage.dict = SearchPage.dict.sorted{($0["name"]!).localizedCompare($1["name"]!) == ComparisonResult.orderedAscending}
            
                if(!SearchPage.sections.contains(firstLetter)){
                    SearchPage.sections.append(firstLetter)
                    // we add in the sections array all the first letters of the names if they are not already in the array
                }
            })
        }

        
        
        // we store the events the current user is either attending or has created
        Data.ref.child("users").child(Data.userID!).observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
            let data = snapshot.value as! [String : AnyObject]
            if(data["EventsCreated"] != nil){
                self.eventsCreated = data["EventsCreated"] as! [String]
                
                print(self.eventsCreated)
            }
            if(data["Attending"] != nil){
                self.eventsAttending = data["Attending"] as! [String]
            }
            
        })
        
        
        // then we fetch all the events, and display them on the table view
        Data.ref.child("Events").observe(.childAdded, with: { (snapshot) -> Void in
            let data = snapshot.value as! [String : AnyObject]
            let eventTitle = data["eventTitle"] as! String
            let organisator = data["Creator"] as! String
            let eventMonth = data["Month"] as! String
            let RFC3339DateFormatter = DateFormatter()
            RFC3339DateFormatter.locale = Locale(identifier: "en_US_POSIX")
            RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
            RFC3339DateFormatter.timeZone = TimeZone.autoupdatingCurrent
            let endDateString = data["endDate"] as! String
            let endDate = RFC3339DateFormatter.date(from: endDateString)!
            let startDateString = data["startDate"] as! String
            let startDate = RFC3339DateFormatter.date(from: startDateString)!
            let tomorrow = Date().addingTimeInterval(24*60*60)
            let inAWeek = (Calendar.current as NSCalendar).date(byAdding: .day, value: 7, to: Date(), options: NSCalendar.Options())
            let today = Date()
            let calendar = Calendar.current

            let startDateComponents = (calendar as NSCalendar).components([.day, .month], from: startDate)
            let eventDay = startDateComponents.day!
            let month = startDateComponents.month!
            // we store the event title, the organisator, and the day and month of the start date to be able to put it on the cell
            
            let todayDateComponents = (calendar as NSCalendar).components([.day, .month], from: today)
            let todayDay = todayDateComponents.day!
            let todayMonth = todayDateComponents.month!
            
           
            if(endDate < today ){
                
                // the event is over, and should be removed from all the lists

                Data.ref.child("Events").child(eventTitle).removeValue()
                var newEventsCreated = [String]()
                var newAttendingEvents = [String]()
                if (self.eventsCreated.contains(eventTitle)){
                    for i in 0...self.eventsCreated.count-1{
                        if (self.eventsCreated[i] != eventTitle){
                            newEventsCreated.append(self.eventsCreated[i])
                        }
                    }
                }
                if( self.eventsAttending.contains(eventTitle)){
                    for i in 0...self.eventsAttending.count-1{
                        if (self.eventsAttending[i] != eventTitle){
                            newAttendingEvents.append(self.eventsAttending[i])
                        }
                    }

                }
                self.eventsAttending = newAttendingEvents
                self.eventsCreated = newEventsCreated
                // these two arrays are the same exept we took away the event that is over
                
                Data.ref.child("users").child(Data.userID!).updateChildValues(["Attending" : newAttendingEvents, "EventsCreated": newEventsCreated])
            }
            else if(todayDay == eventDay && todayMonth == month){
                self.todayEvent.append(["EventTitle" : eventTitle, "Organisator" : organisator, "Day" : String(eventDay), "Month" : eventMonth])
            }
            else if(todayDay < eventDay && eventDay < (todayDay + 7) && todayMonth == month ){
                self.thisWeek.append(["EventTitle" : eventTitle, "Organisator" : organisator, "Day" : String(eventDay), "Month" : eventMonth])
                
            }
            else {
                // add the event to 'other array'
            }
            
            self.EventTableView.reloadData()
            
        })
        
        WelcomePageTableViewController.indicator.stopAnimating()
        
        
        
        
        if (self.revealViewController() != nil){
            
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }

        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem() */
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        var sections : Int?
        if (self.AllEvents){
            if (todayEvent.count != 0 && thisWeek.count != 0){
                sections = 2
            }
            else {
                sections = 1
            }
        }
        else{
            if (eventsCreated.count != 0 && eventsAttending.count != 0){
                sections = 2
            }
            else {
                sections = 1
            }
        }
        return sections!
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        var rows = 0
        if (section == 0){
            if(AllEvents){
                if (todayEvent.count == 0 && thisWeek.count != 0){
                    rows = thisWeek.count
                    self.noEvents = false
                }
                else if(todayEvent.count == 0 && thisWeek.count == 0){
                    rows = 1
                    self.noEvents = true
                }
                else if (todayEvent.count != 0){
                    rows = todayEvent.count
                    self.noEvents = false
                }
            }
            else {
                // only the events regarding the user will be shown
                if (eventsCreated.count == 0 && eventsAttending.count != 0){
                    rows = eventsAttending.count
                    self.noEvents = false
                }
                else if( eventsCreated.count == 0 && eventsAttending.count == 0){
                    rows = 1
                    self.noEvents = true
                }
                else if(eventsCreated.count != 0){
                    rows = eventsCreated.count
                    self.noEvents = false
                }
            }
        }
        else {
            // if we are in section 2, then we display either the week events, or the events the user is attending (depending on the situation)
            if (AllEvents){
                rows = thisWeek.count
            }
            else{
                rows = eventsAttending.count
            }
            self.noEvents = false
        }
        return rows
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:MyCustomCell2
        
        if (self.noEvents){
            cell = EventTableView.dequeueReusableCell(withIdentifier: "NoEventCell") as! MyCustomCell2
        }
        else {
            cell = EventTableView.dequeueReusableCell(withIdentifier: "EventCell") as! MyCustomCell2
        }
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        cell.GoingButton.setImage(UIImage(), for: UIControlState())
        let section = (indexPath as NSIndexPath).section
        cell.OrganisatorLabel.isHidden = true
        cell.GoingButton.isHidden = false
        cell.GoingButton.setTitle("Attend", for: UIControlState())
        if (AllEvents){
            // if the user wants to display all the evnts, then we separate the different possibilies of diplay, depending on wheter there is events today or not. Then we check if the user is attending the event, if so we change the 'attend' button
            cell.OrganisatorLabel.isHidden = false
            if (section == 0){
                
                
                if (todayEvent.count == 0 && thisWeek.count != 0){
                    // there are no events today but there are some after
                    if (self.eventsAttending.contains(self.thisWeek[indexPath.row]["EventTitle"]!)){
                        self.eventsAttendingComplete.append(self.thisWeek[indexPath.row])
                        cell.GoingButton.setImage(UIImage(named: "Checkmark"), for: UIControlState())
                        cell.GoingButton.setTitle("", for: UIControlState())
                    }
                    cell.DayLabel?.text = self.thisWeek[indexPath.row]["Day"]
                    cell.MonthLabel?.text = self.thisWeek[indexPath.row]["Month"]
                    cell.EventTitleLabel.text = self.thisWeek[indexPath.row]["EventTitle"]
                    cell.OrganisatorLabel.text = self.thisWeek[indexPath.row]["Organisator"]

                }
                
                else if (todayEvent.count != 0){
                    // there are events today
                    if (self.eventsAttending.contains(self.todayEvent[indexPath.row]["EventTitle"]!)){
                        self.eventsAttendingComplete.append(self.todayEvent[indexPath.row])
                        cell.GoingButton.setImage(UIImage(named:"Checkmark"), for: UIControlState())
                        cell.GoingButton.setTitle("", for: UIControlState())
                    }
                    cell.DayLabel?.text = self.todayEvent[indexPath.row]["Day"]
                    cell.MonthLabel?.text = self.todayEvent[indexPath.row]["Month"]
                    cell.EventTitleLabel.text = self.todayEvent[indexPath.row]["EventTitle"]
                    cell.OrganisatorLabel.text = self.todayEvent[indexPath.row]["Organisator"]

                }
                
                else if(todayEvent.count == 0 && thisWeek.count == 0){
                    // no events at all
                    cell.EventTitleLabel.text = "No upcoming events"
                    cell.GoingButton.isHidden = true
                    cell.OrganisatorLabel.isHidden = true
                    cell.accessoryType = UITableViewCellAccessoryType.none
                }
            }
            else {
                if (self.eventsAttending.contains(thisWeek[(indexPath as NSIndexPath).row]["EventTitle"]!)){
                    self.eventsAttendingComplete.append(self.thisWeek[indexPath.row])
                    cell.GoingButton.setImage(UIImage(named: "Checkmark"), for: UIControlState())
                    cell.GoingButton.setTitle("", for: UIControlState())
                }
                cell.DayLabel?.text = self.thisWeek[indexPath.row]["Day"]
                cell.MonthLabel?.text = self.thisWeek[indexPath.row]["Month"]
                cell.EventTitleLabel.text = self.thisWeek[(indexPath as NSIndexPath).row]["EventTitle"]
                cell.OrganisatorLabel.text = self.thisWeek[(indexPath as NSIndexPath).row]["Organisator"]
                cell.GoingButton.tag = self.todayEvent.count + (indexPath as NSIndexPath).row
            }
        }
        else {
            
            cell.GoingButton.isHidden = true
            if (section == 0){
                // if the user has no events created but is attending events
                if (eventsCreated.count == 0 && eventsAttending.count != 0){
                    cell.OrganisatorLabel.isHidden = false
                    cell.EventTitleLabel.text = self.eventsAttendingComplete[indexPath.row]["EventTitle"]
                    cell.DayLabel.text = self.eventsAttendingComplete[indexPath.row]["Day"]
                    cell.MonthLabel.text = self.eventsAttendingComplete[indexPath.row]["Month"]
                    
                }
                else if(eventsCreated.count != 0){
                    cell.EventTitleLabel.text = self.eventsCreated[indexPath.row]
                }
                else if (eventsCreated.count == 0 && eventsAttending.count == 0){
                    cell.EventTitleLabel.text = "You are not attending any events"
                    cell.GoingButton.isHidden = true
                    cell.OrganisatorLabel.isHidden = true
                    cell.accessoryType = UITableViewCellAccessoryType.none
                }
            }
            else{
                cell.EventTitleLabel.text = self.eventsAttendingComplete[indexPath.row]["EventTitle"]
                cell.DayLabel.text = self.eventsAttendingComplete[indexPath.row]["Day"]
                cell.MonthLabel.text = self.eventsAttendingComplete[indexPath.row]["Month"]            }
        }
        
        
        return cell
    }
    
   override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 114.0
    }
    
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let cell = self.EventTableView.cellForRow(at: indexPath) as! MyCustomCell2
        WelcomePageTableViewController.toPass = cell.EventTitleLabel.text!
        cell.isSelected = false
        let navigationBar = self.navigationController?.navigationBar
        let subviews = navigationBar?.subviews
        if (cell.EventTitleLabel.text! != "No upcoming events" || cell.EventTitleLabel.text! != "You are not attending any events"){
            let label = subviews?[3] as! UILabel
            label.text = cell.EventTitleLabel.text!
        }
        return indexPath
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.EventTableView.deselectRow(at: indexPath, animated: false)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title = ""
        if (section == 0 ){
            if (AllEvents){
                if (todayEvent.count == 0 && thisWeek.count != 0){
                    title = "Events coming up this week"
                }
                else if (todayEvent.count != 0){
                    title = "Today's Events"
                }
            }
            else{
                if (eventsCreated.count == 0 && eventsAttending.count != 0){
                    title = "Events you are attending"
                }
                else if (eventsCreated.count != 0){
                    title = "Events you created"
                }

            }
            
        }
        else {
            if (AllEvents){
                title = "Events coming up this week"
            }
            else{
                title = "Events you are attending"
            }
           
        }
        return title
    }

    
    @IBAction func GoingButtonClicked(_ sender: AnyObject) {
        // the user taps on the button
        
        let buttonPosition = sender.convert(CGPoint.zero, to: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: buttonPosition)
        var attending : [String]?
        if indexPath != nil {
            let cell = self.EventTableView.cellForRow(at: indexPath!) as! MyCustomCell2
            let eventTitle = cell.EventTitleLabel.text
            
            if(cell.GoingButton.currentImage == UIImage(named: "Checkmark")){
                let optionMenu = UIAlertController(title: nil, message: "Do you want to leave this event?", preferredStyle: .actionSheet)
                let UnAttendAction = UIAlertAction(title: "Unattend Event", style: .default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    
                    // the user is already attending the event, we need to take away his id in the list of attending people
                    cell.GoingButton.setImage(UIImage(), for: UIControlState())
                    cell.GoingButton.setTitle("Attend", for: UIControlState())
                    
                    // we update the list of people that are attending this event
                    Data.ref.child("Events").child(eventTitle!).observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) -> Void in
                        let data = snapshot.value as! [String : AnyObject]
                        attending = data["Attending"] as? [String]
                        var newAttendingList = [] as [String]
                        for i in 0...attending!.count-1{
                            if (attending![i] != Data.userID!){
                                newAttendingList.append(attending![i])
                            }
                        }
                        Data.ref.child("Events").child(eventTitle!).updateChildValues(["Attending" : newAttendingList])
                        var index = -1
                        attending = [] as [String]
                        
                        // here we are looking for the index at which the event is in the attending events array so we can remove it
                        for i in 0...self.eventsAttending.count-1{
                            if (self.eventsAttending[i] != eventTitle){
                                attending!.append(self.eventsAttending[i])
                            }
                            
                            else {
                                index = i
                            }
                            
                            if (self.eventsAttendingComplete[i]["EventTitle"] == eventTitle!){
                                self.eventsAttendingComplete.remove(at: i)
                            }
                        }
                        
                        if(index != -1){
                            self.eventsAttending.remove(at: index)
                        }
                        Data.ref.child("users").child(Data.userID!).updateChildValues(["Attending" : attending!])
                       
                        self.EventTableView.rectForRow(at: indexPath!)

                    })
                })
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
                    (alert: UIAlertAction!) -> Void in
                })
                optionMenu.addAction(UnAttendAction)
                optionMenu.addAction(cancelAction)
                
                self.present(optionMenu, animated: true, completion: nil)
            }
            else{
                // the user is not attending the event and clicked on attend
                
                
                let optionMenu = UIAlertController(title: nil, message: "Do you want to attend this event?", preferredStyle: .actionSheet)
                let attendAction = UIAlertAction(title: "Attend Event", style: .default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    cell.GoingButton.setImage(UIImage(named: "Checkmark"), for: UIControlState())
                    cell.GoingButton.setTitle("", for: UIControlState())
                    
                    // we update the list of people that are attending this event
                    Data.ref.child("Events").child(eventTitle!).observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) -> Void in
                        let data = snapshot.value as! [String : AnyObject]
                        if(data["Attending"] != nil){
                            attending = data["Attending"] as? [String]
                            attending!.append(Data.userID!)
                        }
                        else {
                            attending = [Data.userID!]
                        }
                        Data.ref.child("Events").child(eventTitle!).updateChildValues(["Attending" : attending!])
                        self.EventTableView.rectForRow(at: indexPath!)
                    })
                    
                    Data.ref.child("users").child(Data.userID!).observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) -> Void in
                        let data = snapshot.value as! [String : AnyObject]
                        attending = [String]()
                        if(data["Attending"] != nil){
                            attending = data["Attending"] as? [String]
                            attending!.append(eventTitle!)
                        }
                        else{
                            attending = [eventTitle!]
                        }
                        Data.ref.child("users").child(Data.userID!).updateChildValues(["Attending" : attending!])
                        self.eventsAttending.append(eventTitle!)
                        self.EventTableView.rectForRow(at: indexPath!)
                    })
                    
                    // we add a new element to the attending dictionary, taking the info from the cell
                    self.eventsAttendingComplete.append(["EventTitle" : eventTitle!, "Organisator" : cell.OrganisatorLabel.text!, "Day" : cell.DayLabel.text!, "Month" : cell.MonthLabel.text!])
                    
                })
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
                    (alert: UIAlertAction!) -> Void in
                })
                optionMenu.addAction(attendAction)
                optionMenu.addAction(cancelAction)
                
                self.present(optionMenu, animated: true, completion: nil)
            }
        }
        
    }
    
    // when the user presses this button, we change the events that are shown. (from all events to the events that concern the user back and forth)
    @IBAction func EventsTypeButtonTapped(_ sender: AnyObject) {
        self.AllEvents = !self.AllEvents
        if(self.EventTypeButton.title == "My Events"){
            self.EventTypeButton.title = "All Events"
        }
        else {
            self.EventTypeButton.title = "My Events"
        }
        
        self.EventTableView.reloadData()
        
    }
    
    
    func activityIndicator() {
        WelcomePageTableViewController.indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        WelcomePageTableViewController.indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        WelcomePageTableViewController.indicator.center = self.view.center
       WelcomePageTableViewController.indicator.hidesWhenStopped = true
        self.view.addSubview(WelcomePageTableViewController.indicator)
        WelcomePageTableViewController.indicator.becomeFirstResponder()
    }
    
    
    
    
   

    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "EventToEventPage"){
           // let svc = segue.destination as! EventPageTableViewController;
           // svc.event = toPass
            self.navigationController?.navigationBar.isTranslucent = true            
        }
        
    }
    
    
    
    
  

}
