//
//  UserPersonalCell.swift
//  Life
//
//  Created by 123 on 02.08.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Kingfisher
import SnapKit

class ProfileViewModelPersonalItem: ProfileViewModelItem {
    
    var type: ProfileViewModelItemType {
        return .personal
    }
    
    var sectionTitle: String {
        return "personal"
    }
    
    var isCollapsed = true
    
    init() { }
}

class UserPersonalCell: UITableViewCell {
    
    var modelItem: ProfileViewModelItem? 
    
    static var identifier: String {
        return String(describing: self)
    }
    
    let txtLabel: UILabel = {
        let nl = UILabel()
        nl.font = App.Font.headline
        nl.numberOfLines = 2
        return nl
    }()
    
    let detailLabel: UILabel = {
        let jl = UILabel()
        jl.font = App.Font.footnote
        jl.textColor = App.Color.blackDisable
        jl.numberOfLines = 2
        return jl
    }()
    
    var item: UserProfile? {
        didSet {
            guard let item = item else {
                return
            }
            
            txtLabel.text = item.fullname
            detailLabel.text = item.jobPosition
 
            
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
    
    fileprivate func setupViews() {
        addSubview(txtLabel)
        txtLabel.snp.makeConstraints {
            $0.top.left.equalToSuperview().offset(16)
            $0.width.equalToSuperview().offset(-32)
            $0.height.equalTo(24)
        }
        
        addSubview(detailLabel)
        detailLabel.snp.makeConstraints {
            $0.top.equalTo(txtLabel.snp.bottom).offset(4)
            $0.left.equalToSuperview().offset(16)
            $0.width.equalToSuperview().offset(-32)
            $0.height.equalTo(24)
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}













