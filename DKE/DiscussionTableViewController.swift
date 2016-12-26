//
//  DiscussionTableViewController.swift
//  DKE
//
//  Created by romain boudet on 2016-12-24.
//  Copyright © 2016 Romain Boudet. All rights reserved.
//

import UIKit
import Firebase

class DiscussionTableViewController: UITableViewController, UITextViewDelegate {

    @IBOutlet var DiscussionTableView: UITableView!
    
    var message = ""
    
    var Postbutton = UIBarButtonItem(title: "Post", style: .plain, target: self, action: #selector(PostButtonTapped))
    var saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(SaveButtonTapped))
    
    var button : UIBarButtonItem?
    
    var messageToEdit : String?
    var index : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        button = Postbutton
        button?.isEnabled = false
        
        // if messageToEdit is not nil, then we are here to edit a message, so we put the saveButton instead of the postButton
        if(messageToEdit != nil){
            button = saveButton
            button?.isEnabled = true

        }
        self.navigationItem.rightBarButtonItem  = button
        
        
        DiscussionTableView.tableFooterView = UIView()
        let navigationBar = self.navigationController?.navigationBar
        let label =  navigationBar?.subviews[2] as! UILabel
        label.text = EventPageTableViewController.event

        
        // to hide the keyboard when the user scrolls the tableView
        DiscussionTableView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.onDrag
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    
    func PostButtonTapped(){
        let event = EventPageTableViewController.event
        var messages = EventPageTableViewController.messages 
        
        
        let alert = UIAlertController(title: "Are you sure?", message: "Are you sure you want to post this message?", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: {  (action: UIAlertAction!) in
            // we do nothing
            return
        }))
        
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: {  (action: UIAlertAction!) in
            // we take the current messages and append the new message
            let name = (Data.currentUser?.firstName)! + " " + (Data.currentUser?.lastName)!
            
            messages.append(["Message" : self.message, "User" : name])
            Data.ref.child("Events").child(event).updateChildValues(["Messages" : messages])
            
            // then we go back to the previous view controller and reload the data so that the message appears 
            _ = self.navigationController?.popViewController(animated: true)
            
            return
        }))
        
        
        self.present(alert, animated: true, completion: nil)

        
    }
    
    func SaveButtonTapped(){
        
        // we modify the message in the message array 
        EventPageTableViewController.messages[index!]["Message"] = self.message
        // we update the value in the database
        Data.ref.child("Events").child(EventPageTableViewController.event).updateChildValues(["Messages" : EventPageTableViewController.messages])

        
        
        // then we go back to the previous view controller and reload the data so that the message appears
        self.messageToEdit = nil
        EventPageTableViewController.willEdit = false
        // and we set back the variables to what they were before
        
        _ = self.navigationController?.popViewController(animated: true)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = DiscussionTableView.dequeueReusableCell(withIdentifier: "DiscussionCell") as! MyCustomCell2
        cell.profilePicture.image = Data.currentUser?.profilePicture
        cell.EventTitleLabel.text = (Data.currentUser?.firstName)! + " " + (Data.currentUser?.lastName)!
        cell.DiscussionTextView.delegate = self
        
        if(messageToEdit != nil){
            cell.DiscussionTextView.text = messageToEdit!
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = DiscussionTableView.cellForRow(at: indexPath) as! MyCustomCell2
        cell.setSelected(false, animated: true)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 288.0
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if (textView.text == "Write Something ..."){
            // we do this to clear the text view when the user first starts editing it
            textView.text = ""
        }
       
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if(textView.text !=  "Write Something ..." && textView.text != ""){
            // if the user inputs some text, the post button becomes active
            self.button?.isEnabled = true
        }
        else {
            self.button?.isEnabled = false
        }
        
        // and we update the message variable to the new input
        self.message = textView.text
    }
    
    
    
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
