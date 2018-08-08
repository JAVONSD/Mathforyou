//
//  UserSubmitImageCell.swift
//  Life
//
//  Created by 123 on 05.08.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Kingfisher
import SnapKit

class UserSubmitImageCell: UITableViewCell {
    
    let addImageView: UIImageView = {
        let iv = UIImageView()
        iv.isHidden = true
        iv.isUserInteractionEnabled = false
        return iv
    }()
    
    let addPhotoLabel: UILabel = {
        let lbl = UILabel()
        lbl.isUserInteractionEnabled = false
        lbl.borderColor = App.Color.black
        return lbl
    }()
    
    static var identifier: String {
        return String(describing: self)
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
    
    fileprivate func setupViews() {
        // add addPhotoLabel into self
        addSubview(addPhotoLabel)
        addPhotoLabel.frame = CGRect(x: 30, y: 10, width: 120, height: 20)
        
        // add addImageView into self
        addSubview(addImageView)
        addImageView.frame = CGRect(x: 113, y: 11, width: 201, height: 22)
        
    }
  
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}









