//
//  UserSendButtonCell.swift
//  Life
//
//  Created by 123 on 06.08.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Kingfisher
import SnapKit

class UserSendButtonCell: UITableViewCell {
    
    let sendButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = App.Color.azure
        btn.layer.cornerRadius = 10
        return btn
    }()
    
    static var identifier: String {
        return String(describing: self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
    
    fileprivate func setupViews() {
        // add executorTextField into self
        addSubview(sendButton)
        sendButton.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsetsMake(0, 30, 0, 30))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}




