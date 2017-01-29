//
//  DateService.swift
//  DKE
//
//  Created by Romain Boudet on 02/08/16.
//  Copyright © 2016 Romain Boudet. All rights reserved.
//

import Foundation
import Firebase

class Data {
    static var isSelectingUsers = false
    static var ref = FIRDatabase.database().reference()
    static var userID = FIRAuth.auth()?.currentUser?.uid
    static var user = FIRAuth.auth()?.currentUser
    static var currentUser : User?
    
    static func setCurrentUser(firstName : String, lastName : String, email : String){
        let user = User(Lastname: lastName, Firstname: firstName, email: email)
        Data.currentUser = user
    }
}
