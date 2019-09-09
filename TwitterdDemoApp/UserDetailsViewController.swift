//
//  UserDetailsViewController.swift
//  TwitterdDemoApp
//
//  Created by PRASHANT CHAUDHAI on 06/09/19.
//  Copyright © 2019 Numeroeins. All rights reserved.
//

import UIKit
import TwitterKit

class UserDetailsViewController: UIViewController {

    @IBOutlet var lblFollowers: UIButton!
    
    @IBOutlet var lblFollowig: UIButton!
    @IBOutlet var lblusername: UILabel!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var imageUser: UIImageView!
    var Showfriend = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageUser.layer.cornerRadius = imageUser.frame.size.width/2
        imageUser.clipsToBounds = true
        self.lblName.text  = "\(String(describing: UserDefaults.standard.value(forKey: kname)!))"
        self.lblusername.text  = "\(String(describing: UserDefaults.standard.value(forKey: KscreenName)!))"

        let url = URL(string: UserDefaults.standard.value(forKey: kimageuser) as! String)
        DispatchQueue.global().async
         {
            do{
                let imageData = try Data(contentsOf: url!)
                
                DispatchQueue.main.async {
                 self.imageUser.image = UIImage(data: imageData)
                }
            }
            catch (let error)
            {
                print(error)
            }
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.isNavigationBarHidden = true

        self.getfolllowers(accessToken: UserDefaults.standard.value(forKey: kAuthToken) as! String)
        self.getfollowing(accessToken: UserDefaults.standard.value(forKey: kAuthToken) as! String)

    }
    
    @IBAction func logoutAction()
    {
        let sessionStore = TWTRTwitter.sharedInstance().sessionStore
        if let userID = sessionStore.session()?.userID {
            sessionStore.logOutUserID(userID)
        }
        UserDefaults.standard.set(nil, forKey: KscreenName)
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginvc") as! ViewController
        let nv = UINavigationController(rootViewController: vc)
        appdelegate.window?.rootViewController = nv
        appdelegate.window?.makeKeyAndVisible()

    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! ListVC
        vc.showFriends = self.Showfriend
    }
    func getfolllowers(accessToken:String) {
        
        //Get users timeline tweets
        
        var request = URLRequest(url: URL(string:"https://api.twitter.com/1.1/followers/ids.json?cursor=-1&screen_name=\(UserDefaults.standard.value(forKey: KscreenName)!)&count=5000")!) //users/lookup, followers/ids, followers/list
        request.httpMethod = "GET"
        request.setValue("Bearer "+accessToken, forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in guard let data = data, error == nil else { // check for fundamental networking error
            print("error=\(String(describing: error))")
            return
            }
            
            //                    let responseString = String(data: data, encoding: .utf8)
            //                    let dictionary = data
            //                    print("dictionary = \(dictionary)")
            //                    print("responseString = \(String(describing: responseString!))")
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 { // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
            }
            
            do {
                let response = try JSONSerialization.jsonObject(with: data, options: [])
                let result = response as? [String:Any] ?? [:]
                if result.count > 0
                {
                    DispatchQueue.main.async {
                        self.lblFollowers.setTitle("Followers \((result["ids"] as! NSArray).count)", for: .normal)
                    }
                    
                }
               
                
            } catch let error as NSError {
                print(error)
            }
        }
        
        task.resume()
        
        
    }

func getfollowing(accessToken:String) {
    
    //Get users timeline tweets
    var request = URLRequest(url: URL(string: "https://api.twitter.com/1.1/friends/ids.json?screen_name=\(UserDefaults.standard.value(forKey: KscreenName)!)")!) //users/lookup, followers/ids, followers/list
    request.httpMethod = "GET"
    request.setValue("Bearer "+accessToken, forHTTPHeaderField: "Authorization")
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in guard let data = data, error == nil else { // check for fundamental networking error
        print("error=\(String(describing: error))")
        return
        }
        
        //                    let responseString = String(data: data, encoding: .utf8)
        //                    let dictionary = data
        //                    print("dictionary = \(dictionary)")
        //                    print("responseString = \(String(describing: responseString!))")
        
        if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 { // check for http errors
            print("statusCode should be 200, but is \(httpStatus.statusCode)")
            print("response = \(String(describing: response))")
        }
        
        do {
            let response = try JSONSerialization.jsonObject(with: data, options: [])
            let result = response as? [String:Any] ?? [:]
            if result.count > 0
            {
                DispatchQueue.main.async {
                    self.lblFollowig.setTitle("Following \((result["ids"] as! NSArray).count)", for: .normal)
                }
                
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    task.resume()
    
    
}

  

    @IBAction func showFollowers(_ sender: Any) {
        self.Showfriend = false
        self.performSegue(withIdentifier: "listsegue", sender: nil)


    }
    @IBAction func showFollowing(_ sender: Any) {
        
        self.Showfriend = true
        self.performSegue(withIdentifier: "listsegue", sender: nil)

    }
    
}
