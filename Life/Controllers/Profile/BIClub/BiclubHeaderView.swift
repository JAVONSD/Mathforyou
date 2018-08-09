//
//  BiclubHeaderView.swift
//  Life
//
//  Created by 123 on 09.08.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Material
import RxCocoa
import RxSwift
import SnapKit

class BiclubHeaderView: UIView {
    
    let imageheader: UIImageView = {
        let img = UIImageView()
        img.image = #imageLiteral(resourceName: "bi")
        img.contentMode = .scaleAspectFit
        return img
    }()
    
    let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Ваша карта сотрудника"
        lbl.font = App.Font.headline
        lbl.textAlignment = .center
        return lbl
    }()
    
    let bodyLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Ваша карта сотрудника Ваша карта сотрудника Ваша карта сотрудника Ваша карта сотрудника Ваша карта сотрудника Ваша карта сотрудника"
        lbl.font = App.Font.body
        lbl.numberOfLines = 4
        return lbl
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    private func setupViews() {
        addSubview(imageheader)
        imageheader.snp.makeConstraints {
            $0.top.equalTo(self.snp.top)
            $0.left.equalTo(self.snp.left)
            $0.right.equalTo(self.snp.right)
            $0.height.equalTo(156)
        }
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(imageheader.snp.bottom).offset(25)
            $0.left.equalTo(self.snp.left)
            $0.right.equalTo(self.snp.right)
            $0.height.equalTo(20)
        }
        
        addSubview(bodyLabel)
        bodyLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(6)
            $0.left.equalTo(self.snp.left)
            $0.right.equalTo(self.snp.right)
            $0.height.equalTo(100)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


























