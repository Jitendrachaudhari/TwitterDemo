//
//  ListVC.swift
//  TwitterdDemoApp
//
//  Created by Jitendra Chaudhari on 05/09/19.
//  Copyright © 2019 Numeroeins. All rights reserved.
//

import UIKit
import Kingfisher

class ListVC: UIViewController,UITableViewDelegate,UITableViewDataSource{

    @IBOutlet var tblList: UITableView!
    var arr_frind:[FriendListData] = []
    var cursor = -1
    var LoadMore = true
    var showFriends = Bool()
    var progresBar = UIActivityIndicatorView(style: .whiteLarge)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progresBar.backgroundColor = UIColor.darkGray
        self.navigationController?.isNavigationBarHidden = false
        
        if showFriends
        {
            self.title = "Followers"
                self.navigationController?.navigationItem.title = "Followers"
        }
        else
        {
            self.title = "Frinds"

        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if showFriends
        {
            self.getFriends(accessToken: UserDefaults.standard.value(forKey: kAuthToken) as! String, baseUrl: "https://api.twitter.com/1.1/followers/list.json?")

        }
        else
        {
            self.getFriends(accessToken: UserDefaults.standard.value(forKey: kAuthToken) as! String, baseUrl: "https://api.twitter.com/1.1/friends/list.json?")

        }
    }
    func getFriends(accessToken:String,baseUrl:String) {
        
        self.progresBar.startAnimating()
        //Get users timeline tweets
        var request = URLRequest(url: URL(string: "\(baseUrl)screen_name=\(UserDefaults.standard.value(forKey: KscreenName)!)&count=50&cursor=\(self.cursor)")!) //users/lookup, followers/ids, followers/list
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
                    if self.cursor==(result["next_cursor"] as? Int ?? -1)
                    {
                        self.LoadMore = false
                    }
                    else
                    {
                         self.cursor = result["next_cursor"] as? Int ?? -1
                    }
                   
                    let users = result["users"] as? [[String:Any]] ?? [[:]]
                    
                    for item in users
                    {
                        let obj_user = FriendListData()
                        obj_user.name = item["name"] as? String ?? ""
                        obj_user._description = item["description"] as? String ?? ""
                        obj_user.profile_image_url = (item["profile_image_url"] as? String ?? "")
                        self.arr_frind.append(obj_user)
                    }
                    
                    DispatchQueue.main.async {
                        self.progresBar.startAnimating()
                        self.tblList.reloadData()
                    }
                    
                }
            } catch let error as NSError {
                print(error)
            }
        }
        
        task.resume()
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arr_frind.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.textLabel?.text = self.arr_frind[indexPath.row].name!
        cell.detailTextLabel?.text = self.arr_frind[indexPath.row]._description!

        let url = URL(string: self.arr_frind[indexPath.row].profile_image_url!)
        
        let image = UIImage(named: "icons8-twitter-96")
        cell.imageView?.kf.setImage(with: url, placeholder: image)
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
        tap.accessibilityHint = String(indexPath.row)
        cell.imageView?.isUserInteractionEnabled = true
        cell.imageView?.addGestureRecognizer(tap)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row==self.arr_frind.count - 1 && self.LoadMore
        {
            if showFriends
            {
                self.getFriends(accessToken: UserDefaults.standard.value(forKey: kAuthToken) as! String, baseUrl: "https://api.twitter.com/1.1/followers/list.json?")
                
            }
            else
            {
                self.getFriends(accessToken: UserDefaults.standard.value(forKey: kAuthToken) as! String, baseUrl: "https://api.twitter.com/1.1/friends/list.json?")
                
            }
        }
    }
    
     @objc func imageTapped(_ sender: UITapGestureRecognizer) {
        
        let newImageView = UIImageView()
        let url = URL(string: self.arr_frind[Int(sender.accessibilityHint!)!].profile_image_url!.replacingOccurrences(of: "_normal", with: ""))
        let image = UIImage(named: "icons8-twitter-96")
        newImageView.kf.setImage(with: url, placeholder: image)
        newImageView.frame = UIScreen.main.bounds
        newImageView.backgroundColor = .black
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(tap)
        self.view.addSubview(newImageView)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        sender.view?.removeFromSuperview()
    }
}


