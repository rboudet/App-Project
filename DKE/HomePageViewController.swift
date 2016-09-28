//
//  HomePageViewController.swift
//  DKE
//
//  Created by Romain Boudet on 31/07/16.
//  Copyright © 2016 Romain Boudet. All rights reserved.
//

import UIKit
import Firebase
import BRYXBanner


class HomePageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
  
    @IBOutlet weak var Open: UIBarButtonItem!
    
    @IBOutlet weak var ProfilePicture: UIImageView!
    @IBOutlet var ToolBarElement: UIToolbar!

    @IBOutlet weak var InformationTableView: UITableView!
    
    @IBOutlet weak var majorLabel: UILabel!
    @IBOutlet weak var FacultyLabel: UILabel!
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var EmailLabel: UILabel!
    
    
    static var justEditedProfil : Bool?
    
    
    var hobbyTextField : UITextField?
    var interestTextField : UITextField?
    let imagePicker = UIImagePickerController()

    var indicator = UIActivityIndicatorView()
    
    var hobbiesShown = 3
    var interestsShown = 3
    var encodedString : String?

    
    
    // variables needed to display correctly the table view
    var indexInterest = 1
    var Interests = [] as [String]
    var Hobbies = [] as [String]
    var isEditingHobbies = false
    var isEditingInterests = false
    var hobbyTextFieldSetUp = false
    var InterestTextFieldSetUp = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (self.revealViewController() != nil){
            
            Open.target = self.revealViewController()
            Open.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        
        self.imagePicker.delegate = self
        InformationTableView.delegate = self
        InformationTableView.dataSource = self
        InformationTableView.backgroundColor = UIColor.whiteColor()
        InformationTableView.tableHeaderView = nil
        
        NameLabel.hidden = true
        EmailLabel.hidden = true
        FacultyLabel.hidden = true
        
        _ = Data.ref.child("users").child(Data.userID!).observeEventType(FIRDataEventType.Value, withBlock: { (snapshot) in
            // we display the info that the user has already put on his profil
            let data = snapshot.value as! [String : AnyObject]
            if(data["email"] != nil){
                self.EmailLabel.text = "Email : " + (data["email"] as? String)!
            }
            
            self.NameLabel.text = "Name : " + ((data["firstName"]) as? String)! + " " + ((data["lastName"]) as? String)!
            
            if(data["major"] == nil){
                self.majorLabel.text = "Major : Not provided"
            }
            else {
                self.majorLabel.text = "Major : " + (data["major"] as? String)!
            }
            
            if(data["faculty"] != nil){
                self.FacultyLabel.text = "Faculty : " + (data["faculty"] as? String)!
            }
            
            if(data["Hobbies"] != nil){
                self.Hobbies = data["Hobbies"] as! [String]
            }
            
            if(data["Interests"] != nil){
                self.Interests = data["Interests"] as! [String]
            }
            
            if(data["indexInterest"] != nil){
                self.indexInterest = data["indexInterest"] as! Int
            }
            
            self.InformationTableView.reloadData()
        })
        
        
        NameLabel.hidden = false
        EmailLabel.hidden = false
        FacultyLabel.hidden = false
        
        ProfilePicture.layer.borderWidth = 1
        ProfilePicture.layer.borderColor = UIColor.blackColor().CGColor
        ProfilePicture.layer.cornerRadius = ProfilePicture.frame.size.width/7
        ProfilePicture.clipsToBounds = true
        let width = ProfilePicture.frame.width
        let height = ProfilePicture.frame.height
        ProfilePicture.contentMode = .ScaleToFill
        let image = imageWithImage((Data.currentUser?.profilePicture)!, scaledToSize: CGSize(width: width - 30, height: height - 40))
        ProfilePicture.image = image
        
        
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if(HomePageViewController.justEditedProfil != nil && HomePageViewController.justEditedProfil!){
            let banner = Banner(title: "Profile Change Saved", subtitle: "", image: UIImage(named: "AppIcon"), backgroundColor: UIColor(red:48.00/255.0, green:174.0/255.0, blue:51.5/255.0, alpha:1.000))
            banner.dismissesOnTap = true
            banner.show(duration: 3.0)
            HomePageViewController.justEditedProfil = false
        }
        isEditingHobbies = false
        isEditingInterests = false
        hobbiesShown = 3
        interestsShown = 3
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    
    

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (2 + self.Hobbies.count + self.Interests.count)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 40.0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let CellIdentifier = "Cell"
        var cell : UITableViewCell?
        cell = self.InformationTableView.dequeueReusableCellWithIdentifier(CellIdentifier)
        if(cell == nil){
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: CellIdentifier)
            cell!.selectionStyle = UITableViewCellSelectionStyle.Gray
            cell!.accessoryType = UITableViewCellAccessoryType.None
        }
        cell!.textLabel?.font = UIFont(name: "Trebuchet MS", size: 10.0)

        
        if(indexPath.row == 0){
            // this means it is the 'add Hobby' cell
            if(isEditingHobbies){
                cell!.textLabel!.text = ""
                InformationTableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
                cell!.contentView.addSubview(hobbyTextField!)
                cell!.accessoryType = UITableViewCellAccessoryType.None
                
            }
            else{
                cell!.textLabel?.font = UIFont(name: "Trebuchet MS-bold", size: 10.0)
                cell!.textLabel?.text = "Add new Hobby    +"
            }
        }
        
        else if(indexPath.row == self.indexInterest){
            // this means it is the 'add Interest' cell
            if(isEditingInterests){
                InformationTableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
                cell!.textLabel!.text = ""
                cell!.contentView.addSubview(interestTextField!)
                cell!.accessoryType = UITableViewCellAccessoryType.None
            }
            else{
                cell!.textLabel?.font = UIFont(name: "Trebuchet MS-bold", size: 10.0)
                cell!.textLabel?.text = "Add new Interest   +"
            }
        }
        
        else if(indexPath.row < self.indexInterest){
            if( indexPath.row <= self.hobbiesShown){
            // this categorie of cells are the hobbies that the user has already put in
                cell!.textLabel?.text = self.Hobbies[self.Hobbies.count - indexPath.row]
            }
            else if (indexPath.row == self.hobbiesShown + 1){
                cell!.textLabel?.text = "Tap to see more"
            }
        }
        else{
            // these will be the interests of the user
            if (indexPath.row <= indexInterest + interestsShown){
                cell!.textLabel?.text = self.Interests[self.Interests.count - (indexPath.row - self.indexInterest)]
            }
            else if( indexPath.row == indexInterest + interestsShown + 1){
                cell!.textLabel?.text = "Tap to see more"
            }
            
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = InformationTableView.cellForRowAtIndexPath(indexPath)
        cell?.setSelected(false, animated: false)
        
        if(indexPath.row == 0){
            // the user has clicked on add new hobby, we want a textField to appear, let him input his hobby, and then save, and reload the tableView
            if(!isEditingHobbies){
                hobbyTextField = nil
                isEditingHobbies = !isEditingHobbies
                if(isEditingInterests){
                    isEditingInterests = false
                    interestTextField!.resignFirstResponder()
                    interestTextField!.removeFromSuperview()
                    interestTextField = nil
                }
                setUpHobbyTextField(indexPath)
            }
            else{
                return
            }
            InformationTableView.reloadData()
            hobbyTextField?.becomeFirstResponder()
        }
        else if(indexPath.row == indexInterest){
            // the user has clicked on add new hobby, we want a textField to appear, let him input his hobby, and then save, and reload the tableView
            if(!isEditingInterests){
                interestTextField = nil
                isEditingInterests = !isEditingInterests
                if (isEditingHobbies){
                    isEditingHobbies = false
                    hobbyTextField!.resignFirstResponder()
                    hobbyTextField!.removeFromSuperview()
                    hobbyTextField = nil
                }
                setUpInterestTextField(indexPath)
            }
            else{
                return
            }
            InformationTableView.reloadData()
            interestTextField?.becomeFirstResponder()
        }
        else if( indexPath.row == hobbiesShown + 1){
            hobbiesShown = hobbiesShown + 3
            InformationTableView.reloadData()
        }
        else if( indexPath.row == indexInterest + interestsShown + 1){
            interestsShown = interestsShown + 3
            InformationTableView.reloadData()
        }
            
        else if (indexPath.row < indexInterest) {
            cancelTextField()
            hobbiesShown = 3
            interestsShown = 3
            // the user as clicked on a hobby, an alert shows up asking if he wants to delete this hobby or not
            let alert = UIAlertController(title: "Deleting", message: "Are you sure you want to delete this Hobby?", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: {  (action: UIAlertAction!) in
                self.Hobbies.removeAtIndex(self.Hobbies.count - indexPath.row)
                self.indexInterest = self.indexInterest - 1
                self.InformationTableView.reloadData()
            }))
            alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            

        }
      
        else {
            cancelTextField()
            hobbiesShown = 3
            interestsShown = 3
            let alert = UIAlertController(title: "Deleting", message: "Are you sure you want to delete this Interest?", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: {  (action: UIAlertAction!) in
                self.Interests.removeAtIndex(self.Interests.count - (indexPath.row - self.indexInterest))
                self.InformationTableView.reloadData()
            }))
            
            alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)

        }
        
        Data.ref.child("users").child(Data.userID!).updateChildValues(["Hobbies" : self.Hobbies, "indexInterest" : self.indexInterest, "Interests" : self.Interests])


    }
    
    
    @IBAction func CancelButtonTapped(sender: AnyObject) {
        cancelTextField()
    }
    
    func cancelTextField () {
        if(isEditingInterests){
            isEditingInterests = false
            interestTextField!.resignFirstResponder()
            interestTextField!.removeFromSuperview()
            interestTextField = nil
            
        }
        if (isEditingHobbies){
            isEditingHobbies = false
            hobbyTextField!.resignFirstResponder()
            hobbyTextField!.removeFromSuperview()
            hobbyTextField = nil
            
        }
        InformationTableView.reloadData()
    }
    
    
    @IBAction func SaveButtonTapped(sender: AnyObject) {
        activityIndicator()
        indicator.startAnimating()
        var newElement = ""
        if(isEditingInterests){
            newElement = (interestTextField?.text)!
            if(newElement != ""){
                self.Interests.append(newElement)
                isEditingInterests = false
                interestTextField!.resignFirstResponder()
                interestTextField!.removeFromSuperview()
                interestTextField = nil
            }
        }
        else if(isEditingHobbies){
            newElement = (hobbyTextField?.text)!
            if(newElement != "" ){
                self.Hobbies.append(newElement)
                self.indexInterest = self.indexInterest + 1
                isEditingHobbies = false
                hobbyTextField!.resignFirstResponder()
                hobbyTextField!.removeFromSuperview()
                hobbyTextField = nil
            }
        }
        indicator.stopAnimating()
        InformationTableView.reloadData()
        Data.ref.child("users").child(Data.userID!).updateChildValues(["Hobbies" : self.Hobbies, "indexInterest" : self.indexInterest, "Interests" : self.Interests])
    }
    
    func activityIndicator() {
        indicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 40, 40))
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        indicator.center = self.view.center
        indicator.hidesWhenStopped = true
        self.view.addSubview(indicator)
    }
    
    func setUpHobbyTextField(indexPath : NSIndexPath){
        
        let cell = InformationTableView.cellForRowAtIndexPath(indexPath)
        let optionalRightMargin: CGFloat = 10.0
        let optionalBottomMargin: CGFloat = 10.0
        hobbyTextField = UITextField(frame: CGRectMake(5, 5, cell!.contentView.frame.size.width - 5 - optionalRightMargin, cell!.contentView.frame.size.height - 5 - optionalBottomMargin))
        hobbyTextField!.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        hobbyTextField?.borderStyle = UITextBorderStyle.RoundedRect
        hobbyTextField?.inputAccessoryView = ToolBarElement
        hobbyTextField?.delegate = self
        hobbyTextField?.placeholder = "enter your new hobby"
    }
    
    func setUpInterestTextField(indexPath : NSIndexPath){
        
        let cell = InformationTableView.cellForRowAtIndexPath(indexPath)
        let optionalRightMargin: CGFloat = 10.0
        let optionalBottomMargin: CGFloat = 10.0
        interestTextField = UITextField(frame: CGRectMake(5, 5, cell!.contentView.frame.size.width - 5 - optionalRightMargin, cell!.contentView.frame.size.height - 5 - optionalBottomMargin))
        interestTextField!.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        interestTextField?.borderStyle = UITextBorderStyle.RoundedRect
        interestTextField?.inputAccessoryView = ToolBarElement
        interestTextField?.delegate = self
        interestTextField?.placeholder = "enter your new interest"
        
        
    }
    
    
    @IBAction func EditProfilePictureTapped(sender: AnyObject) {
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .PhotoLibrary
        
        presentViewController(imagePicker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickerImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            ProfilePicture.contentMode = .ScaleAspectFill
            let newImage = imageWithImage(pickerImage, scaledToSize: CGSize(width: ProfilePicture.frame.width, height: ProfilePicture.frame.height))
            ProfilePicture.image = newImage
            Data.currentUser?.setPhoto(newImage)
            let imageData = UIImagePNGRepresentation(newImage)!
            let encodedString = imageData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
            Data.ref.child("users").child(Data.userID!).updateChildValues(["ProfilePicture" : encodedString])
            Data.currentUser?.setEncodedString(encodedString)
            
            
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // this function is to resize the images taken from the photo library
    func imageWithImage(image:UIImage, scaledToSize newSize:CGSize ) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        let newImage : UIImage  = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        return newImage;
    }
    
    
    

}
