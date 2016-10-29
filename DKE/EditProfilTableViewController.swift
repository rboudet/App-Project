//
//  EditProfilTableViewController.swift
//  DKE
//
//  Created by Romain Boudet on 19/10/16.
//  Copyright © 2016 Romain Boudet. All rights reserved.
//

import UIKit
import Firebase

class EditProfilTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var toolBar: UIToolbar!
    
    @IBOutlet var EditProfileTableView: UITableView!
    var name : String?
    var email : String?
    var major : String?
    var address : String?
    var cities : String?
    var snapchat : String?
    
    var rowClicked : String?
    var imageHeight : CGFloat?
    var imageWidth : CGFloat?
    
    var isEditingCommittee = false
    // we keep track of the original committee of the user, and his new one.
    var committee : String?
    var originalCommittee : String?
    var currentProject : String?
    var committees = ["Finance", "Betterment", "Internal", "External", "Philanthropy", "Social", "House", "Rush", "No Committee"]
    let imagePicker = UIImagePickerController()
    var isChair : Bool?
    var isActive : Bool?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self

        // we first initilize all the variables to the current user's
        self.title = "Edit Profile"
        self.name = (Data.currentUser?.firstName)! + " " + (Data.currentUser?.lastName)!
        self.email = Data.currentUser?.email
        self.major = Data.currentUser?.major
        self.address = Data.currentUser?.Address
        self.cities = Data.currentUser?.Cities
        self.snapchat = Data.currentUser?.snapchat
        self.committee = Data.currentUser?.committee
        self.originalCommittee = Data.currentUser?.committee
        self.currentProject = Data.currentUser?.currentProject
        self.isChair = Data.currentUser?.isChair
        self.isActive = Data.currentUser?.isActive
        
        let width = EditProfileTableView.frame.width
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 140.0))
        
        // we add a header view, containing the user's profile picture and a button to edit the photo
        let imageView = UIImageView(frame: CGRect(x: width/2.0 - 40.0, y: 150/2.0 - 60.0, width: 90.0, height: 90.0))
        imageWidth = imageView.frame.width
        imageHeight = imageView.frame.height
        let but = UIButton(type: UIButtonType.roundedRect)
        
        but.frame = CGRect(x: width/2 - 60.0 , y: 150.0/2.0 + 20.0, width: 120.0, height: 50.0)
        but.setTitle("Edit Profile Picture", for: UIControlState.normal)
        but.addTarget(self, action: #selector(EditProfilTableViewController.ChangePhoto), for: .touchUpInside)
    
        headerView.addSubview(but)
        but.titleLabel?.font = UIFont(name: "Arial", size: 10.0)
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.layer.cornerRadius = imageView.frame.size.width/2
        imageView.clipsToBounds = true
        imageView.image = Data.currentUser?.profilePicture!
        imageView.contentMode = .scaleAspectFill
        headerView.addSubview(imageView)
        
        
        EditProfileTableView.tableHeaderView = headerView
        EditProfileTableView.tableFooterView = UIView()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
        // the first section will be the user's personal info, and the second tau alpha information
    }
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        var title = ""
        if (section == 0){
                
            title = "Personal Information"
        }
        if (section == 1){
            title = "Tau Alpha Information"
        }
            
        return title
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        var rows = 0
        if (section == 0){
            rows = 7
        }
        if (section == 1){
            if (isEditingCommittee){
                rows = 2 + self.committees.count
            }
            else {
                rows = 3
            }
        }
        
        return rows
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        var cell : UITableViewCell
        
        
        if((section == 0 && indexPath.row == 0) || (section == 1 && indexPath.row == 2 && !isEditingCommittee) || ( section == 1 && indexPath.row == self.committees.count + 1 && isEditingCommittee)){
            cell = EditProfileTableView.dequeueReusableCell(withIdentifier: "SwitchCell") as! SwitchTableViewCell
        }
        else {
            if (section == 1 && indexPath.row == 0){
                cell = EditProfileTableView.dequeueReusableCell(withIdentifier: "EditProfile2") as! MyCustomCell3!
            }
            else if (section == 1 && isEditingCommittee && indexPath.row < self.committees.count){
                cell = EditProfileTableView.dequeueReusableCell(withIdentifier: "EditProfile2") as! MyCustomCell3!
            }
            else{
                cell = EditProfileTableView.dequeueReusableCell(withIdentifier: "EditProfile") as! MyCustomCell3!
            }
            (cell as! MyCustomCell3).InputTextField.inputAccessoryView = self.toolBar
            (cell as! MyCustomCell3).Label?.font = UIFont(name: "Arial", size: 10.0)
            (cell as! MyCustomCell3).InputTextField.isHidden = false
            (cell as! MyCustomCell3).imageView?.isHidden = false
            (cell as! MyCustomCell3).Label.isHidden = false
        }
        if(section == 0){
            if(indexPath.row == 0){
                (cell as! SwitchTableViewCell).SwitchElement.isOn = isActive!
                (cell as! SwitchTableViewCell).Label.text = "Active :"
            }
            
            if (indexPath.row == 1 ){
                (cell as! MyCustomCell3).Label.text = "Name : "
                (cell as! MyCustomCell3).InputTextField.text = self.name!

                (cell as! MyCustomCell3).iconImage.image = UIImage(named: "User-50")
            }
            if (indexPath.row == 2 ){
                (cell as! MyCustomCell3).Label.text = "Email : "
                (cell as! MyCustomCell3).InputTextField.text = self.email!

            }
            if (indexPath.row == 3 ){
                (cell as! MyCustomCell3).Label.text = "Major : "
                (cell as! MyCustomCell3).InputTextField.text = self.major!

            }
            if (indexPath.row == 4 ){
                (cell as! MyCustomCell3).Label.text = "Address : "
                (cell as! MyCustomCell3).InputTextField.text = self.address!

            }
            if (indexPath.row == 4 ){
                (cell as! MyCustomCell3).Label.text = "Cities Lived in : "
                (cell as! MyCustomCell3).InputTextField.text = self.cities!

            }
            if (indexPath.row == 5 ){
                (cell as! MyCustomCell3).Label.text = "Snapchat : "
                (cell as! MyCustomCell3).InputTextField.text = self.snapchat!

            }
        }
        if (section == 1){
            if(!isEditingCommittee){
                if (indexPath.row == 0){
                    (cell as! MyCustomCell3).InputTextField.isHidden = true
                    (cell as! MyCustomCell3).imageView?.isHidden = true
                    
                    (cell as! MyCustomCell3).Label?.text = "Current Committee : "
                    (cell as! MyCustomCell3).CommitteeLabel?.text = self.committee!
                    (cell as! MyCustomCell3).accessoryType = UITableViewCellAccessoryType.none
                }
                if (indexPath.row == 1 ){
                    (cell as! MyCustomCell3).Label.text = "Current Project : "
                    (cell as! MyCustomCell3).InputTextField.text = self.currentProject!
                    (cell as! MyCustomCell3).InputTextField.inputAccessoryView = self.toolBar
                }
                if(indexPath.row == 2){
                    (cell as! SwitchTableViewCell).Label.text = "Chair of " + self.committee! + " :"
                    (cell as! SwitchTableViewCell).SwitchElement.isOn = self.isChair!
                }
            }
            else{
                if (indexPath.row < self.committees.count){
                    (cell as! MyCustomCell3).InputTextField.isHidden = true
                    (cell as! MyCustomCell3).imageView?.isHidden = true
                    (cell as! MyCustomCell3).Label?.isHidden = true
                    (cell as! MyCustomCell3).CommitteeLabel?.text = self.committees[indexPath.row]
                    if(self.committees[indexPath.row] == self.committee!){
                        cell.accessoryType = UITableViewCellAccessoryType.checkmark
                    }
                    else {
                        cell.accessoryType = UITableViewCellAccessoryType.none
                    }
                    
                }
                else if (indexPath.row == self.committees.count){
                    (cell as! MyCustomCell3).Label.text = "Current Project : "
                    (cell as! MyCustomCell3).InputTextField.text = self.currentProject!
                    (cell as! MyCustomCell3).InputTextField.inputAccessoryView = self.toolBar
                }
                else if ( indexPath.row == self.committees.count + 1){
                    (cell as! SwitchTableViewCell).Label.text = "Chair of " + self.committee! + " :"
                    (cell as! SwitchTableViewCell).SwitchElement.isOn = self.isChair!
                }
                
            }
        }
        
            
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        let cell = EditProfileTableView.cellForRow(at: indexPath) as! MyCustomCell3
        if (section == 1){
            if (isEditingCommittee){
                let newCommittee = cell.CommitteeLabel.text
                self.committee = newCommittee
                isEditingCommittee = !isEditingCommittee
                self.EditProfileTableView.reloadData()
            }
            else {
                isEditingCommittee = !isEditingCommittee
                self.EditProfileTableView.reloadData()
            }
           
        }
            
    }
    
   
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 35.0
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    @IBAction func cancelButtonTapped(_ sender: AnyObject) {
        view.endEditing(true)

    }
    
    
    
    
    @IBAction func DoneButtonTapped(_ sender: AnyObject) {
        
        var index : NSIndexPath?
        var index2 : NSIndexPath?
        var cell : MyCustomCell3?
        var cell2 : SwitchTableViewCell?
        var cellType : String?
        var newEmail : String?
        var newMajor : String?
        var newAddress : String?
        var newCities : String?
        var newSnapchat : String?
        var newData : String?
        for i in 1...6{
            index = NSIndexPath(row: i, section: 0)
            cell = EditProfileTableView.cellForRow(at: index! as IndexPath) as! MyCustomCell3?
            cellType = cell?.Label.text
            newData = cell?.InputTextField.text
            switch cellType! {
                // we record any changes being made by the user
            case ("Major : ") :
                newMajor = newData
                if (newMajor! != self.major!){
                    Data.ref.child("users").child(Data.userID!).updateChildValues(["major" : newMajor!])
                    Data.currentUser?.setMajor(newMajor!)
                }
                break
            case "Address : " :
                newAddress = newData
                if (newAddress! != self.address!){
                    Data.ref.child("users").child(Data.userID!).updateChildValues(["address" : newAddress!])
                    Data.currentUser?.setAddress(newAddress!)
                }
                break
            case("Cities Lived in : "):
                newCities = newData
                if(newCities! != self.cities!){
                    Data.ref.child("users").child(Data.userID!).updateChildValues(["cities" : newCities!])
                    Data.currentUser?.setCities(newCities!)
                }
                break
            case("Snapchat : "):
                newSnapchat = newData
                if (newSnapchat! != self.snapchat!){
                    Data.ref.child("users").child(Data.userID!).updateChildValues(["snapchat" : newSnapchat!])
                    Data.currentUser?.setSnapchat(newSnapchat!)
                }
                break
            case("Email : "):
                newEmail = newData
               // Data.ref.child("users").child(Data.userID!).updateChildValues(["major" : newMajor!])
                break
            default :
                break
            }
        }
        
        index = NSIndexPath(row: 0, section: 0)
        cell2 = EditProfileTableView.cellForRow(at: index as! IndexPath) as! SwitchTableViewCell?
        self.isActive = (cell2?.SwitchElement.isOn)!
        // we then update the committe and the current project.
        if (!isEditingCommittee){
            index = NSIndexPath(row:1, section: 1)
            index2 = NSIndexPath (row:2, section: 1)
        }
        else{
            index = NSIndexPath(row: 8, section: 1)
            index2 = NSIndexPath (row:9, section: 1)

        }
            
        cell = EditProfileTableView.cellForRow(at: index as! IndexPath) as! MyCustomCell3?
        // cell represents the project that the user is undertaking in his committee
        // cell2 represents the active switch cell
        cell2 = EditProfileTableView.cellForRow(at: index2 as! IndexPath) as! SwitchTableViewCell?
        self.isChair = (cell2?.SwitchElement.isOn)!
        let newProject = cell?.InputTextField.text
        // procced will represent the boolean that indicates if we save the data that the user has inputed
        
        if(self.isChair! && (self.isChair! != Data.currentUser?.isChair)){
            // if the user says he is the chair for the first time, we ask again to make sure he is
            let alert = UIAlertController(title: "Verification", message: "You said you are chair of the " + self.committee! + " committee. Do you wish to save this information?", preferredStyle: UIAlertControllerStyle.alert)
                
            alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: {  (action: UIAlertAction!) in
                // we do not update the user's information
                return
            }))
                
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: {  (action: UIAlertAction!) in
                Data.currentUser?.setCommittee(self.committee!)
                Data.currentUser?.setActive(self.isActive!)
                Data.currentUser?.setCurrentProject(newProject!)
                Data.currentUser?.setChair(self.isChair!)
                
                Data.ref.child("users").child(Data.userID!).updateChildValues(["Committee" : self.committee!, "CommitteeProject" : newProject!, "Active" : self.isActive!, "Chair" : self.isChair! ])
                Data.ref.child(self.committee!).updateChildValues(["Chair" : (Data.currentUser?.firstName)! + " " + (Data.currentUser?.lastName)!])
                
                
                self.performSegue(withIdentifier: "EditProfileToProfile", sender: nil)
            }))

            self.present(alert, animated: true, completion: nil)
                
        }
            
        // we update the new data to the user's information
        Data.currentUser?.setCommittee(self.committee!)
        Data.currentUser?.setActive(self.isActive!)
        Data.currentUser?.setCurrentProject(newProject!)
        Data.currentUser?.setChair(self.isChair!)
           
        Data.ref.child("users").child(Data.userID!).updateChildValues(["Committee" : self.committee!, "CommitteeProject" : newProject!, "Active" : self.isActive!, "Chair" : self.isChair! ])
        
        if(self.committee! != self.originalCommittee){
            // ie the user has either put his committee or changed his committee
            
            Data.ref.observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
                    let data = snapshot.value as! [String : AnyObject]
                    var currentUsers : [String]?
                    if (data[self.committee!] != nil){
                        
                        currentUsers = data[self.committee!]?["Members"] as? [String]
                        if(!((currentUsers?.contains(Data.userID!))!)){
                            currentUsers?.append(Data.userID!)
                        }
                    }
                    else {
                        currentUsers = [Data.userID!]
                    }
                
                    Data.ref.child(self.committee!).updateChildValues(["Members" : currentUsers!])
                
                    if (self.isChair!){
                         Data.ref.child(self.committee!).updateChildValues(["Chair" : Data.userID!])
                    }
                
            })
        }
        
        
        self.performSegue(withIdentifier: "EditProfileToProfile", sender: nil)
    }

    
    
    
     @IBAction func ReturnButtonTapped(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "EditProfileToProfile", sender: nil)

    }
    
    func ChangePhoto() {
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
        EditProfileTableView.reloadData()

        
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickerImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let subviews = EditProfileTableView.tableHeaderView?.subviews
            let imageView = subviews?[1] as! UIImageView
            imageView.contentMode = .scaleAspectFill

            let newImage = imageWithImage(pickerImage, scaledToSize: CGSize(width: imageWidth!, height: imageHeight!))
            imageView.image = newImage

            Data.currentUser?.setPhoto(newImage)
            let imageData = UIImagePNGRepresentation(newImage)!
            let encodedString = imageData.base64EncodedString(options: .lineLength64Characters)
            Data.ref.child("users").child(Data.userID!).updateChildValues(["ProfilePicture" : encodedString])
            Data.currentUser?.setEncodedString(encodedString)
            
            
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    // this function is to resize the images taken from the photo library
    func imageWithImage(_ image:UIImage, scaledToSize newSize:CGSize ) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage : UIImage  = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext();
        return newImage;
    }
    
    
    
    

}
