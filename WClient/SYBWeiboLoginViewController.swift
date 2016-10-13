//
//  SYBWeiboLoginViewController.swift
//  WClient
//
//  Created by xiaomingsong on 10/12/16.
//  Copyright © 2016 Song Xiaoming. All rights reserved.
//

import UIKit


class SYBWeiboLoginViewController: UIViewController, WeiboSDKDelegate{

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let authorizeRequest = WBAuthorizeRequest.init()
        
        authorizeRequest.redirectURI = redirect_uri;
        authorizeRequest.scope = "all";
        authorizeRequest.shouldShowWebViewForAuthIfCannotSSO = true;
        
        WeiboSDK.send(authorizeRequest)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - WeiboSDKDelegate
    
    func didReceiveWeiboRequest(_ request: WBBaseRequest) -> Void {
    }
    
    func didReceiveWeiboResponse(_ response: WBBaseResponse) -> Void {

        if response.isMember(of: WBAuthorizeResponse.self) && response.statusCode == .success {
            let accessToken = (response as! WBAuthorizeResponse).accessToken
            let refreshToken = (response as! WBAuthorizeResponse).refreshToken
            let userID = (response as! WBAuthorizeResponse).userID
            
            UserDefaults.standard.set(userID, forKey: "uid")
            UserDefaults.standard.set(refreshToken, forKey: "refreshToken")
            UserDefaults.standard.synchronize()
            SSKeychain.setPassword(accessToken, forService: "WClient", account: userID)
        }
        
        SYBRouter.sharedRouter.dismissLoginView(viewController: self)
    }

}
