//
//  User.swift
//  DKE
//
//  Created by Romain Boudet on 15/09/16.
//  Copyright © 2016 Romain Boudet. All rights reserved.
//

import Foundation

class CurrentUser{
    var firstName : String?
    var lastName : String?
    var email : String?
    var major : String?
    var faculty : String?
    var profilePicture : UIImage?
    var encodedString : String?
    
    init(Lastname : String, Firstname : String, email: String, major: String, faculty : String, profilePic : UIImage){
        self.firstName = Firstname
        self.lastName = Lastname
        self.email = email
        self.major = major
        self.faculty = faculty
        self.profilePicture = profilePic
    }
    
    init(Lastname : String, Firstname : String, email: String, profilePic : UIImage){
        self.firstName = Firstname
        self.lastName = Lastname
        self.email = email
        self.profilePicture = profilePic
    }
    
    func setPhoto(photo : UIImage){
        self.profilePicture = photo
    }
    
    func setEncodedString(encoded : String){
        self.encodedString = encoded
    }

}