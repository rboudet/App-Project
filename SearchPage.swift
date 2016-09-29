//
//  SearchPage.swift
//  DKE
//
//  Created by Romain Boudet on 02/08/16.
//  Copyright © 2016 Romain Boudet. All rights reserved.
//

import UIKit
import Firebase

class SearchPage: UITableViewController, UISearchBarDelegate, UISearchDisplayDelegate {
    
    
    var sections = [] as [String]
    
    
    @IBOutlet var SearchToolbar: UIToolbar!
    @IBOutlet weak var NavigationBar: UINavigationItem!
    
    @IBOutlet weak var Open: UIBarButtonItem!
    @IBOutlet var ListOfUsers: UITableView!
    var currentCell = MyCustomCell.init(style: .Default, reuseIdentifier: "cell")
    var test = Array<Array<String>>()
    var dict = [[String:String]]()
    var users = [] as [String]
    var majors = [] as [String]
    var uid = [] as [String]
    var names = [] as [String]
    var index = 0
    var test2 = "false" as String
    var list = [] as [String]
    var isSearching = false
    var searchDict = [[String:String]]()
    var searchSections = [] as [String]
    var presentSearchBar : UISearchBar?
    
    
    override func viewDidLoad() {
    
        let searchBar = UISearchBar()
        searchBar.sizeToFit()
        searchBar.placeholder = "Search Names and Majors"
        searchBar.delegate = self
        searchBar.inputAccessoryView = self.SearchToolbar
        self.presentSearchBar = searchBar
        self.NavigationBar.titleView = searchBar
        
        
        
        super.viewDidLoad()
        ListOfUsers.delegate  = self
        ListOfUsers.dataSource = self
        
        if (self.revealViewController() != nil){
            
            Open.target = self.revealViewController()
            Open.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        self.ListOfUsers.tableHeaderView = UIView()
        self.ListOfUsers.tableFooterView = UIView()
        
        Data.ref.child("users").observeEventType(.ChildAdded, withBlock: { (snapshot) -> Void in
            let data = snapshot.value as! [String : AnyObject]
            let firstName = data["firstName"] as! String
            let lastName = data["lastName"] as! String
            let name = firstName + " " + lastName
            let firstChar = firstName[firstName.startIndex]
            let firstLetter = String(firstChar).uppercaseString
            let uid = data["uid"] as! String
            let major : String?
            if (data["major"] == nil){
                major = "Major not provided"
            }
            else{
                major = data["major"] as? String
            }
            self.dict.append(["firstLetter" : firstLetter, "uid": uid, "name" : name, "major" : major! , "EncodedString" : data["ProfilePicture"] as! String])
            
            self.dict = self.dict.sort{($0["name"]!).localizedCompare($1["name"]!) == NSComparisonResult.OrderedAscending}
            
            
            if(!self.sections.contains(firstLetter)){
                self.sections.append(firstLetter)
                // we add in the sections array all the first letters of the names if they are not already in the array
            }

            self.ListOfUsers.reloadData()
        })
        
        
        Data.ref.child("users").observeEventType(.ChildChanged, withBlock: { (snapshot) -> Void in
            let data = snapshot.value as! [String : AnyObject]
            for i in 0...self.dict.count-1{
                if (self.dict[i]["name"]! == (data["firstName"] as! String) + " " + (data["lastName"] as! String)){
                    self.dict[i]["major"] = data["major"] as? String
                    self.dict[i]["EncodedString"] = data["ProfilePicture"] as? String
                }
            }
            

            self.ListOfUsers.reloadData()
        })
        
        Data.ref.observeEventType(.ChildRemoved, withBlock: { (snapshot) -> Void in
            //self.ListOfUsers.reloadData()
        })
        
        
     /*   _ = Data.ref.observeSingleEventOfType(FIRDataEventType.Value, withBlock: { (snapshot) in
            let data = snapshot.value as! [String : AnyObject]
            self.list = data["list"] as! [String]
            // here list represents a list of all the user's ID that have registered
            self.users = self.list
            self.majors = self.list
            self.uid = self.list
            self.names = self.list
            // we set all these arrays to be the same as list to have the correct length
            var iterations = 0
            if(self.users.count != 0){
                for i in 0...self.users.count-1{
                    // then we iterate through all the users, and retreive their profile information
                    Data.ref.child("users").child(self.users[i]).observeSingleEventOfType(.Value, withBlock: { (snapshot2) in
                        let data2 = snapshot2.value as! [String : AnyObject]
                        let firstName = data2["firstName"] as! String
                        let lastName = data2["lastName"] as! String
                        let major = data2["major"]
                        let encodedPictureString = data2["ProfilePicture"] as! String
                        self.names[i] = firstName + " " + lastName
                        if(data2["major"] == nil){
                            self.majors[i] = ""
                        }
                        else{
                            self.majors[i] = major as! String
                        }
                        
                        let firstChar = firstName[firstName.startIndex]
                        let firstLetter = String(firstChar).uppercaseString
                        // we take the first character of the name to create the section array
                        if(!self.sections.contains(firstLetter)){
                            self.sections.append(firstLetter)
                            // we add in the sections array all the first letters of the names if they are not already in the array
                        }
                        
                        self.dict.append(["firstLetter" : firstLetter, "uid": self.users[i], "name" : self.names[i], "major" : self.majors[i], "EncodedString" : encodedPictureString])
                        // dict will contain all the information we need, it is an array of dictionnaries
                        self.dict = self.dict.sort{($0["name"]!).localizedCompare($1["name"]!) == NSComparisonResult.OrderedAscending}
                        // we then sort the array
                        iterations = iterations + 1
                        if(iterations ==  self.users.count){
                            self.ListOfUsers.reloadData()  // we reload the data, once the array has been filled with all the data
                        }
                        
                    })
                }
            }

            
        })*/
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
      
        

    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var number = 0
        self.sections = self.sections.sort({$0 < $1})
        // we sorte the section array, to have the sections in alphabetical order
        if(dict.count != 0 && test2 != "true"){
            let letter = sections[section]
            for i in 0...dict.count-1{
                
                if(dict[i]["firstLetter"]!.caseInsensitiveCompare(letter) == NSComparisonResult.OrderedSame){
                    number = number + 1
                    // we count how many names start with the letter so that we know many cells are going to be needed
                }
            }
        }
        
        return number
    }
    
    
    
    override func tableView(tableView : UITableView, cellForRowAtIndexPath indexPath : NSIndexPath) -> UITableViewCell{
        var currentDict = [[String:String]]()
        var currentSection = [] as [String]
        index = 0
        let cell:MyCustomCell = self.tableView.dequeueReusableCellWithIdentifier("UserCell") as! MyCustomCell
        cell.cellLabel.hidden = true
        let sectionNumber = indexPath.section
        if (isSearching){
            currentDict = self.searchDict
            currentSection = self.searchSections
        }
        else {
            currentDict = self.dict
            currentSection = self.sections
        }
        
        if(dict.count != 0){
            while(!(currentDict[index]["firstLetter"]!.caseInsensitiveCompare(currentSection[sectionNumber]) == NSComparisonResult.OrderedSame) && index < currentDict.count){
                index = index + 1
                
                // once we change sections, we get the index of the first name that has the same letter as the section
            }
            
            if(currentDict[index + indexPath.row]["firstLetter"]!.caseInsensitiveCompare(currentSection[sectionNumber
                ]) == NSComparisonResult.OrderedSame && index < currentDict.count){
                
                cell.cellTitle.text = currentDict[index + indexPath.row]["name"]
                cell.cellSubtitle.text = currentDict[index + indexPath.row]["major"]
                cell.cellLabel.text = currentDict[index + indexPath.row]["uid"]
                
                let dataDecoded = NSData(base64EncodedString: currentDict[index + indexPath.row]["EncodedString"]!, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)!
                
                let profilePhoto = UIImage(data: dataDecoded)
                

                cell.cellProfilePicture.layer.borderWidth = 1
                cell.cellProfilePicture.layer.borderColor = UIColor.blackColor().CGColor
                cell.cellProfilePicture.layer.cornerRadius = cell.cellProfilePicture.frame.size.width/15
                cell.cellProfilePicture.clipsToBounds = true
                cell.cellProfilePicture.image = profilePhoto
                
                
                
            }
        }
        return cell

    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        var numSections : Int?
        if ( self.isSearching){
            numSections = self.searchSections.count
        }
        else{
            numSections = self.sections.count
        }
        return numSections!
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        var section = [] as [String]
        if(isSearching){
            section = self.searchSections
        }
        else{
            section = self.sections
        }
        
        section = section.sort({$0 < $1})
        return section
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var currentSections = [] as [String]
        if (isSearching){
            currentSections = self.searchSections
        }
        else{
            currentSections = self.sections
        }
        return currentSections[section]
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        let cell = ListOfUsers.cellForRowAtIndexPath(indexPath)
        self.currentCell = cell as! MyCustomCell
        // we set the current cell to be the cell that we are going to select
        return indexPath
    }
 
    
    func searchDisplayControllerDidBeginSearch(controller: UISearchDisplayController) {
        self.isSearching = true
    }
    
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.filterBrothersForSearchString(searchText)
    }
    
