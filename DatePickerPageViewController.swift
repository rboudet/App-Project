//
//  DatePickerPageViewController.swift
//  DKE
//
//  Created by Romain Boudet on 16/08/16.
//  Copyright © 2016 Romain Boudet. All rights reserved.
//

import UIKit

class DatePickerPageViewController: UIViewController {

    static var toPass : String?
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var barItemToggleDatePicker: UIBarButtonItem!
    @IBOutlet weak var dpDatePicker: UIDatePicker!
    @IBOutlet var viewDatePicker: UIView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(DatePickerPageViewController.toPass == "end"){
            if(CreateEventPageViewController.isFullDayEvent){
                dpDatePicker.datePickerMode = UIDatePickerMode.date
            }
            else {
                dpDatePicker.datePickerMode = UIDatePickerMode.dateAndTime
            }
            dpDatePicker.date = CreateEventPageViewController.startDtEvent! as Date
             barItemToggleDatePicker.title = ""
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func acceptSelectedDate(_ sender: AnyObject) {
    
        if(DatePickerPageViewController.toPass == "start"){
            CreateEventPageViewController.startDtEvent = dpDatePicker.date
            // Also, convert it to a string properly formatted depending on whether the event is a full-day one or not
            // by calling the getStringFromDate: method.
        
            CreateEventPageViewController.startStrEventDate = getStringFromDate(dpDatePicker.date)
            // Remove the view with the date picker from the self.view.
            self.performSegue(withIdentifier: "DatePickerToEvent", sender: nil)
        }
        else if(DatePickerPageViewController.toPass == "end"){
             CreateEventPageViewController.endDtEvent = dpDatePicker.date
             CreateEventPageViewController.endStrEventDate = getStringFromDate(dpDatePicker.date)
             self.performSegue(withIdentifier: "DatePickerToEvent", sender: nil)
        }
        
    }
    
    
    @IBAction func cancelPickingDate(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "DatePickerToEvent", sender: nil)
    }

    @IBAction func toggleDatePicker(_ sender: AnyObject) {
        if (DatePickerPageViewController.toPass == "start"){
            if(dpDatePicker.datePickerMode == UIDatePickerMode.dateAndTime){
                // If the date picker currently shows both date and time, then set it to show only date and change the title of the barItemToggleDatePicker item. In this case the user selects to make a full-day event.
                dpDatePicker.datePickerMode = UIDatePickerMode.date
                barItemToggleDatePicker.title = "Specific time"
                CreateEventPageViewController.isFullDayEvent = true
            }
            else{
                // Otherwise, if only date is shown on the date picker, set it to show time too.
                // The event is no longer a full-day one.
                dpDatePicker.datePickerMode = UIDatePickerMode.dateAndTime
                barItemToggleDatePicker.title = "All-Day Event"
                CreateEventPageViewController.isFullDayEvent = false
            }
        }
    }
    
    func getStringFromDate(_ date : Date) -> String {
        let formatter = DateFormatter.init()
        
        if(!CreateEventPageViewController.isFullDayEvent){
            formatter.dateFormat = "EEE, MMM dd, yyy, HH:mm"
            if(DatePickerPageViewController.toPass == "end"){
                CreateEventPageViewController.isEndFullDay = false
            }
        }
        else{
            formatter.dateFormat = "EEE, MMM dd, yyyy"
            if(DatePickerPageViewController.toPass == "end"){
                CreateEventPageViewController.isEndFullDay = true
            }

        }
        return formatter.string(from: date)
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
