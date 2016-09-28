//
//  CreateEventPageViewController.swift
//  DKE
//
//  Created by Romain Boudet on 16/08/16.
//  Copyright © 2016 Romain Boudet. All rights reserved.
//

import UIKit
import GoogleSignIn
import GoogleAPIClient
import BRYXBanner

class CreateEventPageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, GIDSignInUIDelegate {

    
    @IBOutlet weak var Open: UIBarButtonItem!
    @IBOutlet weak var tblPostData: UITableView!
    @IBOutlet var toolbarInputAccessoryView: UIToolbar!
    @IBOutlet weak var barItemPost: UIBarButtonItem!
    
    
    private let kKeychainItemName = "Google Calendar API"
    private let kClientID = "464162409429-k3kb5k3ldic0knqbt5ad8h3olfd67va6.apps.googleusercontent.com"
    
    var accessToken = ""
    private let scopes = [kGTLAuthScopeCalendar, "https://www.googleapis.com/auth/userinfo.profile"]
    
    let service = GTLServiceCalendar()

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
    static var startDtEvent : NSDate?
    static var endDtEvent : NSDate?
    
    // The textfield that is appeared on the table view for editing the event description.
    static var txtEvent : UITextField?
    static var txtLocation : UITextField?
    
    // This array is one of the most important properties, as it contains
    // all the calendars as NSDictionary objects.
    static var arrGoogleCalendars : NSMutableArray?
    
    // This dictionary contains the currently selected calendar.
    // It's the one that appears on the table view when the calendar list
    // is collapsed.
    static var dictCurrentCalendar : NSDictionary?
    
    // A GoogleOAuth object that handles everything regarding the Google.
    static var googleOAuth : GIDGoogleUser?
    
    // This flag indicates whether the event description is being edited or not.
    static var isEditingEvent = false
    static var isEditingLoc = false
    
    // It indicates whether the event is a full-day one.
    static var isFullDayEvent = false
    static var isEndFullDay = false
    
    // It simply indicates whether the calendar list is expanded or not on the table view.
    static var isCalendarListExpanded = false
    
    // this variable will be used to distinguish the case of start date and end date
    var currentDatePicker = ""
    var currentEdit = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if (self.revealViewController() != nil){
            
            Open.target = self.revealViewController()
            Open.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }

        
        tblPostData.delegate = self
        tblPostData.dataSource = self
        CreateEventPageViewController.isEditingEvent = false
        CreateEventPageViewController.isEditingLoc = false
        CreateEventPageViewController.isCalendarListExpanded = false
        if(CreateEventPageViewController.arrGoogleCalendars != nil && CreateEventPageViewController.dictCurrentCalendar == nil){
            CreateEventPageViewController.dictCurrentCalendar = CreateEventPageViewController.arrGoogleCalendars![0] as? NSDictionary
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        acceptEditingEvent(self)
        return true
    }
    

    
    @IBAction func acceptEditingEvent(sender: AnyObject) {
        if(self.currentEdit == "event"){
            if(CreateEventPageViewController.strEvent != nil){
                CreateEventPageViewController.strEvent = nil
            }
            CreateEventPageViewController.strEvent = CreateEventPageViewController.txtEvent?.text
            CreateEventPageViewController.isEditingEvent = false
            CreateEventPageViewController.txtEvent?.resignFirstResponder()
            CreateEventPageViewController.txtEvent?.removeFromSuperview()
            CreateEventPageViewController.txtEvent = nil
            let indexPath = NSIndexPath(forRow: 0, inSection: 0)
            tblPostData.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
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
            let indexPath = NSIndexPath(forRow: 0, inSection: 1)
            tblPostData.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    @IBAction func cancelEditingEvent(sender: AnyObject) {
        
        if(self.currentEdit == "event"){
            CreateEventPageViewController.isEditingEvent = false
            CreateEventPageViewController.txtEvent?.resignFirstResponder()
            CreateEventPageViewController.txtEvent?.removeFromSuperview()
            CreateEventPageViewController.txtEvent = nil
            let indexPath = NSIndexPath(forRow: 0, inSection: 0)
            tblPostData.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
        else if(self.currentEdit == "location"){
            CreateEventPageViewController.isEditingLoc = false
            
            CreateEventPageViewController.txtLocation?.resignFirstResponder()
            CreateEventPageViewController.txtLocation?.removeFromSuperview()
            CreateEventPageViewController.txtLocation = nil
            let indexPath = NSIndexPath(forRow: 0, inSection: 1)
            tblPostData.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
        
    }
    
    
    
    // all the table View delegate methods
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section != 4){
            return 1
        }
        else{
            if(!CreateEventPageViewController.isCalendarListExpanded){
                return 1
            }
            else{
                return (CreateEventPageViewController.arrGoogleCalendars?.count)!
            }
        }
    }
  
    
    // these are the footer titles for all the different sections of the table view
    func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        var footerTitle = ""
        if(section == 0){
            footerTitle = "Event short description"
        }
        else if (section == 1){
            footerTitle = "Location"
        }
        else if(section == 2){
            footerTitle = "Start date"
        }
        else if(section == 3){
            footerTitle = "End date"
        }
        else {
            footerTitle = "Google Calendar"
        }
        return footerTitle
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }
    
    // this method will return the content of the cell that we are currently filling out
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let CellIdentifier = "Cell"
        var cell : UITableViewCell?
        let section = indexPath.section
        cell = self.tblPostData.dequeueReusableCellWithIdentifier(CellIdentifier)
        if(cell == nil){
            
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: CellIdentifier)
            cell!.selectionStyle = UITableViewCellSelectionStyle.Gray
            cell!.accessoryType = UITableViewCellAccessoryType.None
            cell!.textLabel?.font = UIFont(name: "Trebuchet MS", size: 15.0)
        }
        
