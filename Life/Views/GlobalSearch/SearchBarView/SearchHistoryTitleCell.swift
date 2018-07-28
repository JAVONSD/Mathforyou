//
//  SearchHistoryTitleCell.swift
//  SearchBar
//
//  Created by huangmian on 2018/7/26.
//  Copyright © 2018年 hm. All rights reserved.
//

import UIKit
import SnapKit

class SearchHistoryTitleCell: UITableViewCell {
    var cleanTapped: (()->Void)?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel.init()
        label.text = "搜索历史"
        label.font = UIFont.systemFont(ofSize: 12.0)
        label.textColor = UIColor.init(hexString: "#898989")
        return label
    }()
    
    private lazy var cleanButton: UIButton = {
        let button = UIButton.init(type: UIButtonType.custom)
        button.setTitle("清除历史", for: UIControlState.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12.0)
        button.setTitleColor(UIColor.init(hexString: "#898989"), for: UIControlState.normal)
        return button
    }()
    
    private lazy var seperationView: UIView = {
        let view = UIView.init(frame: CGRect.zero)
        view.backgroundColor = UIColor.init(hexString: "#ebeef1")
        return view
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = UITableViewCellSelectionStyle.none
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        self.contentView.addSubview(cleanButton)
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(seperationView)
        
        cleanButton.snp.makeConstraints {
            $0.right.top.bottom.equalToSuperview().inset(UIEdgeInsetsMake(33, 0, 16, 15))
        }
        
        cleanButton.addTarget(self, action: #selector(cleanAction), for: UIControlEvents.touchUpInside)
        
        titleLabel.snp.makeConstraints {
            $0.left.top.equalToSuperview().inset(UIEdgeInsetsMake(33, 15.5, 0, 0))
        }
        
        seperationView.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview().inset(UIEdgeInsetsMake(0, 15, 0, 15))
            $0.height.equalTo(0.5)
        }
    }
    
    @objc func cleanAction() {
        print("cleanAction")
        cleanTapped?()
    }
}
