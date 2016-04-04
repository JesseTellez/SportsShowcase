//
//  FeedVC.swift
//  sportshowcase
//
//  Created by Jesse Tellez on 4/1/16.
//  Copyright © 2016 SunCat Developers. All rights reserved.
//

import UIKit
import Firebase

class FeedVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var posts = [Post]()
    
    //one instance globally availible
    static var imgCache = NSCache()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        DataService.ds.REF_POSTS.observeEventType(.Value, withBlock: { snapshot in
            //code in here will be called over and over again once data is changed
            //replace all the data before parsing
            self.posts = []
            
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot]{
                for snap in snapshots {
                   // print("Snap: \(snap)")
                    if let postDictionary = snap.value as? Dictionary <String, AnyObject> {
                        let key = snap.key
                        let post = Post(postKey: key, dict: postDictionary)
                        self.posts.append(post)
                    }
                }
            }
            //update the tableview EVERYTIME new data comes in
            self.tableView.reloadData()
            //print(snapshot.value)
        })
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        
        var img = UIImage?
        
        if let url = post.imgUrl {
            //need to grab the static instance so dont use "self"
            img = FeedVC.imgCache.objectForKey(url) as? UIImage
        }
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as? PostCell {
            cell.configureCell(post, img: img)
            return cell
        }else {
            return PostCell()
        }
    }

}
