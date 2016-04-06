//
//  PostCell.swift
//  sportshowcase
//
//  Created by Jesse Tellez on 4/1/16.
//  Copyright © 2016 SunCat Developers. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

class PostCell: UITableViewCell {

    @IBOutlet weak var progireImg: UIImageView!
    @IBOutlet weak var showCaseImg: UIImageView!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var likeImage: UIImageView!
    
    //need to create and store an alamofire request because you need to be able to cancel it
    var request: Request?
    
    var post: Post!
    
    var likeRef: Firebase!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tapRecog = UITapGestureRecognizer(target: self, action: "likeTapped:")
        tapRecog.numberOfTapsRequired = 1
        
        likeImage.addGestureRecognizer(tapRecog)
        likeImage.userInteractionEnabled = true
        
        
        
    }
    
    override func drawRect(rect: CGRect) {
        progireImg.layer.cornerRadius = progireImg.frame.size.width / 2
        
        progireImg.clipsToBounds = true
        
        showCaseImg.clipsToBounds = true
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        //configure the view for the selected state
        
    }
    
    func configureCell(post: Post, img: UIImage) {
        self.post = post
        likeRef = DataService.ds.REF_USER_CURRENT.childByAppendingPath("likes").childByAppendingPath(post.postKey)
        self.descriptionText.text = post.postDescription
        self.likesLabel.text = "\(post.likes)"
        
        //everytime we download an image from the internet, we are going to store it in the cache
        if post.imgUrl != nil {
            
            if img != nil {
                self.showCaseImg.image = img
            } else {
                request = Alamofire.request(.GET, post.imgUrl!).validate(contentType: ["image/*"]).response(completionHandler: {
                    request, response, data, error in
                    if error == nil {
                        let img = UIImage(data: data!)!
                        self.showCaseImg.image = img
                        //add to cache
                        FeedVC.imgCache.setObject(img, forKey: self.post.imgUrl!)
                    }
                })
            }
            
        }else {
            self.showCaseImg.hidden = true
        }
        
        
        //handle how to show if heart is full or not
        
        //this will only ever be called once for CURRENT USER
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            if let doesNotExists = snapshot.value as? NSNull {
                //need to show empty heart
                //firebase: If there is no data in .value, you will get an NSNull!!
                self.likeImage.image = UIImage(named: "heart-empty")
            } else {
                self.likeImage.image = UIImage(named: "heart-full")
            }
        })
        
    }
    
    func likeTapped(sender: UITapGestureRecognizer) {
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            if let doesNotExists = snapshot.value as? NSNull {
                //need to show empty heart
                //firebase: If there is no data in .value, you will get an NSNull!!
                self.likeImage.image = UIImage(named: "heart-full")
                self.post.adjustLikes(true)
                //this sets the like reference to true -> meaning users now have references to what they have liked
                self.likeRef.setValue(true)
            } else {
                self.likeImage.image = UIImage(named: "heart-empty")
                self.post.adjustLikes(false)
                //removes the key itself too
                self.likeRef.removeValue()
            }
        })
    }
    
}
