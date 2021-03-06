//
//  CreateEventPageViewController.swift
//  DKE
//
//  Created by Romain Boudet on 16/08/16.
//  Copyright © 2016 Romain Boudet. All rights reserved.
//

import UIKit
import Firebase

class CreateEventPageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    
    @IBOutlet weak var Open: UIBarButtonItem!
    @IBOutlet weak var tblPostData: UITableView!
    @IBOutlet var toolbarInputAccessoryView: UIToolbar!
    @IBOutlet weak var barItemPost: UIBarButtonItem!
    
    var accessToken = ""
  
    

    var indicator = UIActivityIndicatorView()

    
    
    
    // The string that contains the event description.
    // Its value is set every time the event description gets edited and its
    // value is displayed on the table view
    static var strEvent : String?
    static var strLocation : String?
    
    // The string that contains the date of the event.
    // This is the value that is displayed on the table view.
    static var startStrEventDate : String?
    static var endStrEventDate : String?
    
    // This string is composed right before posting the event on the calendar.
    // It's actually the quick-add string and contains the date data as well.
    static var strEventTextToPost : String?
    
    // The selected event date from the date picker.
    static var startDtEvent : Date?
    static var endDtEvent : Date?
    
    // The textfield that is appeared on the table view for editing the event description.
    static var txtEvent : UITextField?
    static var txtLocation : UITextField?
    
    // This flag indicates whether the event description is being edited or not.
    static var isEditingEvent = false
    static var isEditingLoc = false
    
    // It indicates whether the event is a full-day one.
    static var isFullDayEvent = false
    static var isEndFullDay = false
    
    
    // this variable will be used to distinguish the case of start date and end date
    var currentDatePicker = ""
    var currentEdit = ""
    
    let reminderArray = ["1 hour before the event", "3 hours before the event", "24 hours before the event", "No reminders"]
    static var currentReminder : String?
    static var whoToRemind : String?
    let whoToRemindArray = ["Finance", "Betterment", "Internal", "External", "Philanthropy", "Social", "House", "Rush", "Custom"]
    
    var toPass  : String?
    static var isReminderCustom = false
    static var tblPostData2 : UITableView?
    
    static var selectedUsers = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        CreateEventPageViewController.tblPostData2 = tblPostData
        
        if (self.revealViewController() != nil){
            
            Open.target = self.revealViewController()
            Open.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }

        
        tblPostData.delegate = self
        tblPostData.dataSource = self
        CreateEventPageViewController.isEditingEvent = false
        CreateEventPageViewController.isEditingLoc = false
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        acceptEditingEvent(self)
        return true
    }
    
    
    // these are the methods for when the user clicks on the buttons associated to the keyboard
    
    @IBAction func acceptEditingEvent(_ sender: AnyObject) {
        if(self.currentEdit == "event"){
            if(CreateEventPageViewController.strEvent != nil){
                CreateEventPageViewController.strEvent = nil
            }
            CreateEventPageViewController.strEvent = CreateEventPageViewController.txtEvent?.text
            CreateEventPageViewController.isEditingEvent = false
            CreateEventPageViewController.txtEvent?.resignFirstResponder()
            CreateEventPageViewController.txtEvent?.removeFromSuperview()
            CreateEventPageViewController.txtEvent = nil
            let indexPath = IndexPath(row: 0, section: 0)
            tblPostData.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        }
        else if(self.currentEdit == "location"){
            if(CreateEventPageViewController.strLocation != nil){
                CreateEventPageViewController.strLocation = nil
            }
            CreateEventPageViewController.strLocation = CreateEventPageViewController.txtLocation?.text
            CreateEventPageViewController.isEditingLoc = false
            CreateEventPageViewController.txtLocation?.resignFirstResponder()
            CreateEventPageViewController.txtLocation?.removeFromSuperview()
            CreateEventPageViewController.txtLocation = nil
            let indexPath = IndexPath(row: 0, section: 1)
            tblPostData.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        }
    }
    
    @IBAction func cancelEditingEvent(_ sender: AnyObject) {
        
        if(self.currentEdit == "event"){
            CreateEventPageViewController.isEditingEvent = false
            CreateEventPageViewController.txtEvent?.resignFirstResponder()
            CreateEventPageViewController.txtEvent?.removeFromSuperview()
            CreateEventPageViewController.txtEvent = nil
            let indexPath = IndexPath(row: 0, section: 0)
            tblPostData.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        }
        else if(self.currentEdit == "location"){
            CreateEventPageViewController.isEditingLoc = false
            
            CreateEventPageViewController.txtLocation?.resignFirstResponder()
            CreateEventPageViewController.txtLocation?.removeFromSuperview()
            CreateEventPageViewController.txtLocation = nil
            let indexPath = IndexPath(row: 0, section: 1)
            tblPostData.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        }
        
    }
    
    
    
    // all the table View delegate methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 0
        if(section == 0){
            rows = 1
        }
        else if(section == 1){
            rows = 1
        }
        else if(section == 2){
            rows = 2
        }
        else{
            if(CreateEventPageViewController.currentReminder == "No reminders"){
                rows = 1
            }
            else if(CreateEventPageViewController.isReminderCustom) {
                rows = 3
            }
            else {
                rows = 2
            }
        }
        return rows
    }
  
    
    // these are the footer titles for all the different sections of the table view
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        var footerTitle = ""
        if(section == 0){
            footerTitle = "Event short description"
        }
        else if (section == 1){
            footerTitle = "Location"
        }
        else if(section == 2){
            footerTitle = "Enter Dates"
        }
        else {
            footerTitle = "Reminder"
        }
        return footerTitle
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    // this method will return the content of the cell that we are currently filling out
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell?
        let section = (indexPath as NSIndexPath).section
        if (section == 3 && indexPath.row != 2){
            cell = self.tblPostData.dequeueReusableCell(withIdentifier: "ReminderCell")
        }
        else if(section == 3 && indexPath.row == 2){
            cell = self.tblPostData.dequeueReusableCell(withIdentifier: "CustomReminderCell")
        }
        else {
            cell = self.tblPostData.dequeueReusableCell(withIdentifier: "EventCell")
        }
       
        cell!.selectionStyle = UITableViewCellSelectionStyle.gray
        cell!.accessoryType = UITableViewCellAccessoryType.none
        cell!.textLabel?.font = UIFont(name: "Trebuchet MS", size: 11.0)
        
        
       
        
        if(section == 0 ){
            if(!CreateEventPageViewController.isEditingEvent){
                // If currently the event description is not being edited then just show
                // the value of the strEvent string and let the cell contain a disclosure indicator accessory view.
                cell!.textLabel!.text = CreateEventPageViewController.strEvent
                cell!.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                cell!.selectionStyle = UITableViewCellSelectionStyle.gray
                
            }
            else{
                // If the event description is being edited, then empty the textLabel text so as to avoid having text behind the textfield.
                    cell!.textLabel!.text = ""
                    cell!.contentView.addSubview(CreateEventPageViewController.txtEvent!)
                    cell!.accessoryType = UITableViewCellAccessoryType.none
            }
            
        }
        
        if(section == 1){
            if(!CreateEventPageViewController.isEditingLoc){
                // If currently the event description is not being edited then just show
                // the value of the strEvent string and let the cell contain a disclosure indicator accessory view.
                cell!.textLabel!.text = CreateEventPageViewController.strLocation
                cell!.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                cell!.selectionStyle = UITableViewCellSelectionStyle.gray
                
            }
            else{
                // If the event description is being edited, then empty the textLabel text so as to avoid having text behind the textfield.
                cell!.textLabel!.text = ""
                cell!.contentView.addSubview(CreateEventPageViewController.txtLocation!)
                cell!.accessoryType = UITableViewCellAccessoryType.none
            }
            
        }
        
        if(section == 2){
            if(indexPath.row == 0){
                
                if(CreateEventPageViewController.startStrEventDate == nil || CreateEventPageViewController.startStrEventDate == ""){
                    cell?.textLabel!.text = "Pick a start date ..."
                }
                else{
                    cell?.textLabel!.text = CreateEventPageViewController.startStrEventDate
                    cell?.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                }
            }
        
    
            if(indexPath.row == 1){
                if(CreateEventPageViewController.endStrEventDate == nil || CreateEventPageViewController.endStrEventDate == ""){
                    cell?.textLabel!.text = "Pick a end date ..."
                }
                else{
                    cell?.textLabel!.text = CreateEventPageViewController.endStrEventDate
                    cell?.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                }
            }
        }
        if(section == 3){
            if (indexPath.row == 0){
                if(CreateEventPageViewController.currentReminder == nil){
                    cell?.textLabel!.text = "Choose a form of reminder"
                }
                else{
                    cell?.textLabel!.text = CreateEventPageViewController.currentReminder
                }
            }
            else if (indexPath.row == 1){
                if( CreateEventPageViewController.whoToRemind == nil){
                    cell?.textLabel!.text = "Choose who to remind"
                }
                else{
                    cell?.textLabel!.text = CreateEventPageViewController.whoToRemind!
                }
            }
            
            else if (indexPath.row == 2){
                // if we reach this, then the user has selected a 'custom' reminder
                // we redirect the user to a list of all the current users, and he can select manually the ones he wants to remind
                if(CreateEventPageViewController.selectedUsers == nil){
                    cell?.textLabel!.text = "Select users to remind"

                }
                else {
                    
                    cell?.textLabel!.text = "\((CreateEventPageViewController.selectedUsers).count) users selected "
                }
            }
            cell?.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        }
        return cell!

    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let section = indexPath.section
        if (section == 3){
            if (indexPath.row == 0){
                self.toPass = "How"
            }
            else {
                self.toPass = "Who"
            }
        }
        return indexPath
        
    }
    
    // this method is called when the user taps on one of the cells
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(CreateEventPageViewController.isEditingLoc){
            // we do this in case the user was already editing, it saves what the user has already inputed
            CreateEventPageViewController.isEditingLoc = false
            if (CreateEventPageViewController.txtLocation?.text != ""){
                CreateEventPageViewController.strLocation = CreateEventPageViewController.txtLocation?.text
            }
            CreateEventPageViewController.txtLocation?.resignFirstResponder()
            CreateEventPageViewController.txtLocation?.removeFromSuperview()
            CreateEventPageViewController.txtLocation = nil
        }
        
        if(CreateEventPageViewController.isEditingEvent){
            // we do this in case the user was already editing, it saves what the user has already inputed
            CreateEventPageViewController.isEditingEvent = false
            if(CreateEventPageViewController.txtEvent?.text != ""){
                CreateEventPageViewController.strEvent = CreateEventPageViewController.txtEvent?.text
            }
            CreateEventPageViewController.txtEvent?.resignFirstResponder()
            CreateEventPageViewController.txtEvent?.removeFromSuperview()
            CreateEventPageViewController.txtEvent = nil
        }


        
        let cell = tblPostData.cellForRow(at: indexPath)
        cell?.setSelected(false, animated: false)
        let section = (indexPath as NSIndexPath).section
        if (section == 0){
            self.currentEdit = "event"
            if(!CreateEventPageViewController.isEditingEvent){
                setupEventTextfield()
            }
            else{
                return
            }

            CreateEventPageViewController.isEditingEvent = !CreateEventPageViewController.isEditingEvent
            if(CreateEventPageViewController.isEditingEvent){
                cell!.contentView.addSubview(CreateEventPageViewController.txtEvent!)
                CreateEventPageViewController.txtEvent?.becomeFirstResponder()
            }
        }
        
        if(section == 1){
            self.currentEdit = "location"
            
            if(!CreateEventPageViewController.isEditingLoc){
                setupLocationTextfield()
            }
            else{
                return
            }
            CreateEventPageViewController.isEditingLoc = !CreateEventPageViewController.isEditingLoc
            if(CreateEventPageViewController.isEditingLoc){
                cell!.contentView.addSubview(CreateEventPageViewController.txtLocation!)
                CreateEventPageViewController.txtLocation?.becomeFirstResponder()
            }
            
        }
        
        if(section == 2 ){
            if (indexPath.row == 0){
                self.currentDatePicker = "start"
                self.performSegue(withIdentifier: "EventToDatePicker", sender: nil)
            }
            else {
                if (CreateEventPageViewController.startDtEvent != nil){
                    self.currentDatePicker = "end"
                    self.performSegue(withIdentifier: "EventToDatePicker", sender: nil)
                }
            }
        }
        
        if(section == 3){
           /* if(CreateEventPageViewController.isReminderListExpanded){
                currentReminder = reminderArray[(indexPath as NSIndexPath).row]
            }
        
            CreateEventPageViewController.isReminderListExpanded = !CreateEventPageViewController.isReminderListExpanded
                
                
            let indexSet = IndexSet(integer: 4)
            tblPostData.reloadSections(indexSet, with: UITableViewRowAnimation.automatic)*/
        }
        let index = NSIndexSet(index: section)
        //self.tblPostData.reloadSections(index as IndexSet, with: UITableViewRowAnimation.none)
        
    }
    
    
    func setupEventTextfield(){
        if(CreateEventPageViewController.txtEvent == nil){
            CreateEventPageViewController.txtEvent = UITextField(frame: CGRect(x: 10.0, y: 10.0, width: tblPostData.cellForRow(at: IndexPath(row: 0, section: 0))!.frame.size.width - 20.0, height: 30.0))
            CreateEventPageViewController.txtEvent?.borderStyle = UITextBorderStyle.roundedRect
            CreateEventPageViewController.txtEvent!.text = CreateEventPageViewController.strEvent
            CreateEventPageViewController.txtEvent?.inputAccessoryView = toolbarInputAccessoryView
            CreateEventPageViewController.txtEvent?.delegate = self
            CreateEventPageViewController.txtEvent?.placeholder = "Enter the description of the event"
            
        }
    }
    
    func setupLocationTextfield(){
        if(CreateEventPageViewController.txtLocation == nil){
            CreateEventPageViewController.txtLocation = UITextField(frame: CGRect(x: 10.0, y: 10.0, width: tblPostData.cellForRow(at: IndexPath(row: 0, section: 0))!.frame.size.width - 20.0, height: 30.0))
            CreateEventPageViewController.txtLocation?.borderStyle = UITextBorderStyle.roundedRect
            CreateEventPageViewController.txtLocation!.text = CreateEventPageViewController.strLocation
            CreateEventPageViewController.txtLocation?.inputAccessoryView = toolbarInputAccessoryView
            CreateEventPageViewController.txtLocation?.delegate = self
            CreateEventPageViewController.txtLocation?.placeholder = "Enter the location of the event"
        }
    }
    
    
    
    func activityIndicator() {
        indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        indicator.center = self.view.center
        indicator.hidesWhenStopped = true
        self.view.addSubview(indicator)
    }
    
    
    
    
    
    // this method is called when the user posts an event to the calendar
    @IBAction func post(_ sender: AnyObject) {
        
        
        
        // warning messages in case the user has forgotten to fill out some information
        if(CreateEventPageViewController.strEvent == nil){
            
            let alert = UIAlertController(title: "", message: "Please enter an event description", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        else if (CreateEventPageViewController.startStrEventDate == nil || CreateEventPageViewController.endStrEventDate == nil ){
            let alert = UIAlertController(title: "", message: "Please enter a start and finish date for the event", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
            
        else if (CreateEventPageViewController.isFullDayEvent != CreateEventPageViewController.isEndFullDay){
            let alert = UIAlertController(title: "", message: "The start and finish dates are not the same format", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        else if (CreateEventPageViewController.currentReminder == nil){
            let alert = UIAlertController(title: "", message: "You have not specified the reminder format", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
            
            
        else{
            let eventTitle = CreateEventPageViewController.strEvent!
            let location = CreateEventPageViewController.strLocation!
            let name =  Data.currentUser?.fullName
            
            
            
            // first we want to make sure that there isnt a event with the same title already
            Data.ref.observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) -> Void in
                let data = snapshot.value as! [String : AnyObject]
                if (data["Events"] != nil){
                    // then we have a problem
                    if let event = data["Events"]![eventTitle]! {
                        // this means there is already an event with the same title
                        let alert = UIAlertController(title: "", message: "An Event with the same title is already present, please choose another one", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                    
                }
                // then depending if the user has selected a certain committee to remind, we need to fetch all the users of that committee

                if (!CreateEventPageViewController.isReminderCustom && CreateEventPageViewController.currentReminder! != "No reminders" && CreateEventPageViewController.currentReminder! != "All Actives"){
                    // this means the user selected a certain committee to remind
                    // then we want to go fectch the users from that specific committee
                    let committee = CreateEventPageViewController.currentReminder!
                    
                    if (data[committee] != nil){
                        CreateEventPageViewController.selectedUsers = ((data[committee])?["Members"] as! [String]?)!
                    }
                    else {
                         CreateEventPageViewController.selectedUsers = []
                    }
                    
                }
                if (CreateEventPageViewController.currentReminder! == "No reminders"){
                    CreateEventPageViewController.selectedUsers = []
                }
                
                
                var startDateString = ""
                var endDateString = ""
                
                let calendar = Calendar.current
                let startDateComponents = (calendar as NSCalendar).components([.day, .month, .year, .hour, .minute], from: CreateEventPageViewController.startDtEvent!)
                let endDateComponents = (calendar as NSCalendar).components([.day, .month, .year, .hour, .minute], from: CreateEventPageViewController.endDtEvent!)
                
                
                let eventDay = startDateComponents.day!
                let eventMonth = startDateComponents.month!
                var month = ""
                // the month is in integer form, so we transform it in a 3 letter representation of it
                switch(eventMonth){
                case 1 :
                    month = "Jan"
                    break
                case 2:
                    month = "Feb"
                    break
                case 3 :
                    month = "Mar"
                    break
                case 4:
                    month = "Apr"
                    break
                case 5 :
                    month = "May"
                    break
                case 6:
                    month = "Jun"
                    break
                case 7 :
                    month = "Jul"
                    break
                case 8:
                    month = "Aug"
                    break
                case 9 :
                    month = "Sep"
                    break
                case 10:
                    month = "Oct"
                    break
                case 11 :
                    month = "Nov"
                    break
                case 12:
                    month = "Dec"
                    break
                default :
                    break
                }
                
                if(CreateEventPageViewController.isFullDayEvent){
                    startDateString = "\(startDateComponents.year!)-\(startDateComponents.month!)-\(startDateComponents.day!)"
                    endDateString = "\(endDateComponents.year!)-\(endDateComponents.month!)-\(endDateComponents.day!)"
                }
                else {
                    startDateString = "\(startDateComponents.year!)-\(startDateComponents.month!)-\(startDateComponents.day!)T\(startDateComponents.hour!):\(startDateComponents.minute!)"
                    endDateString = "\(endDateComponents.year!)-\(endDateComponents.month!)-\(endDateComponents.day!)T\(endDateComponents.hour!):\(endDateComponents.minute!)"
                }
                
                
                Data.ref.child("Events").child(eventTitle).updateChildValues(["eventTitle" :eventTitle, "startDate" : startDateString, "endDate": endDateString, "location" : location, "Creator" : name, "Reminder" : CreateEventPageViewController.currentReminder!,"usersToRemind" : CreateEventPageViewController.selectedUsers, "Day" : String(eventDay), "Month" : month])
                
                
                Data.ref.child("users").child(Data.userID!).observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) -> Void in
                    let data = snapshot.value as! [String : AnyObject]
                    var eventsCreated = [] as [String]
                    if(data["EventsCreated"] != nil){
                        eventsCreated = data["EventsCreated"] as! [String]
                        eventsCreated.append(eventTitle)
                    }
                    else {
                        eventsCreated = [eventTitle]
                    }
                    Data.ref.child("users").child(Data.userID!).updateChildValues(["EventsCreated" : eventsCreated])
                })
                
                self.finishedPost()
                
            
            })

        
        
        
        
        
//            var startDateString = ""
//            var endDateString = ""
//            let apiURLString = "https://www.googleapis.com/calendar/v3/calendars/\(CreateEventPageViewController.dictCurrentCalendar!["id"]!)/events?access_token=" + Data.accessToken
//            
//            let calendar = NSCalendar.currentCalendar()
//            let startDateComponents = calendar.components([.Day, .Month, .Year, .Hour, .Minute, .Second], fromDate: CreateEventPageViewController.startDtEvent!)
//            let endDateComponents = calendar.components([.Day, .Month, .Year, .Hour, .Minute, .Second], fromDate: CreateEventPageViewController.endDtEvent!)
//            
//            
//            if(CreateEventPageViewController.isFullDayEvent){
//                startDateString = "\(startDateComponents.year)-\(startDateComponents.month)-\(startDateComponents.day)"
//                endDateString = "\(endDateComponents.year)-\(endDateComponents.month)-\(endDateComponents.day)"
//            }
//            else {
//                startDateString = "\(startDateComponents.year)-\(startDateComponents.month)-\(startDateComponents.day)T\(startDateComponents.hour):\(startDateComponents.minute):\(startDateComponents.second)"
//                endDateString = "\(endDateComponents.year)-\(endDateComponents.month)-\(endDateComponents.day)T\(endDateComponents.hour):\(endDateComponents.minute):\(endDateComponents.second)"
//            }
//            
//            activityIndicator()
//            indicator.startAnimating()
//            
//            let localTimeZone = NSTimeZone.localTimeZone()
//            let timeZoneName = localTimeZone.name
//            
//            
//            let jsonEvent : [String : AnyObject] = [
//                "summary": CreateEventPageViewController.strEvent!,
//                "location": CreateEventPageViewController.strLocation!,
//                "start": [
//                    "dateTime": startDateString,
//                    "timeZone": timeZoneName,
//                    
//                ],
//                "end": [
//                    "dateTime": endDateString,
//                    "timeZone": timeZoneName,
//                ],
//                "reminders": [
//                    "useDefault": false,
//                    "overrides": [
//                        ["method": "email", "minutes": 24 * 60],
//                        ["method": "popup", "minutes": 10],
//                    ],
//                ],
//                ]
//            
//            do{
//                let request = NSMutableURLRequest(URL: NSURL(string: apiURLString)!)
//                request.HTTPMethod = "POST"
//                let jsonData = try NSJSONSerialization.dataWithJSONObject(jsonEvent, options: NSJSONWritingOptions.PrettyPrinted)
//                
//                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//                request.setValue("application/json", forHTTPHeaderField: "Accept")
//                
//                request.HTTPBody = jsonData
//                let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
//                    if (error == nil){
//                        let banner = Banner(title: "Success", subtitle: "The event has been added", image: UIImage(named: "AppIcon"), backgroundColor: UIColor(red:48.00/255.0, green:174.0/255.0, blue:51.5/255.0, alpha:1.000))
//                        banner.dismissesOnTap = true
//                        banner.show(duration: 3.0)
//                        self.finishedPost()
//                    }
//                        
//                    else{
//                        print("there was an error")
//                        self.indicator.stopAnimating()
//                    }
//                }
//                task.resume()
//            }
//            catch{
//                print("something went wrong")
//            }
//            
            
        }
    }

    func finishedPost(){
        // we restore all the variables to all the original values
        CreateEventPageViewController.selectedUsers = []
        CreateEventPageViewController.isReminderCustom = false
        CreateEventPageViewController.startStrEventDate = ""
        CreateEventPageViewController.endStrEventDate = ""
        CreateEventPageViewController.strEvent = ""
        CreateEventPageViewController.strLocation = ""
        CreateEventPageViewController.whoToRemind = nil
        CreateEventPageViewController.currentReminder = nil
        SelectUsersTableViewController.selectedUsers = []
        CreateEventPageViewController.tblPostData2?.reloadData()
        
        self.performSegue(withIdentifier: "BackToWelcomePage", sender: nil)
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "EventToDatePicker") {
            DatePickerPageViewController.toPass = self.currentDatePicker
        }
        
        else if (segue.identifier == "BackToWelcomePage"){
            WelcomePageTableViewController.eventJustCreated = true
        }
        
       else if (segue.identifier == "ReminderSegue"){
            let svc = segue.destination as! ReminderSelectionTableViewController
            if( self.toPass == "Who"){
                if ( CreateEventPageViewController.whoToRemind != nil){
                    svc.compareWith = CreateEventPageViewController.whoToRemind!
                }
    
                svc.reminderArray = self.whoToRemindArray
            }
            else {
                if ( CreateEventPageViewController.currentReminder != nil){
                    svc.compareWith = CreateEventPageViewController.currentReminder!
                }
                svc.reminderArray = self.reminderArray
            }

        }
        else if( segue.identifier == "CreateEventToSelection"){
            if(CreateEventPageViewController.selectedUsers != nil){
                SelectUsersTableViewController.selectedUsers = CreateEventPageViewController.selectedUsers
            }
            else {
                SelectUsersTableViewController.selectedUsers = []
            }
        }
        
        
    }

}
