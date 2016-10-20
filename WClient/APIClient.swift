//
//  APIClient.swift
//  WClient
//
//  Created by xiaomingsong on 10/20/16.
//  Copyright © 2016 Song Xiaoming. All rights reserved.
//

import UIKit

class APIClient: NSObject {
    
    static let sharedAPIClient = APIClient()
    let session = AFHTTPSessionManager.init(baseURL: URL(string:KAPIBaseUrl))
    
    override init() {
        super.init()
    }
}
