//
//  MessagesTableViewController.swift
//  DKE
//
//  Created by romain boudet on 2017-01-28.
//  Copyright © 2017 Romain Boudet. All rights reserved.
//

import UIKit
import Firebase



class MessagesTableViewController: UITableViewController {

    static var userSelected : User?
    
    @IBOutlet var MessageTableView: UITableView!
    
    lazy var menuButton : UIBarButtonItem = {
        let image = #imageLiteral(resourceName: "Menu Filled-50")
        let menuButton = UIBarButtonItem(image:image, style: UIBarButtonItemStyle.plain, target: self, action: #selector(handleMenu))
        menuButton.tintColor = UIColor.black
        return menuButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.MessageTableView.delegate = self
        self.MessageTableView.dataSource = self
        tableView.tableFooterView = UIView()
        // we set up the navigation bar
        setUpNavBar(name: (Data.currentUser?.fullName)!, photo: (Data.currentUser?.profilePicture)!)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.compose, target: self, action: #selector(newMessage))
       navigationItem.leftBarButtonItem = menuButton
       
        observeMessages()
        
        // for the menu button
        
        if (self.revealViewController() != nil){
            
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (MessagesTableViewController.userSelected != nil){
            //setUpNavBar(name:(MessagesTableViewController.userSelected?.fullName!)! , photo: (MessagesTableViewController.userSelected?.profilePicture)!)
            showChatController(user: MessagesTableViewController.userSelected!)
        }
    }
    
    var messages = [Message]()
    var messagesDictionary = [String:Message]()
    
    
    func observeMessages() {
         Data.ref.child("Messages").observe(.childAdded, with: { (snapshot) -> Void in
            if let dictionary = snapshot.value as? [String : AnyObject]{
                let message = Message()
                message.setValuesForKeys(dictionary)
                if let chatPartnerId = message.chatPartner(){
                    self.messagesDictionary[chatPartnerId] = message
                    self.messages = Array(self.messagesDictionary.values)
                    
                   self.messages = self.messages.sorted{ $0.timeStamp!.intValue > ($1.timeStamp?.intValue)! }
                
                }
                
                // to fix bugs of messgaes loading too fast and messing up the photos
                self.timer?.invalidate()
                // here we cancel the timer (it gets canceled except for the last one)
                
                self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
             
              
                // and schedule to reload the table view in 0.1 seconds
                
            }
                
         })
        
    }
    var timer : Timer?
    func handleReloadTable() {
        DispatchQueue.main.async( execute: {
            self.tableView.reloadData()
        })

    }
    func newMessage(){
        // we want to display the users to select who we want to include in the message 
        Data.isSelectingUsers = true
        self.performSegue(withIdentifier: "SelectUsersToMessage", sender: nil)

        
    }
    
    func handleMenu(){
        
    }
    
    func setUpNavBar(name : String, photo : UIImage){
       
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        
        let containerView = UIView()
        titleView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let profilePic = UIImageView()
        profilePic.translatesAutoresizingMaskIntoConstraints = false
        profilePic.contentMode = .scaleAspectFill
        profilePic.layer.cornerRadius = 20
        profilePic.clipsToBounds = true
        profilePic.image = photo
        containerView.addSubview(profilePic)
        
        
        // ios9 constraint anchors
        profilePic.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profilePic.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profilePic.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profilePic.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
       
        
        let nameLabel = UILabel()
        containerView.addSubview(nameLabel)

        nameLabel.text = name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        nameLabel.leftAnchor.constraint(equalTo: profilePic.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profilePic.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profilePic.heightAnchor).isActive = true
        
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        self.navigationItem.titleView = titleView
        
        
//        titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showChatController)))
        
        
    }
    
    func showChatController(user : User) {
        ChatLogController.user = user
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        navigationController?.pushViewController(chatLogController, animated: true)
        
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
        return messages.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! MyCustomCell
        cell.cellLabel.isHidden = true
        
        let message = messages[indexPath.row]
        
        var timeLabel = UILabel()
        
        let subviews = cell.subviews
        
        if subviews.count > 2 {
            timeLabel = subviews[2] as! UILabel
        }
        else {
            cell.addSubview(timeLabel)
        }
        
        
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.rightAnchor.constraint(equalTo: cell.rightAnchor).isActive = true
        timeLabel.topAnchor.constraint(equalTo: cell.topAnchor, constant: 5).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: cell.cellTitle.heightAnchor).isActive = true
        timeLabel.font = UIFont.systemFont(ofSize: 12)
        timeLabel.textColor = UIColor.darkGray
        
        // we convert the time stamp to actual date
        if let seconds = message.timeStamp?.doubleValue {
            let timeStampDate = NSDate(timeIntervalSince1970: seconds)
            let dateFormatteur = DateFormatter()
            dateFormatteur.dateFormat = "hh:mm:ss a"
            timeLabel.text = dateFormatteur.string(from: (timeStampDate as? Date)!)
            
        
        }
        
        
        
        cell.cellSubtitle.text = message.text
        
        if let chatPartnerId = message.chatPartner() {
             Data.ref.child("users").child(chatPartnerId).observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String : AnyObject]{
                    cell.cellTitle.text = (dictionary["firstName"] as? String)! + " " + (dictionary["lastName"] as? String)!
                    cell.cellLabel.text = dictionary["uid"]as? String
                    let encodedImage = dictionary["ProfilePicture"] as? String
                    let decodedData = Foundation.Data(base64Encoded: encodedImage!, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
                    let decodedImage = UIImage(data: decodedData!)
                    cell.cellProfilePicture.image = decodedImage
                    cell.cellProfilePicture.contentMode = .scaleAspectFill
                    cell.cellProfilePicture.clipsToBounds = true
                    cell.cellProfilePicture.layer.cornerRadius = cell.cellProfilePicture.frame.size.width/2
                }
                
                
            })
            
        }



        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = self.tableView.cellForRow(at: indexPath) as! MyCustomCell
        cell.isSelected = false
        let fullName = cell.cellTitle.text!
        let uid = cell.cellLabel?.text!
        let photo = cell.cellProfilePicture.image
        let user = User(fullName: fullName, uid: uid!, photo: photo!)
        showChatController(user : user)
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
