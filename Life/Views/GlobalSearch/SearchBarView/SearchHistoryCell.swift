//
//  SearchHistoryCell.swift
//  SearchBar
//
//  Created by huangmian on 2018/7/26.
//  Copyright © 2018年 hm. All rights reserved.
//

import UIKit
import SnapKit

class SearchHistoryCell: UITableViewCell {
    var deleteTapped: (() -> Void)?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel.init()
        label.textColor = UIColor.init(hexString: "#494949")
        label.font = UIFont.systemFont(ofSize: 15.0)
        return label
    }()
    
    private lazy var deleleButton: UIButton = {
        let button = UIButton.init()
        button.setImage(#imageLiteral(resourceName: "deleteHistoryIcon"), for: UIControlState.normal)
        return button
    }()
    
    private lazy var seperationView: UIView = {
        let view = UIView.init(frame: CGRect.zero)
        view.backgroundColor = UIColor.init(hexString: "#ebeef1")
        return view
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        self.contentView.addSubview(deleleButton)
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(seperationView)
        
        deleleButton.snp.makeConstraints {
            $0.right.equalToSuperview().inset(UIEdgeInsetsMake(0, 0, 0, 16))
            $0.width.equalTo(35)
            $0.height.equalTo(35)
            $0.centerX.equalToSuperview()
        }
        deleleButton.addTarget(self, action: #selector(deleteAction), for: UIControlEvents.touchUpInside)
        
        titleLabel.snp.makeConstraints {
            $0.left.top.equalToSuperview().inset(UIEdgeInsetsMake(18, 15, 0, 0))
            $0.right.equalTo(deleleButton.snp.left).offset(-15)
        }
        
        seperationView.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview().inset(UIEdgeInsetsMake(0, 15, 0, 15))
            $0.height.equalTo(0.5)
        }
    }
    
    func setTitle(titleString: String) {
        titleLabel.text = titleString
    }
    
    @objc func deleteAction() {
        print("deleteAction")
        deleteTapped?()
    }
}
