//
//  UserInfoHeaderView.swift
//  Life
//
//  Created by 123 on 01.08.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Kingfisher
import SnapKit
import Material

class UserInfoHeaderFooterView: UIView {

    var item: UserProfile? {
        didSet {
            guard
                let item = item
                else { return }
            
            fullNameLabel.text = item.fullname
            jobPositionLabel.text = item.jobPosition
            
            ImageDownloader.set(
                image: "",
                employeeCode: User.current.employeeCode,
                to: self.pictureImageView,
                placeholderImage: #imageLiteral(resourceName: "ic-user"),
                size: CGSize(width: 120, height: 120))
        }
    }
    
    let fullNameLabel: UILabel = {
        let fl = UILabel()
        fl.font = App.Font.headline
        fl.numberOfLines = 2
        return fl
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

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }

    fileprivate func setupViews() {
        addSubview(pictureImageView)
        pictureImageView.anchor(top: topAnchor, left: self.leftAnchor, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 120, height: 120)

        let stackView = UIStackView(arrangedSubviews: [fullNameLabel, jobPositionLabel])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually

        addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.top.equalTo(pictureImageView.snp.top)
            $0.right.equalTo(self.snp.right).offset(-20)
            $0.left.equalTo(pictureImageView.snp.right).offset(20)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}










