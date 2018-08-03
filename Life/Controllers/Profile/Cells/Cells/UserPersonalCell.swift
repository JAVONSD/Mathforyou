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
        nl.textColor = App.Color.black24
        nl.numberOfLines = 1
        return nl
    }()
    
    let detailLabel: UILabel = {
        let jl = UILabel()
        jl.font = App.Font.body
        jl.numberOfLines = 3
        return jl
    }()
    
    let rightTxtLabel: UILabel = {
        let nl = UILabel()
        nl.font = App.Font.headline
        nl.textColor = App.Color.black24
        nl.numberOfLines = 1
        return nl
    }()
    
    let rightDetailLabel: UILabel = {
        let jl = UILabel()
        jl.font = App.Font.body
        jl.numberOfLines = 3
        return jl
    }()

    
    var item: UserProfile?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
    
    fileprivate func setupViews() {
        let leftStackView = UIStackView(arrangedSubviews: [txtLabel, detailLabel])
        leftStackView.axis = .vertical
        leftStackView.spacing = 3
        leftStackView.distribution = .fillEqually
        
        addSubview(leftStackView)
        leftStackView.snp.makeConstraints {
            $0.top.bottom.equalTo(self)
            $0.width.equalTo(self.snp.width).dividedBy(2).offset(-30)
            $0.left.equalTo(self).offset(20)
        }
        
        let rightStackView = UIStackView(arrangedSubviews: [rightTxtLabel, rightDetailLabel])
        rightStackView.axis = .vertical
        rightStackView.spacing = 3
        rightStackView.distribution = .fillEqually
        
        addSubview(rightStackView)
        rightStackView.snp.makeConstraints {
            $0.top.bottom.equalTo(self)
            $0.width.equalTo(self.snp.width).dividedBy(2).offset(-30)
            $0.right.equalTo(self).offset(-20)
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}













