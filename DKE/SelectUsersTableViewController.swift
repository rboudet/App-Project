//
//  SelectUsersTableViewController.swift
//  DKE
//
//  Created by Romain Boudet on 29/10/16.
//  Copyright © 2016 Romain Boudet. All rights reserved.
//

import UIKit

class SelectUsersTableViewController: UITableViewController {

    
    @IBOutlet var usersTableView: UITableView!
    var users = [[String : String]]()
    var selectedUsers : [String]?
    var sections : [String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // we retreive the users and the sections for the seachPage, as we have already retreived all the info and put them in there.
        users = SearchPage.dict
        sections = SearchPage.sections
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return sections!.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var number = 0
        sections = sections?.sorted(by: {$0 < $1})
        // we sorte the section array, to have the sections in alphabetical order
        if(users.count != 0){
            let letter = sections?[section]
            for i in 0...users.count-1{
                
                if(users[i]["firstLetter"]!.caseInsensitiveCompare(letter!) == ComparisonResult.orderedSame){
                    number = number + 1
                    // we count how many names start with the letter so that we know many cells are going to be needed
                }
            }
        }
        
        return number

    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sections!.sorted(by: {$0 < $1})
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections![section]
    }
    
    

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var index = 0
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "SelectionUser") as! MyCustomCell
        cell.cellLabel.isHidden = true
        let sectionNumber = indexPath.section
        while(!(users[index]["firstLetter"]!.caseInsensitiveCompare(sections![sectionNumber]) == ComparisonResult.orderedSame) && index < users.count){
                index = index + 1
        // once we change sections, we get the index of the first name that has the same letter as the section
        }
            
        if(users[index + indexPath.row]["firstLetter"]!.caseInsensitiveCompare((sections?[sectionNumber
            ])!) == ComparisonResult.orderedSame && index < users.count){
                
            cell.cellTitle.text = users[index + indexPath.row]["name"]
            cell.cellSubtitle.text = users[index + indexPath.row]["major"]
            cell.cellLabel.text = users[index + indexPath.row]["uid"]
            if(selectedUsers?.contains(users[index + indexPath.row]["uid"]!))!{
                cell.SelectUser.isOn = true
            }
            else{
                cell.SelectUser.isOn = false
            }
            
            let dataDecoded = Foundation.Data(base64Encoded: users[index + indexPath.row]["EncodedString"]!, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)!
                
            let profilePhoto = UIImage(data: dataDecoded)
                
                
            cell.cellProfilePicture.layer.borderWidth = 1
            cell.cellProfilePicture.layer.borderColor = UIColor.black.cgColor
            cell.cellProfilePicture.layer.cornerRadius = 3.6
            cell.cellProfilePicture.clipsToBounds = true
            cell.cellProfilePicture.image = profilePhoto
            
        }
        return cell
    }
    
    override func viewWillDisappear(_ animated: Bool) {
       // we want to go through all the cells, to see which users have been checked
        var section = 0
        var index = 0
        var indexPath : IndexPath?
        var cell : MyCustomCell?
        var newSelectedUsers:[String] = []
        while(true){
            while(true){
                indexPath = NSIndexPath(row: index, section: section) as IndexPath
                cell = self.usersTableView.cellForRow(at: indexPath!) as! MyCustomCell?
                if(cell == nil){
                    break
                }
                else {
                    if (cell?.SelectUser.isOn)!{
                        newSelectedUsers.append((cell?.cellLabel.text!)!)
                    }
                }
                index = index + 1
            }
            if(index == 0){
                break
            }
            section = section + 1
            index = 0
        }
        
        CreateEventPageViewController.selectedUsers = newSelectedUsers
        CreateEventPageViewController.tblPostData2?.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = usersTableView.cellForRow(at: indexPath)
        cell?.setSelected(false, animated: true)
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
