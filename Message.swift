//
//  Message.swift
//  DKE
//
//  Created by romain boudet on 2017-01-28.
//  Copyright © 2017 Romain Boudet. All rights reserved.
//

import UIKit

class Message: NSObject {
    var fromID: String?
    var text: String?
    var timeStamp: NSNumber?
    var toID: String?
    var isReceiving : Bool?
    
    func chatPartner() -> String? {
        var chatPartner : String?
        if (fromID! == Data.userID!){
            chatPartner = toID
        }
        else if(toID! == Data.userID!) {
            chatPartner = fromID
        }

        return chatPartner
    }
}
