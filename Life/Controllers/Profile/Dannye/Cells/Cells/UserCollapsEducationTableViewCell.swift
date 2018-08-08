//
//  UserCollapsEducationTableViewCell.swift
//  Life
//
//  Created by 123 on 08.08.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Kingfisher
import SnapKit

class UserCollapsEducationTableViewCell: UITableViewCell {

    var modelItem: ProfileViewModelItem?
    
    let txtLabel: UILabel = {
        let nl = UILabel()
        nl.font = App.Font.subheadAlts
        nl.textColor = App.Color.black24
        nl.numberOfLines = 3
        nl.lineBreakMode = .byWordWrapping
        nl.adjustsFontForContentSizeCategory = true
        return nl
    }()
    
    let detailLabel: UILabel = {
        let jl = UILabel()
        jl.font = App.Font.body
        jl.numberOfLines = 3
        jl.lineBreakMode = .byWordWrapping
        jl.adjustsFontForContentSizeCategory = true
        return jl
    }()
    
    let rightTxtLabel: UILabel = {
        let nl = UILabel()
        nl.font = App.Font.subheadAlts
        nl.textColor = App.Color.black24
        nl.numberOfLines = 3
        nl.lineBreakMode = .byWordWrapping
        nl.adjustsFontForContentSizeCategory = true
        return nl
    }()
    
    let rightDetailLabel: UILabel = {
        let jl = UILabel()
        jl.font = App.Font.body
        jl.numberOfLines = 3
        jl.lineBreakMode = .byWordWrapping
        jl.adjustsFontForContentSizeCategory = true
        return jl
    }()
    
    static var identifier: String {
        return String(describing: self)
    }

    var item: UserProfile?
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
    
    fileprivate func setupViews() {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   

}







