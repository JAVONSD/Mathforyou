//
//  UserHeaderTableCell.swift
//  Life
//
//  Created by 123 on 01.08.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Kingfisher
import SnapKit


class UserHeaderTableCell: UITableViewCell {
    
    var item: UserProfile?
    var modelItem: ProfileViewModelItem?
    
    static var identifier: String {
        return String(describing: self)
    }
    
    let pictureImageView: UIImageView = {
        let pi = UIImageView()
        return pi
    }()
    
    let companyLabel: UILabel = {
        let nl = UILabel()
        nl.font = App.Font.body
        nl.numberOfLines = 2
        return nl
    }()

    override func prepareForReuse() {
        super.prepareForReuse()
        
        pictureImageView.image = nil
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
    
    fileprivate func setupViews() {
        addSubview(pictureImageView)
        pictureImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 10, paddingLeft: 20, paddingBottom: 10, paddingRight: 0, width: 35, height: 35)

        addSubview(companyLabel)
        companyLabel.snp.makeConstraints {
            $0.left.equalTo(pictureImageView.snp.right).offset(20)
            $0.right.equalTo(self).offset(-20)
            $0.centerY.equalToSuperview()
        }
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}















