//
//  DataService.swift
//  sportshowcase
//
//  Created by Jesse Tellez on 3/31/16.
//  Copyright © 2016 SunCat Developers. All rights reserved.
//

import Foundation
import Firebase

let URL_BASE = "https://sportshowcase.firebaseio.com"

class DataService {
    //create a static vairable (only one instance in memory)
    static let ds = DataService()
    
    
    
    private var _REF_BASE = Firebase(url: URL_BASE)
    
    private var _REF_POSTS = Firebase(url: "\(URL_BASE)/posts")
    
    private var _REF_USERS = Firebase(url: "\(URL_BASE)/users")
    
    var REF_BASE: Firebase {
        return _REF_BASE
    }
    
    var REF_USERS: Firebase {
        return _REF_USERS
    }
    
    var REF_POSTS: Firebase {
        return _REF_POSTS
    }
    
    func createFireBaseUser(uid: String, user: Dictionary<String, String>) {
        
        //what ever values are in the user dictionary, it updates them and adds a new user with them
        REF_USERS.childByAppendingPath(uid).setValue(user)
    }
}