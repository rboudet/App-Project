//
//  ChatLogController.swift
//  DKE
//
//  Created by romain boudet on 2017-01-28.
//  Copyright © 2017 Romain Boudet. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController : UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout {
    static var user : User?
    
    lazy var inputTextField : UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message"
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        //collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)

        collectionView?.keyboardDismissMode = .interactive
        
        collectionView?.alwaysBounceVertical = true
        observeMessages()
        collectionView?.backgroundColor = UIColor.white
        setUpInputComponents()
        let name = ChatLogController.user?.fullName
        let photo =  ChatLogController.user?.profilePicture
        
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: "cellId")
        setUpKeyBoardObserves()
        setUpNavBar(name: name!, photo: photo!)
        MessagesTableViewController.userSelected = nil
        
        
    }
    
   /*lazy var inputContainerView : UIView? = {
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        containerView.backgroundColor = UIColor.gray
    
        let sendButton = UIButton(type: .system)
    
        sendButton.setTitle("send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(sendButton)
    
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        sendButton.addTarget(self, action: #selector(handleSend), for: UIControlEvents.touchUpInside)
    
    
    
        containerView.addSubview(self.inputTextField)
    
        // set constaints
        self.inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        self.inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        self.inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        self.inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
    
    
        let seperatorLineView = UIView()
        seperatorLineView.backgroundColor = UIColor.black
        seperatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(seperatorLineView)
    
        seperatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        seperatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        seperatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        seperatorLineView.heightAnchor.constraint(equalToConstant: 0.7).isActive = true
    
        containerView.becomeFirstResponder()
    
        return containerView
    }()*/
    
 
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    
    var messages = [Message]()
    
    func observeMessages(){
        // fetch all the messages we need from the user
        
        let _ = Data.ref.child("user-message").child(Data.userID!).observe(.childAdded, with: { (snapshot) in
            // we retrive the message id to find the name of the recipient
            let messageId = snapshot.key
            let _ = Data.ref.child("Messages").child(messageId).observe(FIRDataEventType.value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String : AnyObject]
                else {
                    return
                }
                
                let message = Message()
                message.setValuesForKeys(dictionary)
                
                if message.chatPartner() == (ChatLogController.user?.uid)! {
                    self.messages.append(message)
                    DispatchQueue.main.async( execute: {
                        self.collectionView?.reloadData()
                    })
                }
            
            })
        
        })
        
    }
    
    func setUpKeyBoardObserves() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: .UIKeyboardDidHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillChange), name: .UIKeyboardWillChangeFrame, object: nil)
        
    }
    
    func handleKeyboardWillChange(notification : NSNotification){
        // need to hide the container View
        self.containerView!.isHidden = true
        
    }
    
    func handleKeyboardWillShow(notification : NSNotification){
        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        self.containerView!.isHidden = false
        // we need tomove the textfield up
        containerViewBottomAnchor?.constant = -keyboardFrame!.height
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        UIView.animate(withDuration: keyboardDuration!, animations: {
            self.view.layoutIfNeeded()
        })
    }
    func handleKeyboardWillHide(notification : NSNotification){
        self.containerView!.isHidden = false
        containerViewBottomAnchor?.constant = 0
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        UIView.animate(withDuration: keyboardDuration!, animations: {
            self.view.layoutIfNeeded()
        })


    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
        
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! ChatMessageCell
        
        let message = self.messages[indexPath.item]
        cell.textView.text = message.text!
        
        // set up the color + text color
        setUpCell(cell: cell, message: message)
        
        // we want to modify the width
       
        cell.bubbleWidthAnchor?.constant = estimatedFrameForText(text: message.text!).width + 32
        
        return cell
    }
    
    private func setUpCell(cell : ChatMessageCell, message : Message){
        
        
        
        if(message.fromID! == Data.userID!){
            // message should be blue
            cell.bubbleView.backgroundColor = ChatMessageCell.blueColor
            cell.textView.textColor = UIColor.white
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
            cell.profileImageView.isHidden = true
        }
        else {
            cell.profileImageView.image = ChatLogController.user?.profilePicture
            // incoming message gray
            cell.textView.textColor = UIColor.black
            // we get the bubbles that are gray to go on the left
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
            cell.profileImageView.isHidden = false

            cell.bubbleView.backgroundColor = UIColor(colorLiteralRed: 240/255, green: 240/255, blue: 240/255, alpha: 1)
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height = 80.0 as CGFloat
        if let text = messages[indexPath.item].text {
            height = estimatedFrameForText(text: text).height + 20
        }
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    private func estimatedFrameForText(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 16)], context: nil)
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
        
    }
    
    var containerViewBottomAnchor : NSLayoutConstraint?
    
    var containerView : UIView?
    
    
    
    
    func setUpInputComponents() {
        containerView = UIView()
        containerView?.backgroundColor = UIColor.white
        containerView?.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView!)
        
        // need constraint anchors
        containerView?.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        
        containerViewBottomAnchor = containerView?.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        containerViewBottomAnchor?.isActive = true

        containerView?.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView?.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        let sendButton = UIButton(type: .system)
        
        sendButton.setTitle("send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        containerView?.addSubview(sendButton)
        
        sendButton.rightAnchor.constraint(equalTo: (containerView?.rightAnchor)!).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: (containerView?.centerYAnchor)!).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: (containerView?.heightAnchor)!).isActive = true
        sendButton.addTarget(self, action: #selector(handleSend), for: UIControlEvents.touchUpInside)
        
       
        
        containerView?.addSubview(inputTextField)
        
        // set constaints 
        inputTextField.leftAnchor.constraint(equalTo: (containerView?.leftAnchor)!, constant: 8).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: (containerView?.centerYAnchor)!).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: (containerView?.heightAnchor)!).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        
        
        let seperatorLineView = UIView()
        seperatorLineView.backgroundColor = UIColor.black
        seperatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView?.addSubview(seperatorLineView)
        
        seperatorLineView.leftAnchor.constraint(equalTo: (containerView?.leftAnchor)!).isActive = true
        seperatorLineView.topAnchor.constraint(equalTo: (containerView?.topAnchor)!).isActive = true
        seperatorLineView.widthAnchor.constraint(equalTo: (containerView?.widthAnchor)!).isActive = true
        seperatorLineView.heightAnchor.constraint(equalToConstant: 0.7).isActive = true
        
        
    }
    
    func handleSend(){
        
        // we save the info about the message in the main message folder
        
        let timeStamp :Int = Int(NSDate().timeIntervalSince1970)
        let childRef = Data.ref.child("Messages").childByAutoId()
        let values = ["text" : inputTextField.text!, "toID" : (ChatLogController.user)!.uid!, "fromID" : (Data.userID)!, "timeStamp" : timeStamp] as [String : Any]
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                return
            }
            // we save the messageId in both the users messages, so that we will be able to fetch it when loading a user's messages
            self.inputTextField.text = nil
            let userMessageRef = Data.ref.child("user-message")
            let messageId = childRef.key
            userMessageRef.child(Data.userID!).updateChildValues([messageId : 1])
            userMessageRef.child((ChatLogController.user)!.uid!).updateChildValues([messageId : 1])
        }
        
        childRef.updateChildValues(values)
        
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
}
