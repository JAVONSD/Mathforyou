//
//  SearchNewsCollectionCell.swift
//  Life
//
//  Created by 123 on 30.07.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Hue
import Material
import SnapKit

class SearchNewsCollectionCell: BaseCell {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Violet"
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.allowsDefaultTighteningForTruncation = true
        return label
    }()

    override func setupViews() {
        addSubview(titleLabel)
        addCustomConstrains()
    }
    
    fileprivate func addCustomConstrains() {
        titleLabel.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(20)
        }
    }
 
}












