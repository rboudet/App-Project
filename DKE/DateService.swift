//
//  DateService.swift
//  DKE
//
//  Created by Romain Boudet on 02/08/16.
//  Copyright © 2016 Romain Boudet. All rights reserved.
//

import Foundation
import Firebase
import GoogleSignIn

class Data {

    static var ref = FIRDatabase.database().reference()
    static var userID = FIRAuth.auth()?.currentUser?.uid
    static var user = FIRAuth.auth()?.currentUser
    static var googleUser : GIDGoogleUser?
    static var accessToken = ""
    static var refreshToken = ""
    static var expires = Date()
    static var currentUser : CurrentUser?
}
