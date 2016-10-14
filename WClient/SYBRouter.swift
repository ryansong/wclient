//
//  SYBRouter.swift
//  WClient
//
//  Created by xiaomingsong on 10/12/16.
//  Copyright © 2016 Song Xiaoming. All rights reserved.
//

import UIKit

@objc class SYBRouter: NSObject {
    
    static let sharedRouter:SYBRouter = SYBRouter()
    var weiboDelegate:WeiboSDKDelegate? = nil
    
    @objc func showLoginViewInViewController(viewController: UIViewController) -> Void {
        
        let loginVC = SYBWeiboLoginViewController();
        
        if ((viewController.navigationController) != nil) {
            viewController.navigationController?.pushViewController(loginVC, animated: true)
        } else {
            viewController.show(loginVC, sender: nil)
        }
        self.weiboDelegate = loginVC
    }
    
    func dismissLoginView(viewController : SYBWeiboLoginViewController) -> Void {
        if (viewController.navigationController != nil) {
           _ = viewController.navigationController?.popViewController(animated: true)
        } else {
            viewController.dismiss(animated: true, completion: nil)
        }
        self.weiboDelegate = nil
    }
    
}