    func filterBrothersForSearchString(searchText : String){
        if (searchText == ""){
            self.isSearching = false
            self.tableView.reloadData()
            return
        }
        // Filter the array using the filter method
        self.searchDict = [[String : String]]()
        self.searchSections = [] as [String]
        self.isSearching = true
        if self.dict.count == 0 {
            return
        }
        self.searchDict = self.dict.filter({( user: [String:String]) -> Bool in
            // to start, let's just search by name
            return (user["name"]!.lowercaseString.rangeOfString(searchText.lowercaseString) != nil) || (user["major"]!.lowercaseString.rangeOfString(searchText.lowercaseString) != nil)
        })
        
        if (self.searchDict.count > 0){
            for i in 0...self.searchDict.count - 1{
                let firstLetter = self.searchDict[i]["firstLetter"]
                if(!self.searchSections.contains(firstLetter!)){
                    self.searchSections.append(firstLetter!)
                }
            }
        }
        self.tableView.reloadData()
        
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.isSearching = false
        self.searchDict = [[String : String]]()
        self.sections = [] as [String]
        self.tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.isSearching = true
        let text = searchBar.text
        self.filterBrothersForSearchString(text!)
        searchBar.resignFirstResponder()
    }

    

    @IBAction func CancelButtonTapped(sender: AnyObject) {
        self.presentSearchBar?.resignFirstResponder()
    }
    
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "CellToProfil") {
            let svc = segue.destinationViewController as! ViewProfilViewController;
            svc.toPass = currentCell.cellLabel.text!
        }
    }
    
    
    // to leave the search bar keyboard
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
        
    }
}
