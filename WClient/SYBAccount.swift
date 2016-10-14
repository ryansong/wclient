//
//  SYBAccount.swift
//  WClient
//
//  Created by xiaomingsong on 10/13/16.
//  Copyright © 2016 Song Xiaoming. All rights reserved.
//

import UIKit

class SYBAccount: SYBWeiboUser {
    
    static let account = SYBAccount()
    
    override init() {
        super.init()
        
        let id = UserDefaults.standard.object(forKey: SSKeyChina_UID)
        if id != nil {
            let userID:String = id as! String
            self.idstr = userID
        }
    }
    
    func isLogin() -> Bool {
        let userID = SYBAccount.account.idstr;
        if userID != nil {
            return true
        }
        return false
    }
    
}
