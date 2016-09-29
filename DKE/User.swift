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
    var major = "Not Provided"
    var faculty : String?
    var profilePicture : UIImage?
    var encodedString : String?
    var Address = "Not Provided"
    var Cities = "Not Provided"
    var snapchat = "Not Provided"
    
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
    func setAddress(address : String){
        self.Address = address
    }
    func setCities(cities : String){
        self.Cities = cities
    }
    func setMajor( major : String){
        self.major = major
    }
    
    func setSnapchat( snapchat : String){
        self.snapchat = snapchat
    }
    

}