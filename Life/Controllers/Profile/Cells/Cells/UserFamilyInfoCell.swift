//
//  UserFamilyInfoCell.swift
//  Life
//
//  Created by 123 on 02.08.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Kingfisher
import SnapKit

class UserFamilyInfoCell: UITableViewCell {
    
    static var identifier: String {
        return String(describing: self)
    }
    
    let fullNameLabel: UILabel = {
        let nl = UILabel()
        nl.font = App.Font.headline
        nl.numberOfLines = 2
        return nl
    }()
    
    let jobPositionLabel: UILabel = {
        let jl = UILabel()
        jl.font = App.Font.footnote
        jl.textColor = App.Color.blackDisable
        jl.numberOfLines = 2
        return jl
    }()

    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    var item: UserProfile? {
        didSet {
            guard let item = item else {
                return
            }
            
            fullNameLabel.text = item.address
            jobPositionLabel.text = item.birthDate
            
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
    
    fileprivate func setupViews() {
        addSubview(fullNameLabel)
        fullNameLabel.snp.makeConstraints {
            $0.top.equalTo(self).offset(20)
            $0.left.equalTo(self.snp.right).offset(20)
            $0.right.equalTo(self).offset(-20)
        }
        
        addSubview(jobPositionLabel)
        jobPositionLabel.snp.makeConstraints {
            $0.top.equalTo(fullNameLabel.snp.bottom).offset(8)
            $0.left.equalTo(fullNameLabel.snp.left)
            $0.right.equalTo(self).offset(-20)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}







