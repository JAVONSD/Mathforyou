//
//  UserProfileCellWithTableView.swift
//  Life
//
//  Created by 123 on 03.08.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Kingfisher
import SnapKit
import IQKeyboardManagerSwift

class UserSubmitDescriptionCell: UITableViewCell {
    
    let descriptionTextView: UITextView = {
        let tv = UITextView()
        tv.toolbarPlaceholder = "Ввведите описание"
        tv.layer.borderColor = App.Color.black24.cgColor
        tv.layer.borderWidth = 0.5
        tv.layer.cornerRadius = 10
        return tv
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
        // add descriptionTextView into self
        addSubview(descriptionTextView)
        descriptionTextView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsetsMake(15, 15, 15, 15))
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
























