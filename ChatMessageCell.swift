//
//  ChatMessageCell.swift
//  DKE
//
//  Created by romain boudet on 2017-01-29.
//  Copyright © 2017 Romain Boudet. All rights reserved.
//

import UIKit

class ChatMessageCell: UICollectionViewCell {
    let textView : UITextView = {
        let tv = UITextView()
        tv.text = "test"
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.backgroundColor = UIColor.clear
        tv.textColor = UIColor.white
        return tv
    }()
    
    static let blueColor = UIColor(colorLiteralRed: 0, green: 137/255, blue: 249/255, alpha: 1)
    
    let bubbleView :UIView = {
       let view = UIView()
        
        view.backgroundColor = ChatMessageCell.blueColor
        
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    var profileImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
        
    }()
    
    var bubbleWidthAnchor : NSLayoutConstraint?
    var bubbleViewRightAnchor : NSLayoutConstraint?
    var bubbleViewLeftAnchor : NSLayoutConstraint?

    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(bubbleView)
        addSubview(textView)
        addSubview(profileImageView)
        
        
        
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        
        textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        
        bubbleViewRightAnchor = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant : -8)
        bubbleViewRightAnchor?.isActive = true
        
        bubbleViewLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8)
        
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnchor?.isActive = true
        
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
