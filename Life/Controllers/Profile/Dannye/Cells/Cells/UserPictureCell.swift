//
//  UserPictureCell.swift
//  Life
//
//  Created by 123 on 04.08.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Kingfisher
import SnapKit
import Material

class UserPictureCell: UITableViewCell {
    
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
    
    var modelItem: ProfileViewModelItem?
    
    static var identifier: String {
        return String(describing: self)
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

    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
                
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
            $0.bottom.equalToSuperview().offset(-40)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}






