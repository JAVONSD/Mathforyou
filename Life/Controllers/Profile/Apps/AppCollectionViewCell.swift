//
//  AppCollectionViewCell.swift
//  Life
//
//  Created by 123 on 08.08.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import FileProvider
import RxSwift
import RxCocoa
import SnapKit
import Moya
import Moya_ModelMapper
import Material
import Kingfisher

class AppCollectionViewCell: UICollectionViewCell {
    
    static var identifier: String {
        return String(describing: self)
    }
    
    let appImageView: UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = 10
        img.layer.masksToBounds =  true
        return img
    }()
    
    let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "BI-Life"
        lbl.textAlignment = .center
        lbl.numberOfLines = 2
        lbl.textColor = .white
        return lbl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        addSubview(appImageView)
        appImageView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview().inset(UIEdgeInsetsMake(0, 0, 0, 0))
            $0.height.equalTo(self.snp.width)
        }
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(appImageView.snp.bottom).offset(4)
            $0.left.bottom.right.equalToSuperview()
        }
    }
}



















