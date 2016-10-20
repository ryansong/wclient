//
//  WeiboCell.swift
//  WClient
//
//  Created by xiaomingsong on 10/14/16.
//  Copyright © 2016 Song Xiaoming. All rights reserved.
//

import UIKit

class WeiboCell: UITableViewCell {

    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet weak var contentLabel: UILabel!
    
    static func cellFromNib() -> WeiboCell {
        let nib = Bundle.main.loadNibNamed("WeiboCell", owner: nil, options: nil)
        return nib?.first as! WeiboCell
    }
    
    static func cellFromNib(with reuserIdentifier:String) -> WeiboCell {
        let nib = Bundle.main.loadNibNamed("WeiboCell", owner: nil, options: nil)
        let cell:WeiboCell = nib?.first as! WeiboCell
        cell.setValue(reuserIdentifier, forKey: "reuseIdentifier")
        return cell
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.separatorInset = UIEdgeInsets.zero
    }
    
    func setup(of weibo:SYBWeiBo) {
        self.userImageView.sd_setImage(with: URL.init(string: weibo.user.avatar_large))
        self.usernameLabel.text = weibo.user.name
        self.contentLabel.text = weibo.text
        
        var info:String
        let time:String = NSDate(createAt: weibo.created_at).sinceDate()
        info = time + " " + weibo.source
        self.infoLabel.text = info
        
    }
    
    override func prepareForReuse() {
        self.userImageView.image = nil;
        self.usernameLabel.text = nil
        self.contentLabel.text = nil
    }
    
    override func layoutSubviews() {
        userImageView.setCorner(radius: 10)
        super.layoutSubviews()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
