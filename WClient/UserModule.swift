//
//  UserModule.swift
//  WClient
//
//  Created by xiaomingsong on 10/18/16.
//  Copyright © 2016 Song Xiaoming. All rights reserved.
//

import UIKit

class UserModule: NSObject {
    
    static let sharedUserModule = UserModule()
    var user:SYBWeiboUser! = SYBWeiboUser()
    
    func updateUserInfo(completion: @escaping (Bool)->Void) -> Void {
        SYBWeiboAPIClient.shared().getUserInfo(withSource: nil, uid: nil, screen_name: nil, success: { (dictionary)-> Void in
           
            let dict:Dictionary = dictionary!
            self.user.idstr = dict["idstr"] as! String!;
            self.user.screen_name = dict["screen_name"] as! String!;
            self.user.location = dict["location"] as! String!;
            self.user.profile_image_url = dict["avatar_large"] as! String!;
            self.user.profile_url = dict["profile_url"] as! String!;
            self.user.userDescription = dict["description"] as! String!;
            self.user.screen_name = dict["screen_name"] as! String!;
            self.user.friends_count = (dict["friends_count"] as! NSNumber).int32Value
            self.user.followers_count = (dict["followers_count"] as! NSNumber).int32Value
            self.user.statuses_count = (dict["statuses_count"] as! NSNumber).int32Value
            
            completion(true)
            
        }) { (type) in
            completion(false)
        }
    }
    
    func fetchtwitter(of user:SYBWeiboUser, completion:(Bool)->Void) -> Void {
        
    }

}
