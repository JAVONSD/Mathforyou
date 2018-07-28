//
//  SearchRelativeCell.swift
//  SearchBar
//
//  Created by huangmian on 2018/7/26.
//  Copyright © 2018年 hm. All rights reserved.
//

import UIKit

class SearchRelativeCell: UITableViewCell {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel.init(frame: CGRect.zero)
        label.font = UIFont.boldSystemFont(ofSize: 15.0)
        label.textColor = UIColor.init(hexString: "#494949")
        return label
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
        contentView.addSubview(titleLabel)
        contentView.addSubview(seperationView)
        
        titleLabel.snp.makeConstraints {
            $0.left.right.top.bottom.equalToSuperview().inset(UIEdgeInsetsMake(30, 15, 15, 15))
        }
        
        seperationView.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview().inset(UIEdgeInsetsMake(0, 15, 0, 15))
            $0.height.equalTo(0.5)
        }
    }
    
    func setSearchText(searchText: String) {
        let leftAttr = NSMutableAttributedString.init(string: "搜索")
        leftAttr.addAttributes([NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15), NSAttributedStringKey.foregroundColor : UIColor.init(hexString: "#63c6f9")],
                               range: NSMakeRange(0, leftAttr.length))
        
        let searchAttr = NSMutableAttributedString.init(string: searchText)
        searchAttr.addAttributes([NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15), NSAttributedStringKey.foregroundColor : UIColor.init(hexString: "#494949")],
                                 range: NSMakeRange(0, searchAttr.length))
        leftAttr.append(searchAttr)
        titleLabel.attributedText = leftAttr
    }
}
