//
//  FeedVC.swift
//  sportshowcase
//
//  Created by Jesse Tellez on 4/1/16.
//  Copyright © 2016 SunCat Developers. All rights reserved.
//



//WHEN NOT USING IMAGESHACK, USE AMAZON S3

import UIKit
import Firebase
import Alamofire

class FeedVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var postFeild: MaterialTextField!
    @IBOutlet weak var imgSelectorImg: UIImageView!
    
    
    var posts = [Post]()
    
    var imageSelected = false
    
    //one instance globally availible
    static var imgCache = NSCache()
    
    var imgPicker: UIImagePickerController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 352
        imgPicker = UIImagePickerController()
        imgPicker.delegate = self
        
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
        
     
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as? PostCell {
            
            //if a new cell is being loaded, cancel the request
            cell.request?.cancel()
            
            var img = UIImage?
        
            if let url = post.imgUrl {
                //need to grab the static instance so dont use "self"
                img = FeedVC.imgCache.objectForKey(url) as? UIImage
            }
            
            cell.configureCell(post, img: img)
            return cell
        }else {
            return PostCell()
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        let post = posts[indexPath.row]
        
        
        if post.imgUrl ==  nil {
            //might want to make this dynamic
            return 150
        } else {
            return tableView.estimatedRowHeight
        }
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imgPicker.dismissViewControllerAnimated(true, completion: nil)
        imgSelectorImg.image = image
        imageSelected = true
    }

    @IBAction func selectImage(sender: UITapGestureRecognizer) {
        presentViewController(imgPicker, animated: true, completion: nil)
    }
    
    @IBAction func makePost(sender: AnyObject) {
        
        if let txt = postFeild.text where txt != nil {
            
            if let img = imgSelectorImg.image where imageSelected == true {
                let urlStr = "https://post.imageshack.us/upload_api.php"
                let url = NSURL(string: urlStr)!
                //convert image into a jpeg and compress (0 - 1 : 0 means really compressed and 1 is not at all)
                let imageData = UIImageJPEGRepresentation(img, 0.2)
                
                //MULTIPART FORM REQUEST
                let apiKeyData = "PUT API KEY HERE".dataUsingEncoding(NSUTF8StringEncoding)!
                let keyJSON = "json".dataUsingEncoding(NSUTF8StringEncoding)!
                
                Alamofire.upload(.POST, urlStr, multipartFormData: {
                    multipartData in
                    
                    //we are doing this because the image data is different from the string data!!!!
                    
                    //this is the format provided by the API for imageshack
                    multipartData.appendBodyPart(data: imageData, name:"fileupload", filename: "Image", mimeType: "img/jpg")
                    multipartData.appendBodyPart(data: apiKeyData, name:"key")
                    multipartData.appendBodyPart(data: keyJSON, name:"json")

                    
                    }) { encodingResult in
                        //this is what happens when the uploading is done!!
                        switch encodingResult {
                        case .Success(let upload, _, _):
                            //get response json from server
                            upload.responseJSON(completionHandler: {
                                request, response, result in
                                
                                if let info = result.value as? Dictionary<String, AnyObject> {
                
                                    if let links = info["links"] as? Dictionary<String, AnyObject> {
                                        
                                        if let imgLink = links["image_link"] as? String {
                                            print("LINK: \(imgLink)")
                                            self.postToFireBase(imgLink)
                                        }
                                    }
                                    
                                }
                            })
                        case .Failure(let error):
                            print(error)
                        }
                        
                }
            } else {
                self.postToFireBase(nil)
            }
        }
        
    }
    
    func postToFireBase(imgUrl: String?) {
        //firebase is a clientbased database meaning: your frontend kind of controls that database
        //a typical rest server will reject data that is not in the right form, firebase will not
        //for example: if you had an angular app, ios app, and andriod app, then you must ensure all 3 apps have the exact same data structure on their client
        
        var post: Dictionary<String, AnyObject> = [
            "description": postFeild.text,
            "likes": 0
        ]
        
        if imgURL != nil {
            post["imageUrl"] = imgUrl!
        }
        
        //make a new id
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        
        postFeild.text = ""
        imgSelectorImg.image = UIImage(named: "camera")
        imageSelected = false
        tableView.reloadData()
    }
}
