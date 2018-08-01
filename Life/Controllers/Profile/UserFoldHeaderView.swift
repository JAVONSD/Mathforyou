//
//  UserFoldHeaderView.swift
//  Life
//
//  Created by 123 on 01.08.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit

protocol HeaderViewDelegate: class {
    func toggleSection(header: UserFoldHeaderView, section: Int)
}

class UserFoldHeaderView: UITableViewHeaderFooterView {
    
    weak var delegate: HeaderViewDelegate?
    
    static var identifier: String {
        return String(describing: self)
    }
    
    // We will use the section variable to store the current section index
    var section: Int = 0
    
    let arrowLabel: UILabel = {
        let fl = UILabel()
        fl.text = "▽"
        return fl
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
 
    fileprivate func setupViews() {
        addSubview(arrowLabel)
        arrowLabel.snp.makeConstraints {
            $0.width.height.equalTo(35)
            $0.top.equalTo(self).offset(20)
            $0.right.equalTo(self).offset(-20)
        }
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapHeader)))
    }
    
    @objc private func didTapHeader() {
        delegate?.toggleSection(header: self, section: section)
    }
    
    func setCollapsed(collapsed: Bool) {
        // When we call this method for collapsed state,
        // it will rotate the arrow to the original position,
        // for expanded state it will rotate the arrow to pi radians.
        arrowLabel.rotate(collapsed ? 0.0 : .pi)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension UIView {
    func rotate(_ toValue: CGFloat, duration: CFTimeInterval = 0.2) {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        
        animation.toValue = toValue
        animation.duration = duration
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        
        self.layer.add(animation, forKey: nil)
    }
}
























