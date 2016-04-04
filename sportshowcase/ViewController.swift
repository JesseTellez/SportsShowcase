//
//  ViewController.swift
//  sportshowcase
//
//  Created by Jesse Tellez on 3/30/16.
//  Copyright © 2016 SunCat Developers. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class ViewController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) != nil {
            self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
        }
    }
    
    @IBAction func fbBtnPressed(sender: UIButton!){
        let facebookLogin = FBSDKLoginManager()
        facebookLogin.logInWithReadPermissions(["email"]) { (facebookResult, fbErr) -> Void in
            if fbErr != nil {
                print("Facebook Login Failed. \(fbErr)")
            } else {
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                print("Successfully logged in with facebook. \(accessToken)")
                
                //access static instance
                DataService.ds.REF_BASE.authWithOAuthProvider("facebook", token: accessToken, withCompletionBlock: { (err, authData) -> Void in
                    
                    if err != nil {
                        print("loggin failed")
                    }else {
                      print("Logged In!\(authData)")
                        
                        //Create firebase user
                        let user = ["provider": authData.provider!]
                        DataService.ds.createFireBaseUser(authData.uid, user: user)
                        
                        NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: KEY_UID)
                        self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                    }
                })
                
            }
        }
    }
    
    @IBAction func emailBtnPressed(sender: UIButton!){
        if let email = emailField.text where email != "", let pwd = passwordTextField.text where pwd != "" {
            DataService.ds.REF_BASE.authUser(email, password: pwd, withCompletionBlock: { (err, authData) -> Void in
                if err != nil {
                    
                    print(err)
                    
                    if err.code == STATUS_ACCOUNT_NONEXIST {
                        DataService.ds.REF_BASE.createUser(email, password: pwd, withValueCompletionBlock: { (err, result) -> Void in
                            //create a new user
                            if err != nil {
                                self.showErrorAlert("Could not create account", msg: "Please Try again")
                            } else {
                                NSUserDefaults.standardUserDefaults().setValue(result[KEY_UID], forKey: KEY_UID)
                                
                               // DataService.ds.REF_BASE.authUser(email, password: pwd, withCompletionBlock: nil)
                                DataService.ds.REF_BASE.authUser(email, password: pwd, withCompletionBlock: { (err, authData) -> Void in
                                    let user = ["provider": authData.provider!, "blah":"test"]
                                    DataService.ds.createFireBaseUser(authData.uid, user: user)
                                })
                                
                                self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                            }
                            
                        })
                    } else {
                        self.showErrorAlert("Could not Log In", msg: "Please check your username or password")
                    }
                } else {
                    
                    
                    self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                }
            })
        } else {
            showErrorAlert("Email and Password Required", msg: "Please enter an email and password")
        }
    }
    
    
    func showErrorAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }


}

