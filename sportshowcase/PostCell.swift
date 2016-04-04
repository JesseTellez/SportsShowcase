//
//  PostCell.swift
//  sportshowcase
//
//  Created by Jesse Tellez on 4/1/16.
//  Copyright © 2016 SunCat Developers. All rights reserved.
//

import UIKit
import Alamofire

class PostCell: UITableViewCell {

    @IBOutlet weak var progireImg: UIImageView!
    @IBOutlet weak var showCaseImg: UIImageView!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var likesLabel: UILabel!
    
    //need to create and store an alamofire request because you need to be able to cancel it
    var request = Request?
    
    var post: Post!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
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
        self.descriptionText.text = post.postDescription
        self.likesLabel.text = "\(post.likes)"
        
        //everytime we download an image from the internet, we are going to store it in the cache
        
    }
    
}