        if(section == 0 ){
            if(!CreateEventPageViewController.isEditingEvent){
                // If currently the event description is not being edited then just show
                // the value of the strEvent string and let the cell contain a disclosure indicator accessory view.
                cell!.textLabel!.text = CreateEventPageViewController.strEvent
                cell!.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                cell!.selectionStyle = UITableViewCellSelectionStyle.Gray
                
            }
            else{
                // If the event description is being edited, then empty the textLabel text so as to avoid having text behind the textfield.
                    cell!.textLabel!.text = ""
                    cell!.contentView.addSubview(CreateEventPageViewController.txtEvent!)
                    cell!.accessoryType = UITableViewCellAccessoryType.None
            }
            
        }
        
        if(section == 1){
            if(!CreateEventPageViewController.isEditingLoc){
                // If currently the event description is not being edited then just show
                // the value of the strEvent string and let the cell contain a disclosure indicator accessory view.
                cell!.textLabel!.text = CreateEventPageViewController.strLocation
                cell!.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                cell!.selectionStyle = UITableViewCellSelectionStyle.Gray
                
            }
            else{
                // If the event description is being edited, then empty the textLabel text so as to avoid having text behind the textfield.
                cell!.textLabel!.text = ""
                cell!.contentView.addSubview(CreateEventPageViewController.txtLocation!)
                cell!.accessoryType = UITableViewCellAccessoryType.None
            }
            
        }
        
        if(section == 2){
            if(CreateEventPageViewController.startStrEventDate == nil || CreateEventPageViewController.startStrEventDate == ""){
                cell?.textLabel!.text = "Pick a Date ..."
            }
            else{
                cell?.textLabel!.text = CreateEventPageViewController.startStrEventDate
                cell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            }
        }
        
        if(section == 3){
            if(CreateEventPageViewController.endStrEventDate == nil || CreateEventPageViewController.endStrEventDate == ""){
                cell?.textLabel!.text = "Pick a Date ..."
            }
            else{
                cell?.textLabel!.text = CreateEventPageViewController.endStrEventDate
                cell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            }
        }
        
        if(section == 4){
            
            if(!CreateEventPageViewController.isCalendarListExpanded){
                // If the calendar list is not expanded and only the selected calendar is shown,
                // then if the arrGoogleCalendars array is nil or it doesn't have any contents at all prompt
                // the user to download them now.
                // Otherwise show the summary (title) of the selected calendar along with a disclosure indicator.
                
                if(CreateEventPageViewController.arrGoogleCalendars == nil){
                    cell?.textLabel!.text = "Download Calendars ..."
                }
                else{
                    cell?.textLabel!.text = CreateEventPageViewController.dictCurrentCalendar!["summary"] as? String
                }
                
                cell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            }
            else{
                // This is the case where all the calendars should be listed.
                // Note that each calendar is represented as a NSDictionary which is read from the
                // arrGoogleCalendars array.
                // If the calendar that is shown in the current cell is the already selected one,
                // then add the checkmark accessory type to the cell, otherwise set the accessory type to none.
                
                let tempDict = CreateEventPageViewController.arrGoogleCalendars![indexPath.row]
                cell?.textLabel!.text = tempDict["summary"] as? String
                
                if(tempDict.isEqual(CreateEventPageViewController.dictCurrentCalendar)){
                    cell?.accessoryType = UITableViewCellAccessoryType.Checkmark
                }
                else {
                    cell?.accessoryType = UITableViewCellAccessoryType.None
                }
                
            }
            
        }
        
