//
//  User.swift
//  DKE
//
//  Created by Romain Boudet on 15/09/16.
//  Copyright © 2016 Romain Boudet. All rights reserved.
//

import Foundation

class User{
    var firstName : String?
    var lastName : String?
    var fullName : String?
    var email : String?
    var uid : String?
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
    var firstLetter : String?
    
    init(Lastname : String, Firstname : String, email: String, major: String, profilePic : UIImage, uid : String){
        self.firstName = Firstname
        self.lastName = Lastname
        self.email = email
        self.major = major
        self.profilePicture = profilePic
        self.fullName = Firstname + " " + Lastname
        self.uid = uid
        let firstChar = Firstname[Firstname.startIndex]
        let firstLetter = String(firstChar).uppercased()
        self.firstLetter = firstLetter

    }
    
    init(Lastname : String, Firstname : String, email: String){
        self.firstName = Firstname
        self.lastName = Lastname
        self.email = email
        self.fullName = Firstname + " " + Lastname
        let firstChar = Firstname[Firstname.startIndex]
        let firstLetter = String(firstChar).uppercased()
        self.firstLetter = firstLetter
    }
    
    init(fullName : String, uid: String, photo : UIImage){
        self.uid = uid
        self.fullName = fullName
        self.profilePicture = photo
        let firstChar = fullName[fullName.startIndex]
        let firstLetter = String(firstChar).uppercased()
        self.firstLetter = firstLetter
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
    
    func setUid(uid : String){
        self.uid = uid
    }

}
