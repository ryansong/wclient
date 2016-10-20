//
//  ScrollTableView.swift
//  WClient
//
//  Created by xiaomingsong on 10/18/16.
//  Copyright © 2016 Song Xiaoming. All rights reserved.
//

import UIKit


public protocol ScrollTableViewDelegate:NSObjectProtocol {
    
    func scrollView(_ scrollView: ScrollTableView, didScrollFromTableView fromIndex:Int, ToTableView toIndex: Int) -> Void
}

open class ScrollTableView: UIView {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var firstTableView: SwipeTableView!
    @IBOutlet weak var middleTableView: SwipeTableView!
    @IBOutlet weak var lastTableView: SwipeTableView!
    
    weak open var delegate:ScrollTableViewDelegate?
    var viewArrays:[UITableView]?
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        
        self.xibSetup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.xibSetup()
    }
    
    func xibSetup() {
        
        Bundle.main.loadNibNamed("ScrollTableView", owner: self, options: nil)
        addSubview(self.scrollView!)
        
        self.scrollView.mas_makeConstraints { (make:MASConstraintMaker?) in
            make?.edges.setInsets(UIEdgeInsets.zero)
        }
    }
    
    static func scrollTableViewFromNib() -> ScrollTableView {
        let nib = Bundle.main.loadNibNamed("ScrollTableView", owner: self, options: nil)
        return nib?.first as! ScrollTableView
    }

    
    func setDataSource(dataSource:UITableViewDataSource) -> Void {
        self.firstTableView.dataSource = dataSource
        self.middleTableView.dataSource = dataSource
        self.lastTableView.dataSource = dataSource
    }
    
    func setDelegate(delegate:UITableViewDelegate) -> Void {
        self.firstTableView.delegate = delegate
        self.middleTableView.delegate = delegate
        self.lastTableView.delegate = delegate
    }

}