        return cell!

    }
    
    
    
    
    // this method is called when the user taps on one of the cells
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
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


        
        let cell = tblPostData.cellForRowAtIndexPath(indexPath)
        cell?.setSelected(false, animated: false)
        let section = indexPath.section
        if (section == 0){
            self.currentEdit = "event"
            if(!CreateEventPageViewController.isEditingEvent){
                setupEventTextfield()
            }
            else{
                return
            }
            
            CreateEventPageViewController.isEditingEvent = !CreateEventPageViewController.isEditingEvent
            //tblPostData.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            tblPostData.reloadData()
            if(CreateEventPageViewController.isEditingEvent){
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
            //tblPostData.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            tblPostData.reloadData()

            if(CreateEventPageViewController.isEditingLoc){
                CreateEventPageViewController.txtLocation?.becomeFirstResponder()
            }
            
        }
        
        if(section == 2){
            self.currentDatePicker = "start"
            self.performSegueWithIdentifier("EventToDatePicker", sender: nil)
        }
        if(section == 3){
            if (CreateEventPageViewController.startDtEvent != nil){
                self.currentDatePicker = "end"
                self.performSegueWithIdentifier("EventToDatePicker", sender: nil)
            }
        }
        
        if(section == 4){
            if(CreateEventPageViewController.arrGoogleCalendars == nil ){
                self.indicator.startAnimating()
                activityIndicator()
            }
            else{
                // in this case the calendars are already loaded in the arrGoogleCalendar
                
                if(CreateEventPageViewController.isCalendarListExpanded){
                    CreateEventPageViewController.dictCurrentCalendar = nil
                    CreateEventPageViewController.dictCurrentCalendar = CreateEventPageViewController.arrGoogleCalendars![indexPath.row] as? NSDictionary
                }
        
                CreateEventPageViewController.isCalendarListExpanded = !CreateEventPageViewController.isCalendarListExpanded
                
                
                let indexSet = NSIndexSet(index: 4)
                tblPostData.reloadSections(indexSet, withRowAnimation: UITableViewRowAnimation.Automatic)
                
            }
            
        }
        
    }
    
    
    func setupEventTextfield(){
        if(CreateEventPageViewController.txtEvent == nil){
            CreateEventPageViewController.txtEvent = UITextField(frame: CGRect(x: 10.0, y: 10.0, width: tblPostData.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))!.frame.size.width - 20.0, height: 30.0))
            CreateEventPageViewController.txtEvent?.borderStyle = UITextBorderStyle.RoundedRect
            CreateEventPageViewController.txtEvent!.text = CreateEventPageViewController.strEvent
            CreateEventPageViewController.txtEvent?.inputAccessoryView = toolbarInputAccessoryView
            CreateEventPageViewController.txtEvent?.delegate = self
            CreateEventPageViewController.txtEvent?.placeholder = "Enter the description of the event"
            
        }
    }
    
    func setupLocationTextfield(){
        if(CreateEventPageViewController.txtLocation == nil){
            CreateEventPageViewController.txtLocation = UITextField(frame: CGRect(x: 10.0, y: 10.0, width: tblPostData.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))!.frame.size.width - 20.0, height: 30.0))
            CreateEventPageViewController.txtLocation?.borderStyle = UITextBorderStyle.RoundedRect
            CreateEventPageViewController.txtLocation!.text = CreateEventPageViewController.strLocation
            CreateEventPageViewController.txtLocation?.inputAccessoryView = toolbarInputAccessoryView
            CreateEventPageViewController.txtLocation?.delegate = self
            CreateEventPageViewController.txtLocation?.placeholder = "Enter the location of the event"
        }
    }
    
    
    
    func activityIndicator() {
        indicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 40, 40))
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        indicator.center = self.view.center
        indicator.hidesWhenStopped = true
        self.view.addSubview(indicator)
    }
    
    func displayAddEventResultWithTicker(ticket : GTLServiceTicket){
       let error = ticket.fetchError
        if(error != nil){
            print(error.localizedDescription)
        }
    }
    
    
    
    
    // this method is called when the user posts an event to the calendar
    @IBAction func post(sender: AnyObject) {
        
        if(CreateEventPageViewController.strEvent == nil){
            let alert = UIAlertController(title: "", message: "Please enter an event description", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        else if (CreateEventPageViewController.startStrEventDate == nil || CreateEventPageViewController.endStrEventDate == nil ){
            let alert = UIAlertController(title: "", message: "Please enter a start and finish date for the event", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        else if (CreateEventPageViewController.isFullDayEvent != CreateEventPageViewController.isEndFullDay){
            let alert = UIAlertController(title: "", message: "The start and finish dates are not the same format", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
            
        else{
            var startDateString = ""
            var endDateString = ""
            let apiURLString = "https://www.googleapis.com/calendar/v3/calendars/\(CreateEventPageViewController.dictCurrentCalendar!["id"]!)/events?access_token=" + Data.accessToken
            
            let calendar = NSCalendar.currentCalendar()
            let startDateComponents = calendar.components([.Day, .Month, .Year, .Hour, .Minute, .Second], fromDate: CreateEventPageViewController.startDtEvent!)
            let endDateComponents = calendar.components([.Day, .Month, .Year, .Hour, .Minute, .Second], fromDate: CreateEventPageViewController.endDtEvent!)
            
            
            if(CreateEventPageViewController.isFullDayEvent){
                startDateString = "\(startDateComponents.year)-\(startDateComponents.month)-\(startDateComponents.day)"
                endDateString = "\(endDateComponents.year)-\(endDateComponents.month)-\(endDateComponents.day)"
            }
            else {
                startDateString = "\(startDateComponents.year)-\(startDateComponents.month)-\(startDateComponents.day)T\(startDateComponents.hour):\(startDateComponents.minute):\(startDateComponents.second)"
                endDateString = "\(endDateComponents.year)-\(endDateComponents.month)-\(endDateComponents.day)T\(endDateComponents.hour):\(endDateComponents.minute):\(endDateComponents.second)"
            }
            
            activityIndicator()
            indicator.startAnimating()
            
            let localTimeZone = NSTimeZone.localTimeZone()
            let timeZoneName = localTimeZone.name
            
            
            let jsonEvent : [String : AnyObject] = [
                "summary": CreateEventPageViewController.strEvent!,
                "location": CreateEventPageViewController.strLocation!,
                "start": [
                    "dateTime": startDateString,
                    "timeZone": timeZoneName,
                    
                ],
                "end": [
                    "dateTime": endDateString,
                    "timeZone": timeZoneName,
                ],
                "reminders": [
                    "useDefault": false,
                    "overrides": [
                        ["method": "email", "minutes": 24 * 60],
                        ["method": "popup", "minutes": 10],
                    ],
                ],
                ]
            
            do{
                let request = NSMutableURLRequest(URL: NSURL(string: apiURLString)!)
                request.HTTPMethod = "POST"
                let jsonData = try NSJSONSerialization.dataWithJSONObject(jsonEvent, options: NSJSONWritingOptions.PrettyPrinted)
                
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue("application/json", forHTTPHeaderField: "Accept")
                
                request.HTTPBody = jsonData
                let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
                    if (error == nil){
                        let banner = Banner(title: "Success", subtitle: "The event has been added", image: UIImage(named: "AppIcon"), backgroundColor: UIColor(red:48.00/255.0, green:174.0/255.0, blue:51.5/255.0, alpha:1.000))
                        banner.dismissesOnTap = true
                        banner.show(duration: 3.0)
                        self.finishedPost()
                    }
                        
                    else{
                        print("there was an error")
                        self.indicator.stopAnimating()
                    }
                }
                task.resume()
            }
            catch{
                print("something went wrong")
            }
            
            
        }
        
        
        
    }
 
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "EventToDatePicker") {
            DatePickerPageViewController.toPass = self.currentDatePicker
        }
    }

    func finishedPost(){
        self.indicator.stopAnimating()
        CreateEventPageViewController.startStrEventDate = ""
        CreateEventPageViewController.endStrEventDate = ""
        CreateEventPageViewController.strEvent = ""
        CreateEventPageViewController.strLocation = ""
        tblPostData.reloadData()
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
