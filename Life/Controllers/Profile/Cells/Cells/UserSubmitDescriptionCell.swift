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

class UserSubmitDescriptionCell: UITableViewCell {
    
    let descriptionTextView: UITextView = {
        let tv = UITextView()
        return tv
    }()

    static var identifier: String {
        return String(describing: self)
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupViews()
    }

    fileprivate func setupViews() {
        // add descriptionTextView into self
        addSubview(descriptionTextView)
        descriptionTextView.snp.makeConstraints {
            $0.edges.equalToSuperview().offset(15)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
























