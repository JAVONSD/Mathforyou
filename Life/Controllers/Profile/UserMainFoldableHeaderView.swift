//
//  UserMainFoldableHeaderView.swift
//  Life
//
//  Created by 123 on 01.08.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//


import UIKit

protocol UserMainFoldableHeaderViewDelegate: class {
    func toggleSection(header: UserMainFoldableHeaderView, section: Int)
}



class UserMainFoldableHeaderView: UITableViewHeaderFooterView {
    
    var item: UserProfile? {
        didSet {
            guard let item = item else {
                return
            }
            
            titleLabel?.text = item.company
//            setCollapsed(collapsed: item.isCollapsed)
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var arrowLabel: UILabel?
    
    // We will use the section variable to store the current section index
    var section: Int = 0
    
    weak var delegate: UserMainFoldableHeaderViewDelegate?

    
    static var identifier: String {
        return String(describing: self)
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        // To detect a user interaction we can set a TapGestureRecognizer in our header
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapHeader)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc private func didTapHeader() {
        delegate?.toggleSection(header: self, section: section)
    }
    
    func setCollapsed(collapsed: Bool) {
        // When we call this method for collapsed state,
        // it will rotate the arrow to the original position,
        // for expanded state it will rotate the arrow to pi radians.
        arrowLabel?.rotate(collapsed ? 0.0 : .pi)
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





