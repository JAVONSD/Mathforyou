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
    
    var item: UserProfile? {
        didSet {
            guard
                let item = item else { return }
            
            fullNameLabel.text = item.fullname
            jobPositionLabel.text = item.jobPosition
            
            ImageDownloader.set(
                image: "",
                employeeCode: User.current.employeeCode,
                to: self.pictureImageView,
                placeholderImage: #imageLiteral(resourceName: "ic-user"),
                size: CGSize(width: 96, height: 96)
            )
            
        }
    }
    
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
    
    let pictureImageView: UIImageView = {
        let pi = UIImageView()
        pi.layer.cornerRadius = 25
        pi.layer.masksToBounds = true
        pi.contentMode = .scaleAspectFit
        pi.backgroundColor = UIColor.lightGray
        return pi
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
        pictureImageView.snp.makeConstraints {
            $0.top.equalTo(self).offset(20)
            $0.left.equalTo(self).offset(20)
            $0.bottom.equalTo(self).offset(-20)
            $0.size.equalTo(CGSize(width: 96, height: 96))
        }
        
        addSubview(fullNameLabel)
        fullNameLabel.snp.makeConstraints {
            $0.top.equalTo(self).offset(20)
            $0.left.equalTo(pictureImageView.snp.right).offset(20)
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















