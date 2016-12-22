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
    
    
    
    
    @IBOutlet var SearchToolbar: UIToolbar!
    @IBOutlet weak var NavigationBar: UINavigationItem!
    
    @IBOutlet weak var Open: UIBarButtonItem!
    @IBOutlet var ListOfUsers: UITableView!
    
    static var sections = [] as [String]
    var currentCell = MyCustomCell.init(style: .default, reuseIdentifier: "cell")
    static var dict = [[String:String]]()
    var users = [] as [String]
    var majors = [] as [String]
    var uid : [String]?
    var names = [] as [String]
    var index = 0
    var test2 = "false" as String
    var list = [] as [String]
    var isSearching = false
    var searchDict = [[String:String]]()
    var searchSections = [] as [String]
    var presentSearchBar : UISearchBar?
    
    
    override func viewDidLoad() {
    
        let nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.blackTranslucent
        
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
            Open.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        let width = self.ListOfUsers.frame.width
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 30.0))
        
        let but = UIButton(type: UIButtonType.roundedRect)
    
        but.frame = CGRect(x: 0 , y: 0, width: 30, height: 30)
        but.setTitle("Sort by : ", for: UIControlState.normal)
       // but.addTarget(self, action: #selector(EditProfilTableViewController.ChangePhoto), for: .touchUpInside)
        
        headerView.addSubview(but)
        but.titleLabel?.font = UIFont(name: "Arial", size: 10.0)
        
        self.ListOfUsers.tableHeaderView = UIView()
        self.ListOfUsers.tableFooterView = UIView()
        
        
        
        // if some data has changed, this will find the user that has changed, and update its value in the dictionary
        
        Data.ref.child("users").observe(.childChanged, with: { (snapshot) -> Void in
            
            let data = snapshot.value as! [String : AnyObject]
            for i in 0...SearchPage.dict.count-1{
                if (SearchPage.dict[i]["name"]! == (data["firstName"] as! String) + " " + (data["lastName"] as! String)){
                    SearchPage.dict[i]["major"] = data["major"] as? String
                    SearchPage.dict[i]["EncodedString"] = data["ProfilePicture"] as? String
                }
            }
            
            self.ListOfUsers.reloadData()
        })
        
        Data.ref.observe(.childRemoved, with: { (snapshot) -> Void in
            //self.ListOfUsers.reloadData()
        })
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var number = 0
        SearchPage.sections = SearchPage.sections.sorted(by: {$0 < $1})
        // we sorte the section array, to have the sections in alphabetical order
        if(SearchPage.dict.count != 0 && test2 != "true"){
            let letter = SearchPage.sections[section]
            for i in 0...SearchPage.dict.count-1{
                
                if(SearchPage.dict[i]["firstLetter"]!.caseInsensitiveCompare(letter) == ComparisonResult.orderedSame){
                    number = number + 1
                    // we count how many names start with the letter so that we know many cells are going to be needed
                }
            }
        }
        
        return number
    }
    
    
    
    override func tableView(_ tableView : UITableView, cellForRowAt indexPath : IndexPath) -> UITableViewCell{
        var currentDict = [[String:String]]()
        var currentSection = [] as [String]
        index = 0
        let cell:MyCustomCell = self.tableView.dequeueReusableCell(withIdentifier: "UserCell") as! MyCustomCell
        cell.cellLabel.isHidden = true
        cell.SelectUser.isHidden = true
        let sectionNumber = (indexPath as NSIndexPath).section
        if (isSearching){
            currentDict = self.searchDict
            currentSection = self.searchSections
        }
        else {
            currentDict = SearchPage.dict
            currentSection = SearchPage.sections
        }
        
        if(SearchPage.dict.count != 0){
            while(!(currentDict[index]["firstLetter"]!.caseInsensitiveCompare(currentSection[sectionNumber]) == ComparisonResult.orderedSame) && index < currentDict.count){
                index = index + 1
                
                // once we change sections, we get the index of the first name that has the same letter as the section
            }
            
            if(currentDict[index + (indexPath as NSIndexPath).row]["firstLetter"]!.caseInsensitiveCompare(currentSection[sectionNumber
                ]) == ComparisonResult.orderedSame && index < currentDict.count){
                
                cell.cellTitle.text = currentDict[index + (indexPath as NSIndexPath).row]["name"]
                cell.cellSubtitle.text = currentDict[index + (indexPath as NSIndexPath).row]["major"]
                cell.cellLabel.text = currentDict[index + (indexPath as NSIndexPath).row]["uid"]
                
                let dataDecoded = Foundation.Data(base64Encoded: currentDict[index + (indexPath as NSIndexPath).row]["EncodedString"]!, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)!
                
                let profilePhoto = UIImage(data: dataDecoded)
                

                cell.cellProfilePicture.layer.borderWidth = 1
                cell.cellProfilePicture.layer.borderColor = UIColor.black.cgColor
                cell.cellProfilePicture.layer.cornerRadius = cell.cellProfilePicture.frame.size.width/3
                cell.cellProfilePicture.clipsToBounds = true
                cell.cellProfilePicture.image = profilePhoto
                
                
                
            }
        }
        return cell

    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        var numSections : Int?
        if ( self.isSearching){
            numSections = self.searchSections.count
        }
        else{
            numSections = SearchPage.sections.count
        }
        return numSections!
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        var section = [] as [String]
        if(isSearching){
            section = self.searchSections
        }
        else{
            section = SearchPage.sections
        }
        
        section = section.sorted(by: {$0 < $1})
        return section
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var currentSections = [] as [String]
        if (isSearching){
            currentSections = self.searchSections
        }
        else{
            currentSections = SearchPage.sections
        }
        return currentSections[section]
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let cell = ListOfUsers.cellForRow(at: indexPath)
        self.currentCell = cell as! MyCustomCell
        // we set the current cell to be the cell that we are going to select
        return indexPath
    }
 
    func searchDisplayControllerDidBeginSearch(_ controller: UISearchDisplayController) {
        self.isSearching = true
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.filterBrothersForSearchString(searchText)
    }
    
    func filterBrothersForSearchString(_ searchText : String){
        if (searchText == ""){
            self.isSearching = false
            self.tableView.reloadData()
            return
        }
        // Filter the array using the filter method
        self.searchDict = [[String : String]]()
        self.searchSections = [] as [String]
        self.isSearching = true
        if SearchPage.dict.count == 0 {
            return
        }
        self.searchDict = SearchPage.dict.filter({( user: [String:String]) -> Bool in
            // to start, let's just search by name
            return (user["name"]!.lowercased().range(of: searchText.lowercased()) != nil) || (user["major"]!.lowercased().range(of: searchText.lowercased()) != nil)
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
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.isSearching = false
        self.searchDict = [[String : String]]()
        SearchPage.sections = [] as [String]
        self.tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.isSearching = true
        let text = searchBar.text
        self.filterBrothersForSearchString(text!)
        searchBar.resignFirstResponder()
    }

    

    @IBAction func CancelButtonTapped(_ sender: AnyObject) {
        self.presentSearchBar?.resignFirstResponder()
    }
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "ViewProfile") {
           // let svc = segue.destination as! HomePageViewController;
            HomePageViewController.user = currentCell.cellLabel.text!
        }
    }
    
    
    // to leave the search bar keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
        
    }
}
