//
//  MineViewController.swift
//  WClient
//
//  Created by xiaomingsong on 10/18/16.
//  Copyright © 2016 Song Xiaoming. All rights reserved.
//

import UIKit

class MineViewController: UIViewController, UIGestureRecognizerDelegate, UITableViewDataSource {

    @IBOutlet weak var followButton:UIButton!
    @IBOutlet weak var followerButton:UIButton!
    @IBOutlet weak var twitter:UIButton!
    
    @IBOutlet weak var userImageView:UIImageView!
    @IBOutlet weak var scrollView:ScrollTableView!
    @IBOutlet weak var username:UILabel!
    @IBOutlet weak var userInfo:UILabel!
    
    var user: SYBWeiboUser?
    var weibos: Array<SYBWeiBo>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserModule.sharedUserModule.updateUserInfo { (complete) in
            if (complete) {
                self.user = UserModule.sharedUserModule.user
                self.updateViews()
            }
        }
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    func updateViews() -> Void {
        self.followButton.set(title:String(describing: self.user?.friends_count))
        self.followerButton.set(title:String(describing: self.user?.followers_count))
        
        let url = URL(string: (self.user?.profile_image_url)!)
        self.userImageView.sd_setImage(with: url)
        
        self.username.text = self.user?.screen_name
        self.userInfo.text = self.user?.userDescription
    }
    
    // MARK: Table View Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        
        if (tableView == self.scrollView.firstTableView) {
            
            let reuseIdentifier = "WeiboCell"
            
            var weiboCell:WeiboCell? = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? WeiboCell
            if (weiboCell == nil) {
                weiboCell = WeiboCell.cellFromNib(with: reuseIdentifier)
            }
            weiboCell?.setup(of: (weibos?[indexPath.row])!)
            
            return weiboCell!
            
        } else if (tableView == self.scrollView.firstTableView) {
        } else if (tableView == self.scrollView.firstTableView) {
        }
        
        
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
