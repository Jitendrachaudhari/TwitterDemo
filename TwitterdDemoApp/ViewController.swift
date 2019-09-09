//
//  ViewController.swift
//  TwitterdDemoApp
//
//  Created by Jitendra Chaudhari on 03/09/19.
//  Copyright © 2019 Numeroeins. All rights reserved.
//

import UIKit
import TwitterKit

class ViewController: UIViewController {

    var accessToken:String!
    var userId:String!
    var screenName:String!
    var imageUrl:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true
       
        
    }


    @IBAction func loginAction(_ sender: Any) {
        
        TWTRTwitter.sharedInstance().logIn { (session, error) in
            if (session != nil) {
//                self.firstName = session?.userName ?? ""
//                self.lastName = session?.userName ?? ""
              
                let client = TWTRAPIClient.withCurrentUser()
                client.loadUser(withID: session?.userID ?? "", completion: {(user, error) in

                    UserDefaults.standard.set(user?.screenName ?? "", forKey: KscreenName)
                    UserDefaults.standard.set(user?.profileImageLargeURL ?? "", forKey: kimageuser)
                    UserDefaults.standard.set(user?.name ?? "", forKey: kname)
                    
                })
                
                client.requestEmail { email, error in
                    if (email != nil) {
                        UserDefaults.standard.set(email ?? "", forKey: KscreenName)

                    }else {
                        print("error: \(String(describing: error?.localizedDescription))");
                    }
                }
                
                self.getBearerToken()
                
            }else {
                print("error: \(String(describing: error?.localizedDescription))");
            }
        }
        
    }



func loadFollowers(userid:String) {
    
    //let twapi = "https://api.twitter.com/1.1/followers/list.json?cursor=-1&user_id=\(session)&count=5000"
    let twapi = "https://api.twitter.com/1.1/friends/list.json?cursor=-1&user_id=\(userid)&count=10"
    let url2 = URL(string: twapi)!
    print(url2)
    URLSession.shared.dataTask(with: url2, completionHandler: { (data, response, error) in
        
        //UIApplication.shared.isNetworkActivityIndicatorVisible = false
        do {
            let userData = try JSONSerialization.jsonObject(with: data!, options:[])
            print(userData)
        } catch {
            NSLog("Account Information could not be loaded \(error)")
        }
    }).resume()
}
    
    
   
    func getBase64EncodeString() -> String {
        
        let concatenateKeyAndSecret = consumerKey + ":" + consumerSecret
        let secretAndKeyData = concatenateKeyAndSecret.data(using: String.Encoding.ascii, allowLossyConversion: true)
        let base64EncodeKeyAndSecret = secretAndKeyData?.base64EncodedString(options: NSData.Base64EncodingOptions())
        return base64EncodeKeyAndSecret!
    }
    
    func getBearerToken() {
        var request = URLRequest(url: URL(string: authUrl)!)
        request.httpMethod = "POST"
        
        request.addValue("Basic " + getBase64EncodeString(), forHTTPHeaderField: "Authorization")
        request.addValue("application/x-www-form-urlencoded;charset=UTF-8", forHTTPHeaderField:"Content-Type")
        request.setValue("29", forHTTPHeaderField:"Content-Length")
        request.setValue("gzip", forHTTPHeaderField: "Accept-Encoding")
        let grantType = "grant_type=client_credentials"
        request.httpBody = grantType.data(using: String.Encoding.utf8, allowLossyConversion:  true)
        let session = URLSession.shared
        session.dataTask(with: request, completionHandler: {
            (data:Data?,response:URLResponse?,error:Error?) in
            do {
                if let results: NSDictionary = try JSONSerialization .jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments  ) as? NSDictionary {
                    if let token = results["access_token"] as? String {
                        UserDefaults.standard.set(token, forKey:kAuthToken)
                        self.performSegue(withIdentifier: "UserDetailsegue", sender: nil)

                    } else {
                        print(results["errors"]!)
                    }
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }).resume()
      
    }
    
}
