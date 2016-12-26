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
    var fullName : String?
    var email : String?
    var major = "Not Provided"
    var faculty = "Not Provided"
    var profilePicture : UIImage?
    var encodedString : String?
    var Address = "Not Provided"
    var Cities = "Not Provided"
    var snapchat = "Not Provided"
    var committee = "Not Provided"
    var currentProject = "Not Provided"
    var isChair = false
    var isActive = false
    
    init(Lastname : String, Firstname : String, email: String, major: String, faculty : String, profilePic : UIImage){
        self.firstName = Firstname
        self.lastName = Lastname
        self.email = email
        self.major = major
        self.faculty = faculty
        self.profilePicture = profilePic
        self.fullName = Firstname + " " + Lastname
    }
    
    init(Lastname : String, Firstname : String, email: String){
        self.firstName = Firstname
        self.lastName = Lastname
        self.email = email
        self.fullName = Firstname + " " + Lastname
    }
    
    func setPhoto(_ photo : UIImage){
        self.profilePicture = photo
    }
    
    func setEncodedString(_ encoded : String){
        self.encodedString = encoded
    }
    func setAddress(_ address : String){
        self.Address = address
    }
    func setCities(_ cities : String){
        self.Cities = cities
    }
    func setMajor( _ major : String){
        self.major = major
    }
    
    func setSnapchat( _ snapchat : String){
        self.snapchat = snapchat
    }
    
    func setCommittee(_ committee : String){
        self.committee = committee
    }
    
    func setCurrentProject(_ project : String){
        self.currentProject = project
    }
    
    func setChair(_ isChair : Bool){
        self.isChair = isChair
    }
    func setActive (_ isActive : Bool){
        self.isActive = isActive
    }

}
