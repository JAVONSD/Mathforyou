//
//  SearchResultCell.swift
//  SearchBar
//
//  Created by huangmian on 2018/7/26.
//  Copyright © 2018年 hm. All rights reserved.
//
import UIKit
import Kingfisher

class SearchResultCell: UITableViewCell {
    
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView.init(frame: CGRect.zero)
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel.init(frame: CGRect.zero)
        label.font = UIFont.boldSystemFont(ofSize: 18.0)
        label.textColor = UIColor.init(hexString: "#494949")
        return label
    }()
    
    private lazy var arrowImageView: UIImageView = {
        let imageView = UIImageView.init(image: #imageLiteral(resourceName: "cell_arrow"))
        return imageView
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
        contentView.addSubview(avatarImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(seperationView)
        contentView.addSubview(arrowImageView)
        
        avatarImageView.snp.makeConstraints {
            $0.left.top.bottom.equalToSuperview().inset(UIEdgeInsetsMake(30, 15, 15, 0))
            $0.width.height.equalTo(70)
        }
        avatarImageView.cornerRadius = 35
        
        titleLabel.snp.makeConstraints {
            $0.left.equalTo(avatarImageView.snp.right).offset(23.5)
            $0.right.equalTo(arrowImageView.snp.left).offset(-15)
            $0.centerY.equalTo(avatarImageView.snp.centerY)
        }
        
        arrowImageView.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-15)
            $0.centerY.equalTo(avatarImageView.snp.centerY)
            $0.width.equalTo(8)
            $0.height.equalTo(14)
        }
        
        seperationView.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview().inset(UIEdgeInsetsMake(0, 15, 0, 15))
            $0.height.equalTo(0.5)
        }
    }
    
    func setName(_ name: String) {
        titleLabel.text = name
    }
    
    func setAvartar(_ avartarUrl: String) {
        //avatarImageView.kf.setImage(with: URL(string: avartarUrl), placeholder: #imageLiteral(resourceName: "icon_avatar_default"))
        avatarImageView.image = #imageLiteral(resourceName: "jielun")
    }
    
}
