//
//  UserPickExecutorCell.swift
//  Life
//
//  Created by 123 on 06.08.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Kingfisher
import SnapKit

class UserPickExecutorCell: UITableViewCell {
    
    let executorTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Выберите исполнителя"
        tf.borderColor = App.Color.black
        tf.borderStyle = .roundedRect
        return tf
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
        addSubview(executorTextField)
        executorTextField.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsetsMake(20, 20, 20, 20))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}










