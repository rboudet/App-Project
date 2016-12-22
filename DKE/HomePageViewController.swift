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


class HomePageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
  
    @IBOutlet weak var Open: UIBarButtonItem!
    
    @IBOutlet weak var ProfilePicture: UIImageView!
    @IBOutlet var ToolBarElement: UIToolbar!

    @IBOutlet weak var InformationTableView: UITableView!
    
    @IBOutlet weak var majorLabel: UILabel!
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var EmailLabel: UILabel!
    @IBOutlet weak var AdressLabel: UILabel!
    @IBOutlet weak var CitiesLabel: UILabel!
    @IBOutlet weak var SnapchatLabel: UILabel!
    
    
    static var justEditedProfil : Bool?
    static var isReady = false
    
    
    var hobbyTextField : UITextField?
    var interestTextField : UITextField?

    var indicator = UIActivityIndicatorView()
    
    var hobbiesShown = 3
    var interestsShown = 3
    var encodedString : String?

    
    static var user : String?
    
    
    // variables needed to display correctly the table view
    var indexInterest = 1
    var Interests = [] as [String]
    var Hobbies = [] as [String]
    var isEditingHobbies = false
    var isEditingInterests = false
    var hobbyTextFieldSetUp = false
    var InterestTextFieldSetUp = false

    
    override func viewWillAppear(_ animated: Bool) {
        
       
    }
    
    override func viewDidLoad() {
    
        
        super.viewDidLoad()
        
        var i = 0
        if (self.revealViewController() != nil){
            
            Open.target = self.revealViewController()
            Open.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        let navigationBar = self.navigationController?.navigationBar
        navigationBar?.barTintColor = UIColor.white

        
        InformationTableView.delegate = self
        InformationTableView.dataSource = self
        InformationTableView.backgroundColor = UIColor.white
        InformationTableView.tableHeaderView = nil
        
        // we set up the image View for the profile picture
        ProfilePicture.layer.borderWidth = 1
        ProfilePicture.layer.borderColor = UIColor.black.cgColor
        ProfilePicture.layer.cornerRadius = ProfilePicture.frame.size.width/2
        ProfilePicture.clipsToBounds = true
        let width = ProfilePicture.frame.width
        let height = ProfilePicture.frame.height
        ProfilePicture.contentMode = .scaleToFill
        
        
        
        if (HomePageViewController.user! == Data.userID!){
            
            // if this is the current user, then we add a button to be able to edit his own profil
            let editButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(HomePageViewController.editProfil))
            editButton.tintColor = UIColor.black
            self.navigationItem.rightBarButtonItem = editButton
            
            
            self.EmailLabel.text = "Email : " + (Data.currentUser?.email)!
            self.NameLabel.text = "Name : " + (Data.currentUser?.firstName)! + " " + Data.currentUser!.lastName!
            self.majorLabel.text = "Major : " + (Data.currentUser?.major)!
            self.AdressLabel.text = "Adress : " + (Data.currentUser?.Address)!
            self.CitiesLabel.text = "Cities lived in : " + (Data.currentUser?.Cities)!
            self.SnapchatLabel.text = "Snapchat : " + (Data.currentUser?.snapchat)!
            let image = imageWithImage((Data.currentUser?.profilePicture)!, scaledToSize: CGSize(width: width - 30, height:
                height - 40))
            ProfilePicture.image = image
            
        }
        
        else{
            Data.ref.child("users").child(HomePageViewController.user!).observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
                let data = snapshot.value as! [String : AnyObject]
                
                self.NameLabel.text = "Name : " + (data["firstName"] as! String) + " " + (data["lastName"] as! String)

                if(data["email"] != nil){
                    self.EmailLabel.text = "Email : " + (data["email"] as! String)
                }
                if(data["major"] != nil){
                    self.majorLabel.text = "Major : " + (data["major"] as! String)
                }
                
                if(data["cities"] != nil){
                    self.CitiesLabel.text = "Cities lived in : " + (data["cities"] as! String)
                }
                if(data["address"] != nil){
                    self.AdressLabel.text = "Adress : " + (data["address"] as! String)
                }
                if(data["snapchat"] != nil){
                    self.SnapchatLabel.text = "Snapchat : " + (data["snapchat"] as! String)
                }
                
                if(data["Committee"] != nil){
                }
                if(data["CommitteeProject"] != nil){
                }
                if(data["Active"] != nil){
                }
                if(data["Chair"] != nil){
                }
                if( data["ProfilePicture"] != nil){
                    let photoString = data["ProfilePicture"] as! String
                    let decodedData = Foundation.Data(base64Encoded: photoString, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
                    let decodedImage = UIImage(data: decodedData!)
                    let image = self.imageWithImage(decodedImage!, scaledToSize: CGSize(width: width - 30, height: height - 40))
                    self.ProfilePicture.image = image
                    
                }
                

                
            })
        }
        
      
        
        

    
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func editProfil(){
        self.performSegue(withIdentifier: "EditProfil", sender: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if(HomePageViewController.justEditedProfil != nil && HomePageViewController.justEditedProfil!){
            let banner = Banner(title: "Changes Saved", subtitle: "", image: UIImage(named: "AppIcon"), backgroundColor: UIColor(red:48.00/255.0, green:174.0/255.0, blue:51.5/255.0, alpha:1.000))
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (2 + self.Hobbies.count + self.Interests.count)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let CellIdentifier = "Cell"
        var cell : UITableViewCell?
        cell = self.InformationTableView.dequeueReusableCell(withIdentifier: CellIdentifier)
        if(cell == nil){
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: CellIdentifier)
            cell!.selectionStyle = UITableViewCellSelectionStyle.gray
            cell!.accessoryType = UITableViewCellAccessoryType.none
        }
        cell!.textLabel?.font = UIFont(name: "Trebuchet MS", size: 10.0)

        
        if((indexPath as NSIndexPath).row == 0){
            // this means it is the 'add Hobby' cell
            if(isEditingHobbies){
                cell!.textLabel!.text = ""
                InformationTableView.scrollToRow(at: indexPath, at: .top, animated: true)
                cell!.contentView.addSubview(hobbyTextField!)
                cell!.accessoryType = UITableViewCellAccessoryType.none
                
            }
            else{
                cell!.textLabel?.font = UIFont(name: "Trebuchet MS-bold", size: 10.0)
                cell!.textLabel?.text = "Add new Hobby    +"
            }
        }
        
        else if((indexPath as NSIndexPath).row == self.indexInterest){
            // this means it is the 'add Interest' cell
            if(isEditingInterests){
                InformationTableView.scrollToRow(at: indexPath, at: .top, animated: true)
                cell!.textLabel!.text = ""
                cell!.contentView.addSubview(interestTextField!)
                cell!.accessoryType = UITableViewCellAccessoryType.none
            }
            else{
                cell!.textLabel?.font = UIFont(name: "Trebuchet MS-bold", size: 10.0)
                cell!.textLabel?.text = "Add new Interest   +"
            }
        }
        
        else if((indexPath as NSIndexPath).row < self.indexInterest){
            if( (indexPath as NSIndexPath).row <= self.hobbiesShown){
            // this categorie of cells are the hobbies that the user has already put in
                cell!.textLabel?.text = self.Hobbies[self.Hobbies.count - (indexPath as NSIndexPath).row]
            }
            else if ((indexPath as NSIndexPath).row == self.hobbiesShown + 1){
                cell!.textLabel?.text = "Tap to see more"
            }
        }
        else{
            // these will be the interests of the user
            if ((indexPath as NSIndexPath).row <= indexInterest + interestsShown){
                cell!.textLabel?.text = self.Interests[self.Interests.count - ((indexPath as NSIndexPath).row - self.indexInterest)]
            }
            else if( (indexPath as NSIndexPath).row == indexInterest + interestsShown + 1){
                cell!.textLabel?.text = "Tap to see more"
            }
            
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = InformationTableView.cellForRow(at: indexPath)
        cell?.setSelected(false, animated: false)
        
        if((indexPath as NSIndexPath).row == 0){
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
        else if((indexPath as NSIndexPath).row == indexInterest){
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
        else if( (indexPath as NSIndexPath).row == hobbiesShown + 1){
            hobbiesShown = hobbiesShown + 3
            InformationTableView.reloadData()
        }
        else if( (indexPath as NSIndexPath).row == indexInterest + interestsShown + 1){
            interestsShown = interestsShown + 3
            InformationTableView.reloadData()
        }
            
        else if ((indexPath as NSIndexPath).row < indexInterest) {
            cancelTextField()
            hobbiesShown = 3
            interestsShown = 3
            // the user as clicked on a hobby, an alert shows up asking if he wants to delete this hobby or not
            let alert = UIAlertController(title: "Deleting", message: "Are you sure you want to delete this Hobby?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: {  (action: UIAlertAction!) in
                self.Hobbies.remove(at: self.Hobbies.count - (indexPath as NSIndexPath).row)
                self.indexInterest = self.indexInterest - 1
                self.InformationTableView.reloadData()
            }))
            alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            

        }
      
        else {
            cancelTextField()
            hobbiesShown = 3
            interestsShown = 3
            let alert = UIAlertController(title: "Deleting", message: "Are you sure you want to delete this Interest?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: {  (action: UIAlertAction!) in
                self.Interests.remove(at: self.Interests.count - ((indexPath as NSIndexPath).row - self.indexInterest))
                self.InformationTableView.reloadData()
            }))
            
            alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)

        }
        
        Data.ref.child("users").child(Data.userID!).updateChildValues(["Hobbies" : self.Hobbies, "indexInterest" : self.indexInterest, "Interests" : self.Interests])


    }
    
    
    @IBAction func CancelButtonTapped(_ sender: AnyObject) {
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
    
    
    @IBAction func SaveButtonTapped(_ sender: AnyObject) {
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
        indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        indicator.center = self.view.center
        indicator.hidesWhenStopped = true
        self.view.addSubview(indicator)
    }
    
    func setUpHobbyTextField(_ indexPath : IndexPath){
        
        let cell = InformationTableView.cellForRow(at: indexPath)
        let optionalRightMargin: CGFloat = 10.0
        let optionalBottomMargin: CGFloat = 10.0
        hobbyTextField = UITextField(frame: CGRect(x: 5, y: 5, width: cell!.contentView.frame.size.width - 5 - optionalRightMargin, height: cell!.contentView.frame.size.height - 5 - optionalBottomMargin))
        hobbyTextField!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hobbyTextField?.borderStyle = UITextBorderStyle.roundedRect
        hobbyTextField?.inputAccessoryView = ToolBarElement
        hobbyTextField?.delegate = self
        hobbyTextField?.placeholder = "enter your new hobby"
    }
    
    func setUpInterestTextField(_ indexPath : IndexPath){
        
        let cell = InformationTableView.cellForRow(at: indexPath)
        let optionalRightMargin: CGFloat = 10.0
        let optionalBottomMargin: CGFloat = 10.0
        interestTextField = UITextField(frame: CGRect(x: 5, y: 5, width: cell!.contentView.frame.size.width - 5 - optionalRightMargin, height: cell!.contentView.frame.size.height - 5 - optionalBottomMargin))
        interestTextField!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        interestTextField?.borderStyle = UITextBorderStyle.roundedRect
        interestTextField?.inputAccessoryView = ToolBarElement
        interestTextField?.delegate = self
        interestTextField?.placeholder = "enter your new interest"
    }
    
    // this function is to resize the images taken from the photo library
    func imageWithImage(_ image:UIImage, scaledToSize newSize:CGSize ) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage : UIImage  = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext();
        return newImage;
    }
    
    
    @IBAction func EditProfileTapped(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "EditProfil", sender: nil)
    }
    
    
    

}
