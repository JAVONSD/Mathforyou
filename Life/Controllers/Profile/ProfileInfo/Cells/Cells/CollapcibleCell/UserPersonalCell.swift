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


class UserPersonalCell: UITableViewCell {
    
    var modelItem: ProfileViewModelItem? 
    
    static var identifier: String {
        return String(describing: self)
    }
    
    //---
    let containerView: UIView = {
        let view = UIView(frame: .zero)
        return view
    }()
    
    let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 3
        stack.distribution = .fill
        return stack
    }()
    
    //---
    let topView: UIView = {
        let view = UIView(frame: .zero)
        return view
    }()
    let caret: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "expand_arrow")
        return iv
    }()
    let titleLabel: UILabel = {
        let nl = UILabel()
        nl.font = App.Font.cardTitle
        nl.textColor = App.Color.black24
        nl.numberOfLines = 1
        nl.lineBreakMode = .byWordWrapping
        return nl
    }()
    
    //---
    let bottomStackView:  UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 3
        stack.distribution = .fill
        return stack
    }()
    
    //--
    let leftBottomStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 3
        stack.distribution = .fill
        return stack
    }()
    let txtLabel: UILabel = {
        let nl = UILabel()
        nl.font = App.Font.subheadAlts
        nl.textColor = App.Color.black24
        nl.numberOfLines = 3
        nl.lineBreakMode = .byWordWrapping
        return nl
    }()
    let detailLabel: UILabel = {
        let jl = UILabel()
        jl.font = App.Font.body
        jl.numberOfLines = 3
        jl.lineBreakMode = .byWordWrapping
        return jl
    }()
    
    //--
    let rightBottomStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 3
        stack.distribution = .fill
        return stack
    }()
    let rightTxtLabel: UILabel = {
        let nl = UILabel()
        nl.font = App.Font.subheadAlts
        nl.textColor = App.Color.black24
        nl.numberOfLines = 3
        nl.lineBreakMode = .byWordWrapping
        return nl
    }()
    let rightDetailLabel: UILabel = {
        let jl = UILabel()
        jl.font = App.Font.body
        jl.numberOfLines = 3
        jl.lineBreakMode = .byWordWrapping
        return jl
    }()
//---
    
    var item: UserProfile?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        txtLabel.text = ""
        detailLabel.text = ""
        rightTxtLabel.text = ""
        rightDetailLabel.text = ""
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
    
    fileprivate func setupViews() {
        // add caret and title into top view
        topView.addSubview(caret)
        caret.snp.makeConstraints {
            $0.right.equalTo(topView.snp.right).offset(-10)
            $0.width.height.equalTo(30)
            $0.centerY.equalTo(topView.snp.centerY)
        }
        
        topView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(topView.snp.top).offset(10)
            $0.left.equalTo(topView.snp.right).offset(10)
            $0.right.equalTo(caret.snp.left).offset(-10)
            $0.bottom.equalTo(topView.snp.bottom).offset(-10)
        }
        
        // add txtLabel detailLabel into leftBottomStackView
        leftBottomStackView.addArrangedSubview(txtLabel)
        leftBottomStackView.addArrangedSubview(detailLabel)
        
        // add rightTxtLabel rightDetailLabel into rightBottomStackView
        rightBottomStackView.addArrangedSubview(rightTxtLabel)
        rightBottomStackView.addArrangedSubview(rightDetailLabel)
        
        // add leftBottomStackView rightBottomStackView into bottomStackView
        bottomStackView.addArrangedSubview(leftBottomStackView)
        bottomStackView.addArrangedSubview(rightBottomStackView)
        
        // add topView bottomView into stackView
        stackView.addArrangedSubview(topView)
        stackView.addArrangedSubview(bottomStackView)
        
        // add stackView into containerView
        containerView.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.edges.equalTo(containerView.snp.edges)
        }
        
        // add containerView into self
        addSubview(containerView)
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}













