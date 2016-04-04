//
//  Post.swift
//  sportshowcase
//
//  Created by Jesse Tellez on 4/4/16.
//  Copyright © 2016 SunCat Developers. All rights reserved.
//

import Foundation

class Post {
    private var _postDescription: String!
    private var _imgUrl: String?
    private var _likes: Int!
    private var _username: String!
    private var _postKey: String!
    
    var postDescription: String {
        return _postDescription
    }
    
    var imgUrl: String? {
        return _imgUrl
    }
    
    var likes: Int {
        return _likes
    }
    
    var username: String {
        return _username
    }
    
    var postKey: String {
        return _postKey
    }
    
    //get data from firebase?
    init(description: String, imgUrl: String?, username: String) {
        self._postDescription = description
        self._imgUrl = imgUrl
        self._username = username
    }
    
    //initializer used to download data to firebase
    init(postKey: String, dict: Dictionary <String, AnyObject>){
        self._postKey = postKey
        if let likes = dict["likes"] as? Int {
            self._likes = likes
        }
        
        if let imgUrl = dict["imgUrl"] as? String {
            self._imgUrl = imgUrl
        }
        
        if let description = dict["description"] as? String  {
            self._postDescription = description
        }
    }
}